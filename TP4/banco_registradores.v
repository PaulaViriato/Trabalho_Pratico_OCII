module banco_registradores (
input              clk,
input              reset,
input              sinal,
input[3:0]         entrada1, 
input[3:0]         entrada2,
input[3:0]         entrada3, 
input[15:0]        dado,
output reg[15:0]   saida1, 
output reg[15:0]   saida2,
output reg[15:0]   saida3
);

	reg [15:0] R0;
	reg [15:0] R1;
	reg [15:0] R2;
	reg [15:0] R3;
	reg [15:0] R4;
	reg [15:0] R5;
	reg [15:0] R6;
	reg [15:0] R7;
	reg [15:0] R8;
	reg [15:0] R9;
	reg [15:0] R10;
	reg [15:0] R11;
	reg [15:0] R12;
	reg [15:0] R13;
	reg [15:0] R14;
	reg [15:0] R15;

	always@(posedge clk)
	begin
		case (entrada1[3:0])
			4'b0000: saida1 = R0;
			4'b0001: saida1 = R1;
			4'b0010: saida1 = R2;
			4'b0011: saida1 = R3;
			4'b0100: saida1 = R4;
			4'b0101: saida1 = R5;
			4'b0110: saida1 = R6;
			4'b0111: saida1 = R7;
			4'b1000: saida1 = R8;
			4'b1001: saida1 = R9;
			4'b1010: saida1 = R10;
			4'b1011: saida1 = R11;
			4'b1100: saida1 = R12;
			4'b1101: saida1 = R13;
			4'b1110: saida1 = R14;
			4'b1111: saida1 = R15;
			default: saida1 = 16'b0;
		endcase
		
		case (entrada2[3:0])
			4'b0000: saida2 = R0;
			4'b0001: saida2 = R1;
			4'b0010: saida2 = R2;
			4'b0011: saida2 = R3;
			4'b0100: saida2 = R4;
			4'b0101: saida2 = R5;
			4'b0110: saida2 = R6;
			4'b0111: saida2 = R7;
			4'b1000: saida2 = R8;
			4'b1001: saida2 = R9;
			4'b1010: saida2 = R10;
			4'b1011: saida2 = R11;
			4'b1100: saida2 = R12;
			4'b1101: saida2 = R13;
			4'b1110: saida2 = R14;
			4'b1111: saida2 = R15;
			default: saida2 = 16'b0;
		endcase

		case (entrada3[3:0])
			4'b0000: saida3 = R0;
			4'b0001: saida3 = R1;
			4'b0010: saida3 = R2;
			4'b0011: saida3 = R3;
			4'b0100: saida3 = R4;
			4'b0101: saida3 = R5;
			4'b0110: saida3 = R6;
			4'b0111: saida3 = R7;
			4'b1000: saida3 = R8;
			4'b1001: saida3 = R9;
			4'b1010: saida3 = R10;
			4'b1011: saida3 = R11;
			4'b1100: saida3 = R12;
			4'b1101: saida3 = R13;
			4'b1110: saida3 = R14;
			4'b1111: saida3 = R15;
			default: saida3 = 16'b0;
		endcase

		if (reset == 1'b1)
		begin
			R0  = 16'b0;
			R1  = 16'b0;
			R2  = 16'b0;
			R3  = 16'b0;
			R4  = 16'b0;
			R5  = 16'b0;
			R6  = 16'b0;
			R7  = 16'b0;
			R8  = 16'b0;
			R9  = 16'b0;
			R10 = 16'b0;
			R11 = 16'b0;
			R12 = 16'b0;
			R13 = 16'b0;
			R14 = 16'b0;
			R15 = 16'b0;
		end

		if (sinal == 1'b1)
		begin
			case (entrada3[3:0])
				4'b0000: R0  = dado;
				4'b0001: R1  = dado;
				4'b0010: R2  = dado;
				4'b0011: R3  = dado;
				4'b0100: R4  = dado;
				4'b0101: R5  = dado;
				4'b0110: R6  = dado;
				4'b0111: R7  = dado;
				4'b1000: R8  = dado;
				4'b1001: R9  = dado;
				4'b1010: R10 = dado;
				4'b1011: R11 = dado;
				4'b1100: R12 = dado;
				4'b1101: R13 = dado;
				4'b1110: R14 = dado;
				4'b1111: R15 = dado;
			endcase
		end
	end
endmodule
