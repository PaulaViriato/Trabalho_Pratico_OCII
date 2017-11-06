module control(
input[3:0]	    CodOP,
input           CLK,
output reg      EscCondCP,
output reg	    EscCP,
output reg 	    EscLR,
output reg[1:0]	FonteCP,
output reg[3:0]	ULA_OP,
output reg	    ULA_A,
output reg[1:0] ULA_B,
output reg	    EscReg	
);

	initial 
	begin
		EscLR     = 1'b1;
		EscCondCP = 1'b0;
		EscCP     = 1'b0;
		EscReg    = 1'b0;
	end

	always@(posedge CLK)
	begin
		if(EscLR == 1'b1)
		begin
			EscLR  = 1'b0;
			ULA_OP = CodOP;

			if(CodOP == 4'b1011)
			begin
				EscCP   = 1'b1;
				FonteCP = 2'b10;
			end
			else
			begin 
				if(CodOP == 4'b1100)
				begin
					EscCondCP = 1'b1;
					ULA_A     = 1'b1;
					ULA_B     = 2'b10;
					FonteCP   = 2'b01;
				end
				else 
				begin
					EscReg  = 1'b1;
					ULA_A   = 1'b1;
					FonteCP = 2'b00;

					if(CodOP <= 4'b0101)
					begin
						ULA_B = 2'b10;
					end
					else
					begin
						ULA_B = 2'b01;
					end
				end
			end
		end
		else 
		begin
			if(EscReg == 1'b1)
			begin
				EscReg  = 1'b0;
				EscCP   = 1'b1;
				ULA_OP  = 2'b00;
				ULA_A   = 1'b0;
				ULA_B   = 2'b00;
				FonteCP = 2'b00;
			end
		end

		if((EscCP == 1'b1)||(EscCondCP == 1'b1))
		begin
			EscLR     = 1'b1;
			EscCondCP = 1'b0;
			EscCP     = 1'b0;
			EscReg    = 1'b0;
		end

	end
endmodule