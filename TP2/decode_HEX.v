module decode_HEX (
input[3:0]        entrada,
output reg[0:6]   saida
);

	wire [3:0] entrada;
	wire [0:6] saida;

	always@(entrada)
	begin
		case(entrada[3:0])
			4'b0000: saida <= 7'b0000001; //0
			4'b0001: saida <= 7'b1001111; //1
			4'b0010: saida <= 7'b0010010; //2
			4'b0011: saida <= 7'b0000110; //3
			4'b0100: saida <= 7'b1001100; //4
			4'b0101: saida <= 7'b0100100; //5
			4'b0110: saida <= 7'b0100000; //6
			4'b0111: saida <= 7'b0001111; //7
			4'b1000: saida <= 7'b0000000; //8
			4'b1001: saida <= 7'b0000100; //9
			4'b1010: saida <= 7'b0001000; //A
			4'b1011: saida <= 7'b1100000; //B
			4'b1100: saida <= 7'b0110001; //C
			4'b1101: saida <= 7'b1000010; //D
			4'b1110: saida <= 7'b0110000; //E
			4'b1111: saida <= 7'b0111000; //F
			default: saida <= 7'b1111111;
		endcase
	end
endmodule
