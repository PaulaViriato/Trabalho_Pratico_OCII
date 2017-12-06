module pipeline (
input        CLOCK_50,
input[3:0]	 KEY,
input[17:0]	 SW,
output[7:0]	 LEDG,
output[0:6]	 HEX0,
output[0:6]	 HEX1,
output[0:6]	 HEX2,
output[0:6]	 HEX3,
output[0:6]	 HEX4,
output[0:6]	 HEX5,
output[0:6]	 HEX6,
output[0:6]	 HEX7
);

/*---------------------------------------------------------------------------------------------*/
/*                  TRABALHO PRATICO 5 - PIPELINE - ORGANIZACAO DE COMPUTADORES II             */
/*    De posse do processador superescalar criado, com multiplicacao paralela, agora passa-se  */
/* a aprimorar o funcionamento do mesmo. Como trabalho final deve ser implementado um pipeline */
/* sobre o caminho de dados desenvolvido.                                                      */
/*                                                                                             */
/* -> IMPLEMENTACAO                                                                            */
/*    O pipeline deve ser desenvolvido com 3 estagios: Decodificacao, Execucao, Memorizacao.   */
/*    A organizacao e utilizacao dos registradores de pipeline ficam a cargo do grupo.         */
/*    Se houver necessidade de uma unidade de foward , a mesma DEVE ser implementada, caso     */
/* haja necessidade e nao for possivel implementa-la, por favor destaquem a necessidade de     */
/* inserir bolhas durante as simulacoes.                                                       */
/*                                                                                             */
/* -> VALIDACAO                                                                                */
/*    O trabalho deverá ser implementado em FPGA, de modo que seja possível passar como        */
/* entrada uma instrução ( por meio dos switches da FPGA, tal como feito no TP_II ) e          */
/* visualizar o conteúdo dos registradores nos LED’s de 7 segmentos, também conforme descrito  */
/* na especificação do TP_II.                                                                  */
/*    Além disso, deve ser gerado um script de simulação ( . do ) com uma sequência de         */
/* instruções usadas pelos próprios membros do grupo para validar o processador (ModelSim).    */
/*---------------------------------------------------------------------------------------------*/


/*---------- REGISTRADORES GLOBAIS ---------------*/
	reg [31:0]   CLK;
	reg [31:0]   PC;
	wire         RESET;
	wire [7:0]   MODE;
	wire [31:0]  DISP_ESCR;
	wire [31:0]  RES_MULT;
	wire [15:0]  RES_LOW;
	wire [15:0]  RES_HIGH;
	wire [15:0]  OPER1;
	wire [15:0]  OPER2;
	wire [15:0]  OPER3;
	wire [15:0]  OMI;

/*---------- REGISTRADORES DECODE  - D -----------*/
	reg        D_JUMPBNQ;
	reg [31:0] D_PC;
	reg [3:0]  D_CODOP;
	reg [3:0]  D_S2;
	reg [3:0]  D_S3;
	reg [3:0]  D_S4;
	reg [15:0] D_IMM;
	reg [15:0] D_OPER1;
	reg [15:0] D_OPER2;
	reg [15:0] D_OPER3;
	reg        D_M_START;
	reg[1:0]   D_FONTECP;
	reg        D_ESCREG;

/*---------- REGISTRADORES EXECUTE - E -----------*/
   reg        E_JUMPBNQ;
   reg [15:0] E_SAIDA;
   reg [3:0]  E_RD;
   reg [31:0] E_PC;
   reg        E_M_START;
   reg[1:0]   E_FONTECP;
   reg        E_ESCREG;

/*---------- REGISTRADORES MEMORY  - M -----------*/
   reg         M_JUMPBNQ;
   reg  [15:0] M_SAIDA;
   reg  [3:0]  M_RD;
   reg         M_ESCREG;
   wire [15:0] M_DATA;
   wire        M_WRITE;

   assign RESET    = (KEY[0] == 0)?(1'b1):(1'b0);
   assign RES_LOW  = RES_MULT[15:0];
   assign RES_HIGH = RES_MULT[31:16];
   assign M_DATA   = M_SAIDA;
   assign M_WRITE  = M_ESCREG;

   wire[1:0] FONTECP;
   wire      ESCREG;

	initial
	begin
		CLK = 32'b0;
		PC  = 32'b0;

		D_FONTECP <= 2'b0;
		D_ESCREG  <= 1'b0;
		D_PC      <= 32'b0;
		D_CODOP   <= 4'b0;
		D_S2      <= 4'b0;
		D_S3      <= 4'b0;
		D_S4      <= 4'b0;
		D_IMM     <= 16'b0;
		D_OPER1   <= 16'b0;
		D_OPER2   <= 16'b0;
		D_OPER3   <= 16'b0;
		D_M_START <= 1'b0;
		D_JUMPBNQ <= 1'b0;

		E_FONTECP <= 2'b0;
		E_ESCREG  <= 1'b0;
		E_SAIDA   <= 16'b0;
   		E_PC      <= 32'b0;
		E_RD      <= 4'b0;
		E_M_START <= 1'b0;
		E_JUMPBNQ <= 1'b0;

		M_ESCREG  <= 1'b0;
		M_RD      <= 4'b0;
		M_SAIDA   <= 16'b0;
		M_JUMPBNQ <= 1'b0;
	end
	
	assign LEDG[0] = CLK[25];
	assign LEDG[1] = CLK[25];
	assign LEDG[2] = CLK[25];
	assign LEDG[3] = CLK[25];
	assign LEDG[4] = CLK[25];
	assign LEDG[5] = CLK[25];
	assign LEDG[6] = CLK[25];
	assign LEDG[7] = CLK[25];

	decode_HEX H0 (.modo(MODE[0]), .entrada(DISP_ESCR[3:0]),   .saida(HEX0));
	decode_HEX H1 (.modo(MODE[1]), .entrada(DISP_ESCR[7:4]),   .saida(HEX1));
	decode_HEX H2 (.modo(MODE[2]), .entrada(DISP_ESCR[11:8]),  .saida(HEX2));
	decode_HEX H3 (.modo(MODE[3]), .entrada(DISP_ESCR[15:12]), .saida(HEX3));
	decode_HEX H4 (.modo(MODE[4]), .entrada(DISP_ESCR[19:16]), .saida(HEX4));
	decode_HEX H5 (.modo(MODE[5]), .entrada(DISP_ESCR[23:20]), .saida(HEX5));
	decode_HEX H6 (.modo(MODE[6]), .entrada(DISP_ESCR[27:24]), .saida(HEX6));
	decode_HEX H7 (.modo(MODE[7]), .entrada(DISP_ESCR[31:28]), .saida(HEX7));

	control_HEX HEX_control (.CLK(CLK[25]), .SIGNAL(M_WRITE), .OPER1(OPER1), .OPER2(OPER2), 
	                         .OPER3(OPER3), .DATA(M_DATA),    .MODE(MODE),   .DISPLAY(DISP_ESCR));

	always@(posedge CLOCK_50)
	begin
		CLK = CLK + 1;
	end

	mem_inst mem_i (.address(PC), .clock(CLK[25]), .q(OMI));

	control ctrl_cpu       (.CODOP(OMI[15:12]), .CLK(CLK[25]), .FONTECP(FONTECP), .ESCREG(ESCREG));
	mult mult_cpu          (.ini(D_M_START),    .clk(CLK[25]), .A(D_OPER1),       .B(D_OPER2),         .resultado(RES_MULT));
	banco_registradores db (.clk(CLK[25]),      .reset(RESET), .sinal(M_WRITE),   .entrada1(OMI[7:4]), .entrada2(OMI[3:0]), 
	                        .entrada3(M_RD),    .dado(M_DATA), .saida1(OPER1),    .saida2(OPER2),      .saida3(OPER3));


    /*------- DECODE FASE  - D ---------------*/
	always@(posedge CLK[25])
	begin
		if (RESET == 1'b1)
		begin
			D_JUMPBNQ <= 1'b0;
			D_FONTECP <= 2'b0;
			D_ESCREG  <= 1'b0;
			D_PC      <= 32'b0;
			D_CODOP   <= 4'b0;
			D_S2      <= 4'b0;
			D_S3      <= 4'b0;
			D_S4      <= 4'b0;
			D_IMM     <= 16'b0;
			D_OPER1   <= 16'b0;
			D_OPER2   <= 16'b0;
			D_OPER3   <= 16'b0;
			D_M_START <= 1'b0;
		end
		else
		begin
			if (D_JUMPBNQ == 1'b1)
			begin
				D_JUMPBNQ = 1'b0;
			end
			else
			begin
				D_JUMPBNQ <= ((FONTECP == 2'b0)?(1'b0):(1'b1));
				D_FONTECP <= FONTECP;
				D_ESCREG  <= ESCREG;

				D_PC    <= PC;
				D_CODOP <= OMI[15:12];
				D_S2    <= OMI[3:0];
				D_S3    <= OMI[7:4];
				D_S4    <= OMI[11:8];
				D_IMM   <= OMI[11:0];

				D_OPER1 <= (((OMI[7:4] == E_RD)&&(D_ESCREG == 1'b1))?(E_SAIDA):(OPER1));
				D_OPER2 <= (((OMI[3:0] == E_RD)&&(D_ESCREG == 1'b1))?(E_SAIDA):(OPER2));
				D_OPER3 <= (((OMI[11:8] == E_RD)&&(D_ESCREG == 1'b1))?(E_SAIDA):(OPER3));

				D_M_START <= ((D_CODOP == 4'b1111)?(1'b1):(1'b0));
			end
		end
	end

    /*------- EXECUTE FASE  - E --------------*/
	always@(posedge CLK[25])
	begin
		if (RESET == 1'b1)
		begin
			E_JUMPBNQ <= 1'b0;
			E_FONTECP <= 2'b0;
			E_ESCREG  <= 1'b0;
			E_SAIDA   <= 16'b0;
    		E_PC      <= 32'b0;
			E_RD      <= 4'b0;
			E_M_START <= 1'b0;
		end
		else
		begin
			if (E_JUMPBNQ == 1'b1)
			begin
				E_JUMPBNQ = 1'b0;
			end
			else
			begin
				E_JUMPBNQ <= ((D_FONTECP == 2'b0)?(1'b0):(1'b1));
				E_FONTECP <= D_FONTECP;
				E_ESCREG  <= D_ESCREG;
				E_RD      <= D_S4;

				case (D_CODOP[3:0])
					4'b0000: E_SAIDA    = D_OPER1 + D_OPER2;
					4'b0001: E_SAIDA    = D_OPER1 - D_OPER2;
					4'b0010: E_SAIDA    = ((D_OPER2 > D_S3)?(1'b1):(1'b0));
					4'b0011: E_SAIDA    = D_OPER2 & D_OPER1;
					4'b0100: E_SAIDA    = D_OPER2 | D_OPER1;
					4'b0101: E_SAIDA    = D_OPER2 ^ D_OPER1;
					4'b0110: E_SAIDA    = D_OPER2 & D_S3;
					4'b0111: E_SAIDA    = D_OPER2 | D_S3;
					4'b1000: E_SAIDA    = D_OPER2 ^ D_S3;
					4'b1001: E_SAIDA    = D_OPER2 + D_S3;
					4'b1010: E_SAIDA    = D_OPER2 - D_S3;
					4'b1011: E_PC[11:0] = D_IMM;
					4'b1100: E_PC[3:0]  = ((D_S3 == 0)?(D_S2):(D_PC[3:0]+(1'b1)));
					4'b1101: E_SAIDA    = RES_LOW;
					4'b1110: E_SAIDA    = RES_HIGH;
					4'b1111: E_M_START  = 1'b1;
					default: E_SAIDA    = 16'b0;
				endcase
			end
		end
	end

   /*------- MEMORY FASE  - M ---------------*/
	always@(posedge CLK[25])
	begin
		if (RESET == 1'b1)
		begin
			M_JUMPBNQ <= 1'b0;
			M_ESCREG  <= 1'b0;
    		M_RD      <= 4'b0;
    		M_SAIDA   <= 16'b0;
		end
		else
		begin
			if (M_JUMPBNQ == 1'b1)
			begin
				M_JUMPBNQ = 1'b0;
			end
			else
			begin
	    		PC        <= ((E_FONTECP != 2'b0)?(E_PC):(PC + 1));
				M_JUMPBNQ <= ((E_FONTECP == 2'b0)?(1'b0):(1'b1));
				M_ESCREG  <= E_ESCREG;
	    		M_SAIDA   <= E_SAIDA;
	    		M_RD      <= E_RD;
			end
		end
	end
endmodule
