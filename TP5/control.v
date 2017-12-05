module control(
input[3:0]	    CODOP,
input           CLK,
output reg      ESCCONDCP,
output reg	    ESCCP,
output reg 	    ESCIR,
output reg[1:0] FONTECP,
output reg[3:0] ULA_OP,
output reg	    ESCREG	
);

	initial 
	begin
		ESCIR     = 1'b1;
		ESCCONDCP = 1'b0;
		ESCCP     = 1'b0;
		ESCREG    = 1'b0;
	end

	always@(posedge CLK)
	begin
		if(ESCIR == 1'b1)
		begin
			ESCIR  = 1'b0;
			ULA_OP = CODOP;

			if(CODOP[3:0] == 4'b1011)
			begin
				ESCCP   = 1'b1;
				FONTECP = 2'b10;
			end

			else
			begin 
				if(CODOP[3:0] == 4'b1100)
				begin
					ESCCONDCP = 1'b1;
					FONTECP   = 2'b01;
				end
				
				else
				begin
					if(CODOP[3:0] == 4'b1111)
					begin
						ESCCP = 1'b1;
					end

					else 
					begin	
						ESCREG  = 1'b1;
						FONTECP = 2'b00;
					end
				end
			end
		end
		
		else 
		begin
			if(ESCREG == 1'b1)
			begin
				ESCREG  = 1'b0;
				ESCCP   = 1'b1;
				ULA_OP  = 2'b00;
				FONTECP = 2'b00;
			end
		end

		if((ESCCP == 1'b1)||(ESCCONDCP == 1'b1))
		begin
			ESCIR     = 1'b1;
			ESCCONDCP = 1'b0;
			ESCCP     = 1'b0;
			ESCREG    = 1'b0;
		end
	end
endmodule