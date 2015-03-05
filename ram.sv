// RAM_Test requires that the registers write enable occurs on negedge, not posedge.

module RAM_Test(output logic [21:0] RAMdata, output logic PC_Reset, input [9:0] address, input [6:0][8:0] registers, input clock); 
logic [30:0] testvectors[1024:0]; 
integer errorCount = 0;
integer lastAddress = -4;
initial
	begin
    $readmemb("cpu_test.txt", testvectors);
		RAMdata <= testvectors[0][30:9];
		PC_Reset <= 1;		
	end // initial

always@(posedge clock)
	begin
		if(address == 0)
			begin
				PC_Reset <= 0;
				lastAddress = 0;
			end
		else  // address not zero
			lastAddress = lastAddress + 1;
		

		 assert((address == lastAddress) || lastAddress < 0)
			else
				begin
					$error("Address was %d, but should be %d", address, lastAddress);
					$stop;
				end // assert

		if(lastAddress < 0)
			RAMdata <= testvectors[0][30:9];  // MOVI(reg 0, ...);
		else
			RAMdata <= testvectors[address][30:9];

		 assert(lastAddress <= 0 
				|| registers[testvectors[address - 1][20:18]] == testvectors[address - 1][8:0])
					else
						begin
					    $display("Error at address: %h reg%b was %b, but was supposed to be %b", address - 1,	testvectors[address - 1][20:18],
								registers[testvectors[address - 1][20:18]],	testvectors[address - 1][8:0]);
							errorCount = errorCount + 1;
							if(errorCount > 5)
								$stop;
						end  // if error

	
	end // always
	
	always@(negedge clock)
		begin
			
			if(testvectors[address][30:27] == 15)  // HALT		
				begin
					$display("Error count: %d", errorCount);
					if(errorCount == 0)
						$display("Congratulations!  No Errors!");
					$stop;
				end  // if HALT
		end // always
endmodule


module testbenchALU();
	logic [8:0] a, b, result, out;
	integer i;
	logic [3:0] opcode = 0; 
	ALU alu(out, a, b, opcode);
	logic[30:0] testvectors[10000:0];
	initial 
		begin
			$readmemb("alu_test.txt", testvectors);
			for(i = 0; i < 10000; i++)
				begin
					opcode = testvectors[i][30:27];
					a = testvectors[i][26:18];
					b = testvectors[i][17:9];
					result = testvectors[i][8:0];
				
					#1 assert(result == out)
						else 
							begin
								$error("Output of ALU was not correct for opcode: %d a: %b b: %b yours: %b  correct: %b ",  opcode, a, b, out, result);
								$stop;
							end;
					end // for i
		
			$display("Everything worked!");
			$stop;
		end // initial
endmodule



module testbenchCLA();
	logic [2:0] ps, gs, carries, calcCarries;
	bit [3:0] a, b;
	logic [1:0] cin, x;
	logic cout, c4;
	CLA cla(carries, cout, ps, gs, cin[0]);
	initial 
		begin
			for(a = 0; a < 8; a = a + 1)
				for(b = 0; b < 8; b = b + 1)
					for(cin = 0; cin < 2; cin = cin + 1)
					begin
						calcCarries[0] = cin[0];
						gs = a[2:0] & b[2:0];
						ps = a[2:0] ^ b[2:0];	
						x = a[0] + b[0] + calcCarries[0];
						calcCarries[1] = x[1];
						x = a[1] + b[1] + calcCarries[1];
						calcCarries[2] = x[1];
						x = a[2] + b[2] + calcCarries[2];
						c4 = x[1];
						#1 assert(calcCarries == carries)
							else
								begin
					  			$display("Output of CLA was not correct for a = %b, b = %b, and cin = %b,  %b should be %b ", 
										a[2:0], b[2:0], cin[0], carries, calcCarries);
									$stop;
								end
						
						assert(c4 == cout)
							else
								begin
									$display("Output of CLA was not correct for a = %b, b = %b, and cin = %b,  cout = %b should be %b ", 
										a[2:0], b[2:0], cin[0], cout, c4);
									$stop;
								end
					end // for cin
			$display("No errors found!");
		end // initial
endmodule
