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
	wire          SIGNAL;
	wire          RESET;
	reg [7:0]    MODE;
	reg [31:0]   DISPLAY;
	wire          JMP_BEQ;
	wire [31:0]  DISP_ESCR;
	wire [31:0]  RES_MULT;
	wire [15:0]  RES_LOW;
	wire [15:0]  RES_HIGH;
	wire [15:0]  OPER1;
	wire [15:0]  OPER2;
	wire [15:0]  OPER3;
	wire [15:0]  out_mem_inst;

/*---------- REGISTRADORES DECODE  - D -----------*/
	reg [31:0] D_PC;
	reg [15:0] D_IR;
	reg [3:0]  D_CODOP;
	reg [3:0]  D_S2;
	reg [3:0]  D_S3;
	reg [3:0]  D_S4;
	reg [15:0] D_IMM;
	reg [15:0] D_OPER1;
	reg [15:0] D_OPER2;
	reg [15:0] D_OPER3;
	reg        D_M_START;

/*---------- REGISTRADORES EXECUTE - E -----------*/
    reg [15:0] E_SAIDA;
	reg [3:0]  E_CODOP;
    reg [3:0]  E_RD;
    reg [31:0] E_PC;
    reg [15:0] E_DATA;
	reg        E_M_START;

/*---------- REGISTRADORES MEMORY  - M -----------*/
    reg  [15:0]  M_SAIDA;
    reg  [3:0]  M_CODOP;
    reg  [3:0]  M_RD;
    wire [15:0] M_DATA;


//	assign REG_DEST	       = M_RD;
	
	assign SIGNAL          = (((D_CODOP[3:0] >= 4'b0000)&&(D_CODOP[3:0] < 4'b1010))||(D_CODOP[3:0] == 4'b1101)||(D_CODOP[3:0] == 4'b1110))?(1'b1):(1'b0);
	assign RESET           = (KEY[0] == 0)?(1'b1):(1'b0);
	assign JMP_BEQ         = ((D_CODOP[3:0] == 4'b1011)||(D_CODOP[3:0] == 4'b1100)||(E_PC != 32'b0))?(1'b1):(1'b0);
	assign TARGET_PC       = ((D_CODOP[3:0] == 4'b1011)||(D_CODOP[3:0] == 4'b1100))?(D_IMM):(E_PC);
	assign RES_LOW         = RES_MULT[15:0];
	assign RES_HIGH        = RES_MULT[31:16];
	assign DISP_ESCR       = DISPLAY;
	assign M_DATA          = M_SAIDA;


	wire      EscCondCP;
	wire	  EscCP;
	wire 	  EscLR;
	wire[1:0] FonteCP;
	wire[3:0] ULA_OP;
	wire	  ULA_A;
	wire	  ULA_B;
	wire	  EscReg;	

	initial
	begin
		CLK       = 32'b0;
		MODE      = 8'b0;
		DISPLAY   = 32'b0;
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

	always@(posedge CLOCK_50)
	begin
		CLK = CLK + 1;
	end

	mem_inst mem_i (.address(PC), .clock(CLK[25]), .q(out_mem_inst));

//	control ctrl (.CodOP(D_CODOP), .CLK(CLK[25]),     .EscCondCP(EscCondCP), .EscCP(EscCP), 
//	              .EscLR(EscLR),   .FonteCP(FonteCP), .ULA_OP(ULA_OP),       .ULA_A(ULA_A), 
//	              .ULA_B(ULA_B),   .EscReg(EscReg));
	
	mult mult_cpu (.ini(D_M_START), .clk(CLK[25]), .A(OPER1), .B(OPER2), .resultado(RES_MULT));
	
	banco_registradores db (.clk(CLK[25]),       .reset(RESET),      .sinal(SIGNAL),
	                        .entrada1(SW[7:4]),  .entrada2(SW[3:0]), .entrada3(M_RD),
	                        .dado(M_DATA),       .saida1(OPER1),     .saida2(OPER2),
	                        .saida3(OPER3));

    /*------- DECODE FASE  - D ---------------*/
	always@(posedge CLK[25])
	begin
		if ((RESET == 1'b1)||(JMP_BEQ == 1'b1))
		begin
			D_PC      = 32'b0;
			D_IR      = 16'b0;
			D_CODOP   = 4'b0;
			D_S2      = 4'b0;
			D_S3      = 4'b0;
			D_S4      = 4'b0;
			D_IMM     = 16'b0;
			D_OPER1   = 16'b0;
			D_OPER2   = 16'b0;
			D_OPER3   = 16'b0;
			D_M_START = 1'b0;

			if (RESET == 1'b1)
			begin
				PC = 32'b0;
			end
			if (RESET == 1'b1)
			begin
				PC = TARGET_PC;
			end
		end

		else
		begin
			D_PC      = PC;

			//Versao com sem RAM
			D_IR      = SW[15:0];
			D_CODOP   = SW[15:12];
			D_S2      = SW[3:0];
			D_S3      = SW[7:4];
			D_S4      = SW[11:8];
			D_IMM     = SW[11:0];

			//Versao com com RAM
			//D_IR      = OUT_MEM_INST;
			//D_CODOP   = OUT_MEM_INST[15:12];
			//D_S2      = OUT_MEM_INST[3:0];
			//D_S3      = OUT_MEM_INST[7:4];
			//D_S4      = OUT_MEM_INST[11:8];
			//D_IMM     = OUT_MEM_INST[11:0];

			D_OPER1   = OPER1;
			D_OPER2   = OPER2;
			D_OPER3   = OPER3;
			D_M_START = ((D_CODOP == 4'b1111)?(1'b1):(1'b0));
			
			PC = PC + 1;
		end
	end

    /*------- EXECUTE FASE  - E --------------*/
	always@(posedge CLK[25])
	begin
		if (RESET == 1'b1)
		begin
			E_SAIDA = 16'b0;
    		E_RD    = 4'b0;
    		E_PC    = 32'b0;
    		E_DATA  = 16'b0;
		end

		else
		begin
			case (D_CODOP[3:0])
				4'b0000: E_SAIDA = D_OPER1 + D_OPER2;
				4'b0001: E_SAIDA = D_OPER1 - D_OPER2;
				4'b0010: E_SAIDA = ((D_OPER2 > D_S3)?(1'b1):(1'b0));
				4'b0011: E_SAIDA = D_OPER2 & D_OPER1;
				4'b0100: E_SAIDA = D_OPER2 | D_OPER1;
				4'b0101: E_SAIDA = D_OPER2 ^ D_OPER1;
				4'b0110: E_SAIDA = D_OPER2 & D_S3;
				4'b0111: E_SAIDA = D_OPER2 | D_S3;
				4'b1000: E_SAIDA = D_OPER2 ^ D_S3;
				4'b1001: E_SAIDA = D_OPER2 + D_S3;
				4'b1010: E_SAIDA = D_OPER2 - D_S3;
				4'b1011: E_PC[11:0] = D_IMM;
				4'b1100: E_PC[3:0]  = ((D_S3 == 0)?(D_S2):(D_PC[3:0]+(1'b1)));
				4'b1101: E_SAIDA = RES_LOW;
				4'b1110: E_SAIDA = RES_HIGH;
				4'b1111: E_M_START  = 1'b1;
				default: E_SAIDA = 16'b0;
			endcase

			E_RD = D_S4;
			E_CODOP = D_CODOP;
		end
	end

   /*------- MEMORY FASE  - M ---------------*/
	always@(posedge CLK[25])
	begin
		if (RESET == 1'b1)
		begin
    		M_RD    = 4'b0;
    		M_CODOP = 4'b0;
    		M_SAIDA = 16'b0;
		end

		else
		begin
    		M_SAIDA = E_SAIDA;
    		M_RD    = E_RD;
    		M_CODOP = E_CODOP;
		end
	end

   /*------- Control HEX  - M ---------------*/
	always@(posedge CLK[25])
	begin
		if (SIGNAL == 1'b0)
		begin
			MODE           <= 8'b00001111;
			DISPLAY[3:0]   <= 4'b0;
			DISPLAY[7:4]   <= 4'b0;
			DISPLAY[11:8]  <= 4'b0;
			DISPLAY[15:12] <= 4'b0;
			DISPLAY[19:16] <= OPER1[3:0];
			DISPLAY[23:20] <= OPER1[7:4];
			DISPLAY[27:24] <= OPER3[3:0];
			DISPLAY[31:28] <= OPER3[7:4];
		end
		else
		begin
			MODE           <= 8'b11111111;
			DISPLAY[3:0]   <= M_SAIDA[3:0];
			DISPLAY[7:4]   <= M_SAIDA[7:4];
			DISPLAY[11:8]  <= M_SAIDA[11:8];
			DISPLAY[15:12] <= M_SAIDA[15:12];
			DISPLAY[19:16] <= OPER2[3:0];
			DISPLAY[23:20] <= OPER2[7:4];
			DISPLAY[27:24] <= OPER1[3:0];
			DISPLAY[31:28] <= OPER1[7:4];
		end
	end
endmodule
