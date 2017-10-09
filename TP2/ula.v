module ula (
input        CLK_50,
input[3:0]   codop,
input[3:0]   s4,
input[3:0]   s3, 
input[3:0]   s2
);
	
	reg [31:0]    clk;
	wire          sinal;
	wire [3:0]    codop;
	wire [3:0]    s2;
	wire [3:0]    s3;
	wire [3:0]    s4;
	wire [15:0]   operando1;
	wire [15:0]   operando2;
	wire [15:0]   dado;

	banco_registradores db(
	.clk(clk[25]),
	.sinal(sinal),
	.entrada1(s3),
	.entrada2(s2),
	.entrada3(s4),
	.dado(dado),
	.saida1(operando1),
	.saida2(operando2)
	);

	always@(posedge CLOCK_50)
	begin
		clk = clk + 1;		
	end

	always@(posedge clk[25])
	begin
	    sinal <= 1'b1;
		case (codop[3:0])
			4'b0000: assign dado = operando1 + operando2;
			4'b0001: assign dado = operando1 - operando2;
			4'b0010: if(operando2 > s3)? dado = 1'b1: dado = 1'b0;
			4'b0011: assign dado = operando2 & operando1;
			4'b0100: assign dado = operando2 | operando1;
			4'b0101: assign dado = operando2 ^ operando1;
			4'b0110: assign dado = operando2 & s3;
			4'b0111: assign dado = operando2 | s3;
			4'b1000: assign dado = operando2 ^ s3;
			4'b1001: assign dado = operando2 + s3;
			4'b1010: assign dado = operando2 - s3;
			default: dado <= 16'b0;
		endcase
	    sinal <= 1'b0;
	end
endmodule
