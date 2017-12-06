module mult (
input            ini,
input            clk,
input[15:0]      A,
input[15:0]      B,
output reg[31:0] resultado
);

	reg[2:0]  state;
	reg[31:0] extA;
	reg[31:0] extB;
	reg[4:0]  counter;

	initial 
	begin
		state = 0;
	end

	always @(posedge clk)
	begin
		if(ini && state == 0)
		begin
			resultado = 0;
			extA = {{ 16{A[15]}}, A };
			extB = {{{B[15]}}, B };
			state = 1;
		end
		else
		begin
			if(state == 1)
			begin
				extB = extB << 1;
				
				case(extB[1:0])
					2'b01: resultado = resultado + extA;
					2'b10: resultado = resultado - extA;
				endcase
				
				state = 2;
				counter = 2;
				extA = extA + extA;
			end
			else
			begin
				if(state == 2)
				begin
					extB = extB>>1;

					case(extB[1:0])
						2'b01: resultado = resultado + extA;
						2'b10: resultado = resultado - extA;
					endcase

					counter = counter + 1;
					extA = extA + extA;
					
					if(extB == 0)
					begin
						state = 0;
					end
				end
			end
		end
	end
endmodule
