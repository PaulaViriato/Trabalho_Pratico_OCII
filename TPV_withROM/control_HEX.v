module control_HEX (
input            CLK,
input            SIGNAL,
input[15:0]      OPER1,
input[15:0]      OPER2,
input[15:0]      OPER3,
input[15:0]      DATA,
output reg[7:0]  MODE,
output reg[31:0] DISPLAY
);
	always@(posedge CLK)
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
			DISPLAY[3:0]   <= DATA[3:0];
			DISPLAY[7:4]   <= DATA[7:4];
			DISPLAY[11:8]  <= DATA[11:8];
			DISPLAY[15:12] <= DATA[15:12];
			DISPLAY[19:16] <= OPER2[3:0];
			DISPLAY[23:20] <= OPER2[7:4];
			DISPLAY[27:24] <= OPER1[3:0];
			DISPLAY[31:28] <= OPER1[7:4];
		end
	end
endmodule
