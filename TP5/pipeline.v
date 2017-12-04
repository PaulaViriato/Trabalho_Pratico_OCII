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
	reg          SIGNAL;
	reg          RESET;
	reg [7:0]    MODE;
	reg [31:0]   DISPLAY;
	reg          JMP_BEQ;
	wire [31:0]  DISP_ESCR;
	wire [31:0]  RES_MULT;
	wire [15:0]  RES_LOW;
	wire [15:0]  RES_HIGH;

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
    reg  [3:0]  M_CODOP;
    reg  [3:0]  M_RD;
    wire [15:0] M_DATA;


	assign br_wen = (MW_FSM2 == `INST_ADDI || MW_FSM2 == `INST_ADD ||
						  MW_FSM2 == `INST_SUB || MW_FSM2 == `INST_LW) ? 1'b1 : 1'b0;
	assign REG_DEST	       = MW_RD;
	assign RESET           = (KEY[0] == 0)?(1'b1):(1'b0);
	assign JMP_BEQ         = ((D_CODOP[3:0] == 4'b)||(E_PC != 9'b0))?(1'b1):(1'b0);
	assign TARGET_PC[11:0] = (D_CODOP[3:0] == 4'b)?(D_IMM):(E_PC);
	assign RES_LOW         = RES_MULT[15:0];
	assign RES_HIGH        = RES_MULT[31:16];
	assign DISP_ESCR       = DISPLAY;



/*---------- Writeback ---------------- */
wire br_wen;	//write enable do banco de registradores
wire reset;		//RESET
/*---------- Writeback ---------------- */


	wire [15:0]   operando1;
	wire [15:0]   operando2;
	wire [15:0]   operando3;

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
		RESET     = 1'b1;
		SIGNAL    = 1'b0;
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

	decode_HEX H0 (.modo(modo[0]), .entrada(disp_escrito[3:0]),   .saida(HEX0));
	decode_HEX H1 (.modo(modo[1]), .entrada(disp_escrito[7:4]),   .saida(HEX1));
	decode_HEX H2 (.modo(modo[2]), .entrada(disp_escrito[11:8]),  .saida(HEX2));
	decode_HEX H3 (.modo(modo[3]), .entrada(disp_escrito[15:12]), .saida(HEX3));
	decode_HEX H4 (.modo(modo[4]), .entrada(disp_escrito[19:16]), .saida(HEX4));
	decode_HEX H5 (.modo(modo[5]), .entrada(disp_escrito[23:20]), .saida(HEX5));
	decode_HEX H6 (.modo(modo[6]), .entrada(disp_escrito[27:24]), .saida(HEX6));
	decode_HEX H7 (.modo(modo[7]), .entrada(disp_escrito[31:28]), .saida(HEX7));

	always@(posedge CLOCK_50)
	begin
		CLK = CLK + 1;
	end

	mem_inst mem_i (.address(PC), .clock(clk[25]), .q(out_mem_inst));
	control ctrl (.CodOP(codop), .CLK(clk[25]),     .EscCondCP(EscCondCP), .EscCP(EscCP), 
	              .EscLR(EscLR), .FonteCP(FonteCP), .ULA_OP(ULA_OP),       .ULA_A(ULA_A), 
	              .ULA_B(ULA_B), .EscReg(EscReg));
	mult mult_cpu (.ini(ini), .clk(clk[25]), .A(operando1), .B(operando2), .resultado(res_mult));
	banco_registradores db (.clk(clk[25]),       .reset(reset),      .sinal(sinal),
	                        .entrada1(s3),       .entrada2(s2),      .entrada3(REG_DEST),
	                        .dado(M_DATA),       .saida1(operando1), .saida2(operando2),
	                        .saida3(operando3));



    /*------- DECODE FASE  - D ---------------*/
	always@(posedge CLK[25])
	begin
		if ((KEY[0] == 0)||(JMP_BEQ == 1'b1))
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

			if (KEY[0] == 0)
			begin
				PC = 32'b0;
			end
			if (JMP_BEQ == 1'b1)
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

			D_OPER1   = operando1;
			D_OPER2   = operando2;
			D_OPER3   = operando3;
			D_M_START = ((D_CODOP == 4'b1111)?(1'b1):(1'b0));
			
			PC = PC + 1;
		end
	end

    /*------- EXECUTE FASE  - E --------------*/
	always@(posedge CLK[25])
	begin
		if (KEY[0] == 0)
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
				4'b1100: E_PC[3:0]  = ((D_S3 == 0)?(s2):(D_PC[3:0]+(1'b1)));
				4'b1101: E_SAIDA = res_low;
				4'b1110: E_SAIDA = res_high;
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
		if (KEY[0] == 0)
		begin
    		M_RD    = 4'b0;
    		M_CODOP = 4'b0;
    		M_DATA  = 16'b0;
		end

		else
		begin
    		M_DATA  = E_SAIDA;
    		M_RD    = E_RD;
    		M_CODOP = E_CODOP;
		end
	end

endmodule