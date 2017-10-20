module ula (
input		 CLOCK_50,
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
	
	reg [31:0]   clk;
	reg          sinal;
	reg          reset;
	reg [15:0]   dado;
	reg [7:0]    modo;
	reg [31:0]   display;
	
	wire [3:0]    codop;
	wire [3:0]    s2;
	wire [3:0]    s3;
	wire [3:0]    s4;
	wire [15:0]   dado_escrito;
	wire [31:0]   disp_escrito;
	wire [15:0]   operando1;
	wire [15:0]   operando2;
	wire [15:0]   operando3;
	
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
	assign dado_escrito = dado;
	assign disp_escrito = display;
	
	assign LEDG[0] = clk[20];
	assign LEDG[1] = clk[20];
	assign LEDG[2] = clk[20];
	assign LEDG[3] = clk[20];
	assign LEDG[4] = clk[20];
	assign LEDG[5] = clk[20];
	assign LEDG[6] = clk[20];
	assign LEDG[7] = clk[20];

	decode_HEX H0 (.modo(modo[0]), .entrada(disp_escrito[3:0]),   .saida(HEX0));
	decode_HEX H1 (.modo(modo[1]), .entrada(disp_escrito[7:4]),   .saida(HEX1));
	decode_HEX H2 (.modo(modo[2]), .entrada(disp_escrito[11:8]),  .saida(HEX2));
	decode_HEX H3 (.modo(modo[3]), .entrada(disp_escrito[15:12]), .saida(HEX3));
	decode_HEX H4 (.modo(modo[4]), .entrada(disp_escrito[19:16]), .saida(HEX4));
	decode_HEX H5 (.modo(modo[5]), .entrada(disp_escrito[23:20]), .saida(HEX5));
	decode_HEX H6 (.modo(modo[6]), .entrada(disp_escrito[27:24]), .saida(HEX6));
	decode_HEX H7 (.modo(modo[7]), .entrada(disp_escrito[31:28]), .saida(HEX7));

	banco_registradores db(.clk(clk[20]), .reset(reset), .sinal(sinal),
	                       .entrada1(s3), .entrada2(s2), .entrada3(s4),
	                       .dado(dado_escrito),	.saida1(operando1), .saida2(operando2),
	                       .saida3(operando3));

	always@(posedge CLOCK_50)
	begin
		clk = clk + 1;
	end

	always@(posedge clk[20])
	begin
		reset = 1'b0;

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
			default: dado = 16'b0;
		endcase

		if (KEY[0] == 1'b1)
		begin
    			sinal          <= 1'b0;
			modo           <= 8'b00001111;
			display[3:0]   <= 4'b0;
			display[7:4]   <= 4'b0;
			display[11:8]  <= 4'b0;
			display[15:12] <= 4'b0;
			display[19:16] <= operando1[3:0];
			display[23:20] <= operando1[7:4];
			display[27:24] <= operando3[3:0];
			display[31:28] <= operando3[7:4];
		end
		else
		begin
			if (KEY[3] == 1'b1)
			begin
	     			sinal          <= 1'b1;
				modo           <= 8'b11111111;
				display[3:0]   <= dado[3:0];
				display[7:4]   <= dado[7:4];
				display[11:8]  <= dado[11:8];
				display[15:12] <= dado[15:12];
				display[19:16] <= operando2[3:0];
				display[23:20] <= operando2[7:4];
				display[27:24] <= operando1[3:0];
				display[31:28] <= operando1[7:4];
			end
			else
			begin
			    sinal   <= 1'b0;
			    modo    <= 8'b0;
			    display <= 32'b0;
			end
		end
	end
endmodule
