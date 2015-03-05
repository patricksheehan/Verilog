module cpu(input clock);
	// bus declarations
	logic reset;
	logic [9:0] pc_address;
	logic [21:0] ram_out;
	logic [6:0] decoder_RB;
	logic [6:0][8:0] register_bus;
	logic [8:0] muxA_ALU, muxB_ALU;
	logic [8:0] ALU_RB;
	// end bus declarations

	logic [2:0] b_select;
	logic [6:0] hot_reg;
	logic myclock;

	pc 					pc1(myclock,reset,pc_address,ram_out[21:18]);
	RAM_Test		ram1(ram_out,reset,pc_address, register_bus, myclock);
	decoder		  dec1(ram_out[11:9],decoder_RB);
	
	always_comb	
		if(ram_out[21:18] == 4'b1011) hot_reg = 7'b0;
		else													hot_reg = decoder_RB;
	always_comb
		if(ram_out[21:18] == 4'b1000 ||
			 ram_out[21:18] == 4'b1001 ||
			 ram_out[21:18] == 4'b1010) b_select = 3'b111;
		else													b_select = ram_out[14:12];
	always_comb
		if(ram_out[21:18] == 4'b1111) myclock = 1'b0;
		else													myclock = clock;

	

	regbank			rb1	(myclock,hot_reg, ALU_RB, register_bus);
	mux8	#(9)	muxa(register_bus[0],
									 register_bus[1],
									 register_bus[2],
									 register_bus[3],
									 register_bus[4],
									 register_bus[5],
									 register_bus[6],
									 9'bz, // should never get this selected via muxa
									 ram_out[17:15],
									 muxA_ALU);
	mux8	#(9)	muxb(register_bus[0],
									 register_bus[1],
									 register_bus[2],
									 register_bus[3],
									 register_bus[4],
									 register_bus[5],
									 register_bus[6],
									 ram_out[8:0], // for immediate mode
									 b_select,
									 muxB_ALU);
	ALU					alu1(ALU_RB, muxA_ALU, muxB_ALU, ram_out[21:18]);
endmodule

module pc(input 				clock,
				  input logic 	reset,
					output logic [9:0]	address,
					input logic [3:0] opcode);

				always_ff @(posedge clock, reset)
						if(reset) address <= 10'b0;
						else address <= address + 1;
endmodule

module decoder(input logic [2:0] regnum,
							 output logic [6:0] regbit);

		always_comb
			case (regnum)
				0:	regbit =   7'b0000001;
				1:	regbit =   7'b0000010;
				2:	regbit =   7'b0000100;
				3:	regbit =   7'b0001000;
				4:	regbit =   7'b0010000; 
				5:	regbit =   7'b0100000; 
				6:	regbit =   7'b1000000;
				default: regbit  = 7'bz;
			endcase

endmodule

module regbank(input 						 clock,
							 input logic [6:0] enable,
							 input [8:0]			 write,
				output logic [6:0][8:0]  register_bus);

		always_ff @ (negedge clock)
			begin
				if		 (enable == 7'b0000001) register_bus[0] <= write;
				else if(enable == 7'b0000010) register_bus[1] <= write; 
				else if(enable == 7'b0000100) register_bus[2] <= write;
				else if(enable == 7'b0001000) register_bus[3] <= write;
				else if(enable == 7'b0010000) register_bus[4] <= write;
				else if(enable == 7'b0100000) register_bus[5] <= write;
				else if(enable == 7'b1000000) register_bus[6] <= write;
				else;
			end

endmodule

module mux8 
	#(parameter width = 4)
	(input logic [width-1:0] d0, d1, d2, d3, d4, d5, d6, d7,
	 input logic [2:0] 				s, 
	 output logic [width-1:0] y);
		
	   always_comb
			case(s)
						0:	y = d0;
						1:	y = d1;
						2:	y = d2;
						3:	y = d3;
						4:	y = d4;
						5:	y = d5;
						6:	y = d6;
						7:	y = d7;
			endcase
endmodule
