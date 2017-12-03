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

/*---------- DE = Decode ---------- */
reg [15:0] DE_IR;        // Fetch: Registrador de instrução do MIPS
reg [9:0]  DE_PC;        // Registrador que carrega o PC (usado no beq para calcular desvio)
reg [15:0] DE_immediate; // Imediato da instrução
reg [15:0] DE_S2;        // Registrador A do MIPS
reg [15:0] DE_S3;        // Registrador B do MIPS
reg [3:0]  DE_S4;		 //Registrador destino
reg [7:0]  DE_FSM2;      // Decode: controle das instruções do MIPS
/*---------- ID = Decode ---------- */

/*---------- EX = Execute ---------- */
reg [31:0] EM_saida_ula;	        //registrador de saída da ULA do MIPS
reg [7:0]  EM_FSM2;			        //Controle das instruções
reg [4:0]  EM_RD;				    //Registrador Destino
reg [9:0]  EM_PC;				    // Registrador que carrega o PC
reg [31:0] EM_dado_a_ser_escrito;	//Dado que sera escrito no BR
/*---------- EX = Execute ---------- */

/*---------- Memory ---------------- */
reg [31:0] MW_saida_ula;	//registrador de saida da ula
reg [7:0] MW_FSM2;			//Controle das instruções
reg [4:0] MW_RD;				//Registrador Destino
wire [31:0] MW_dado_a_ser_escrito;
/*---------- Memory ---------------- */

/*---------- Writeback ---------------- */
wire br_wen;	//write enable do banco de registradores
wire reset;		//RESET
/*---------- Writeback ---------------- */

wire is_jmp_or_beq; //Identifica instrucoes do tipo BEQ/JUMP que serao executadas
reg block_fetch; //Identifica quando deve matar instrucoes erradas
wire [31:0] target_PC; //PC de destino em BEQ/JUMP
wire [31:0] out_mem_inst; //saída da memória de instruções
wire [31:0] out_mem_data; //saída da memória de dados
wire signal_wren; 		 //write enable em memoria
wire [4:0] signal_rd; // utilizado para "criar" o multiplexador que seleciona o registrador de destino do MIPS
wire [31:0] signal_dado_a_ser_escrito; // utilizado para "criar" o multiplexador que seleciona qual dado será salvo no banco de registradores do MIPS

	reg [31:0]   clk;
	reg [31:0]   PC;
	reg          sinal;
	reg          reset;
	reg          ini;
	reg [15:0]   dado;
	reg [7:0]    modo;
	reg [31:0]   display;
	
	wire [15:0]   out_mem_inst;
	wire [3:0]    codop;
	wire [3:0]    s2;
	wire [3:0]    s3;
	wire [3:0]    s4;
	wire [15:0]   imm;
	wire [15:0]   dado_escrito;
	wire [31:0]   disp_escrito;
	wire [15:0]   operando1;
	wire [15:0]   operando2;
	wire [15:0]   operando3;
	wire [31:0]   res_mult;
	wire [15:0]   res_low;
	wire [15:0]   res_high;

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
		clk       = 32'b0;
		reset     = 1'b1;
		sinal     = 1'b0;
		dado      = 16'b0;
		modo      = 8'b0;
		display   = 32'b0;
	end

	assign codop        = SW[15:12];
	assign s2           = SW[3:0];
	assign s3           = SW[7:4];
	assign s4           = SW[11:8];
	assign imm          = SW[11:0];
	assign res_low      = res_mult[15:0];
	assign res_high     = res_mult[31:16];

	assign dado_escrito = dado;
	assign disp_escrito = display;
	
	assign LEDG[0] = clk[25];
	assign LEDG[1] = clk[25];
	assign LEDG[2] = clk[25];
	assign LEDG[3] = clk[25];
	assign LEDG[4] = clk[25];
	assign LEDG[5] = clk[25];
	assign LEDG[6] = clk[25];
	assign LEDG[7] = clk[25];

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
		clk = clk + 1;
	end

	mem_inst mem_i (.address(PC), .clock(clk[25]), .q(out_mem_inst));
	control ctrl (.CodOP(codop), .CLK(clk[25]),     .EscCondCP(EscCondCP), .EscCP(EscCP), 
	              .EscLR(EscLR), .FonteCP(FonteCP), .ULA_OP(ULA_OP),       .ULA_A(ULA_A), 
	              .ULA_B(ULA_B), .EscReg(EscReg));
	mult mult_cpu (.ini(ini), .clk(clk[25]), .A(operando1), .B(operando2), .resultado(res_mult));
	banco_registradores db (.clk(clk[25]),       .reset(reset),      .sinal(sinal),
	                        .entrada1(s3),       .entrada2(s2),      .entrada3(s4),
	                        .dado(dado_escrito), .saida1(operando1), .saida2(operando2),
	                        .saida3(operando3));

	assign MW_dado_a_ser_escrito = ( (MW_FSM2 == `INST_LW) ) ? out_mem_data : MW_saida_ula;	
	assign signal_rd	=	MW_RD;
	assign signal_wren = (EM_FSM2 == `INST_SW) ? 1'b1 : 1'b0;
	assign br_wen = (MW_FSM2 == `INST_ADDI || MW_FSM2 == `INST_ADD ||
						  MW_FSM2 == `INST_SUB || MW_FSM2 == `INST_LW) ? 1'b1 : 1'b0;
	assign reset = (KEY[0] == 0) ?  1'b1 : 1'b0 ;
	assign is_jmp_or_beq = (FD_IR[31:26] == `J_OP_JUMP) || (EM_PC != 9'b0)  ? 1'b1 : 1'b0;
	assign target_PC =  (FD_IR[31:26] == `J_OP_JUMP) ? {{10{FD_IR[9]}}, FD_IR[9:0]} : EM_PC;


	/*---------- IF = Fetch ---------- */
	always@(posedge clk[25])begin
		if(KEY[0] == 0)// Reset
		begin
			PC = 10'b0;
			DE_IR = 32'b0;
			block_fetch = 1'b0;
		end
		else begin
			if(is_jmp_or_beq == 1'b0)
			begin
				if(block_fetch == 1'b0)
				begin
					DE_PC <= PC;
					PC = PC + 1;				
					DE_IR <= out_mem_inst;					
				end
				else begin
					block_fetch <= 1'b0;
				end
			end
			else begin
				PC <= target_PC;
				DE_IR <= 32'b0;
				block_fetch <= 1'b1;
			end
			
		end
	end
	/*---------- IF = Fetch ---------- */

	
	/*---------- ID = Decode ---------- */
	always@(posedge clk[25])begin
		if(KEY[0] == 0 || is_jmp_or_beq == 1'b1 || block_fetch == 1'b1)// Reset/kill op
		begin
			DE_FSM2 = 8'b0;
			DE_RD = 5'b0;
			DE_A = 32'b0;
			DE_B = 32'b0;
			DE_immediate = 32'b0;
		end
		else
			if(FD_IR[31:26] == `OPCODE_R) // add or sub
			begin
				if(FD_IR[5:0] == `R_OP_ADD) begin
					DE_FSM2 <= `INST_ADD;		//add			
				end			
				if(FD_IR[5:0] == `R_OP_SUB) begin
					DE_FSM2 <= `INST_SUB;		//sub		
				end
					DE_RD <= FD_IR[15:11];		//Registrador destino
			end
			if(FD_IR[31:26] == `I_OP_ADDI)//addi
			begin
				DE_FSM2 <= `INST_ADDI;//addi
				DE_RD <= FD_IR[20:16];	//Registrador de destino
			end
			if(FD_IR[31:26] == `I_OP_BEQ) // beq
			begin
				DE_FSM2 <= `INST_BEQ;//beq
			end
			if(FD_IR[31:26] == `J_OP_JUMP) // jump
			begin
				DE_FSM2 <= 8'b0;
				DE_RD <= 5'b0;
				DE_A <= 32'b0;
				DE_B <= 32'b0;
				DE_immediate <= 32'b0;
			end				
			if(FD_IR[31:26] == `I_OP_LW) // load
			begin
				DE_FSM2 <= `INST_LW;//load
				DE_RD <= FD_IR[20:16];	//Registrador de destino
			end
			if(FD_IR[31:26] == `I_OP_SW) // store
			begin
				DE_FSM2 <= `INST_SW;//store
			end
			if(FD_IR == 32'b0)
			begin
				DE_FSM2 <= 8'b0;
			end
			
			DE_A <= dado_lido_1;
			DE_B <= dado_lido_2;
			DE_PC <= FD_PC;
			DE_immediate <= {{16{FD_IR[15]}}, FD_IR[15:0]};		
		end	
	/*---------- ID = Decode ---------- */
	
	
	/*---------- EX = Execute ---------- */
	always@(posedge clk[25])begin
		if(KEY[0] == 0)// Reset/kill op
		begin
			EM_saida_ula = 32'b0;
			EM_FSM2 = 32'b0;
			EM_RD = 5'b0;
			EM_PC = 10'b0;
			EM_dado_a_ser_escrito = 32'b0;
		end
		else
		begin
			case (codop[3:0])
				4'b0000: dado = operando1 + operando2;
				4'b0001: dado = operando1 - operando2;
				4'b0010: dado = ((operando2 > s3)?(1'b1):(1'b0));
				4'b0011: dado = operando2 & operando1;
				4'b0100: dado = operando2 | operando1;
				4'b0101: dado = operando2 ^ operando1;
				4'b0110: dado = operando2 & s3;
				4'b0111: dado = operando2 | s3;
				4'b1000: dado = operando2 ^ s3;
				4'b1001: dado = operando2 + s3;
				4'b1010: dado = operando2 - s3;
				4'b1011: PC[11:0] = imm;
				4'b1100: PC[3:0]  = ((s3 == 0)?(s2):(PC[3:0]+(1'b1)));
				4'b1101: dado = res_low;
				4'b1110: dado = res_high;
				4'b1111: ini  = 1'b1;
				default: dado = 16'b0;
			endcase
			
			EM_FSM2 <= DE_FSM2;
			EM_RD <= DE_RD;		
		end
	end
	/*---------- EX = Execute ---------- */

	
	/*---------- MEM = Memory ---------- */
	always@(posedge clk[25])begin
		if(KEY[0] == 0)// Reset
		begin
			MW_saida_ula = 32'b0;
			MW_FSM2 = 32'b0;
			MW_RD = 5'b0;
		end
	
		MW_FSM2 <= EM_FSM2;
		MW_saida_ula <= EM_saida_ula;		
		MW_RD <= EM_RD;
	end
	/*---------- MEM = Memory ---------- */

endmodule