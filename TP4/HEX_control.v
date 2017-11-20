module HEX_control (
input            clock,
input    	     EscReg,
input[15:0]      operando1,
input[15:0]      operando2,
input[15:0]      operando3,
input[15:0]      dado,
output reg	     sinal,
output reg       modo,
output reg[31:0] display
);
	
	always@(posedge clock)
	begin
		if (EscReg == 1'b0)
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
			if (EscReg == 1'b1)
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