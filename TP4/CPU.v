module CPU (
input        CLOCK_50,
input[3:0]	 KEY,
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
	
	reg [31:0]   clk;
	reg [7:0]    modo;
	reg          sinal;
	reg          reset;
	
	wire [31:0]   PC;
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
		modo      = 8'b0;
	end

	assign codop        = out_mem_inst[15:12];
	assign s2           = out_mem_inst[3:0];
	assign s3           = out_mem_inst[7:4];
	assign s4           = out_mem_inst[11:8];
	assign imm          = out_mem_inst[11:0];
	assign res_low      = res_mult[15:0];
	assign res_high     = res_mult[31:16];
	
	assign LEDG[0] = clk[20];
	assign LEDG[1] = clk[20];
	assign LEDG[2] = clk[20];
	assign LEDG[3] = clk[20];
	assign LEDG[4] = clk[20];
	assign LEDG[5] = clk[20];
	assign LEDG[6] = clk[20];
	assign LEDG[7] = clk[20];

	always@(posedge CLOCK_50)
	begin
		clk = clk + 1;
	end

	decode_HEX H0 (.modo(modo[0]), .entrada(disp_escrito[3:0]),   .saida(HEX0));
	decode_HEX H1 (.modo(modo[1]), .entrada(disp_escrito[7:4]),   .saida(HEX1));
	decode_HEX H2 (.modo(modo[2]), .entrada(disp_escrito[11:8]),  .saida(HEX2));
	decode_HEX H3 (.modo(modo[3]), .entrada(disp_escrito[15:12]), .saida(HEX3));
	decode_HEX H4 (.modo(modo[4]), .entrada(disp_escrito[19:16]), .saida(HEX4));
	decode_HEX H5 (.modo(modo[5]), .entrada(disp_escrito[23:20]), .saida(HEX5));
	decode_HEX H6 (.modo(modo[6]), .entrada(disp_escrito[27:24]), .saida(HEX6));
	decode_HEX H7 (.modo(modo[7]), .entrada(disp_escrito[31:28]), .saida(HEX7));

	HEX_control HEX_control_cpu (.clock(clk[20]),      .codop(codop),        .operando1(operando1),       .operando2(operando2),   .operando3(operando3),
	                             .dado(dado_escrito),  .sinal(sinal),        .modo(modo),                 .display(disp_escrito));
	mem_inst    mem_i           (.address(PC),         .clock(clk[20]),      .q(out_mem_inst));
	control     ctrl            (.CodOP(codop),        .CLK(clk[20]),        .EscCondCP(EscCondCP),       .EscCP(EscCP),           .EscLR(EscLR),
	                             .FonteCP(FonteCP),    .ULA_OP(ULA_OP),      .ULA_A(ULA_A),               .ULA_B(ULA_B),           .EscReg(EscReg));
	mult        mult_cpu        (.entrada1(operando1), .entrada2(operando2), .saida(res_mult));
	banco_registradores db      (.clk(clk[20]),        .reset(reset),        .sinal(sinal), .entrada1(s3),.entrada2(s2),           .entrada3(s4),
	                             .dado(dado_escrito),  .saida1(operando1),   .saida2(operando2),
	                             .saida3(operando3));
	ula         ula_cpu         (.clock(clk[20]),      .fontecp(FonteCP),     .codop(codop),               .s3(s3),                .s2(s2),
	                             .operando1(operando1),.operando2(operando2),.imm(imm),                    .res_low(res_low),      .res_high(res_high),
	                             .dado(dado_escrito),  .pc(PC),              .reset(reset));


endmodule