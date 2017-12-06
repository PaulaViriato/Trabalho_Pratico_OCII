module control(
input[3:0]	    CODOP,
input           CLK,
output reg[1:0] FONTECP,
output reg	    ESCREG	
);

	initial 
	begin
		FONTECP = 2'b0;
		ESCREG = 1'b0;
	end

	always@(posedge CLK)
	begin

		if(CODOP[3:0] == 4'b1011)
		begin
			FONTECP = 2'b10;
			ESCREG = 1'b0;
		end

		else
		begin 

			if(CODOP[3:0] == 4'b1100)
			begin
				FONTECP = 2'b01;
				ESCREG = 1'b0;
			end
			
			else
			begin
				FONTECP = 2'b00;
				ESCREG = 1'b1;

				if(CODOP[3:0] == 4'b1111)
				begin
					ESCREG  = 1'b0;
				end
			end

		end
	end
endmodule