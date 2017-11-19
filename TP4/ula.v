module ula (
input        clock,
input[1:0]   fontecp,
input[3:0]	 codop,
input[3:0]	 s3,
input[3:0]	 s2,
input[15:0]  operando1,
input[15:0]	 operando2,
input[15:0]	 imm,
input[15:0]	 res_low,
input[15:0]	 res_high,
output[15:0] dado,
output[31:0] pc,
output   	 reset
);
	
	always@(posedge clock)
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
			4'b1011: pc[11:0] = imm;
			4'b1100: pc[3:0]  = ((s3 == 0)?(s2):(pc[3:0]+(1'b1)));
			4'b1101: dado = res_low;
			4'b1110: dado = res_high;
			default: dado = 16'b0;
		endcase

		if (fontecp == 2'b00)
		begin
			pc = pc + 1;
		end
	end

endmodule