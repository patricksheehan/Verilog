module ALU(output logic [8:0] out,
				   input logic	[8:0] a, b,
					 input logic 	[3:0] opcode);

	logic [8:0] add_ab, sub_ab;
	add add1(a,b,add_ab);
	subtract sub1(a,b,sub_ab);

	always_comb
		case(opcode)
				4'b0000:	out = a & b; //AND
				4'b0001:	out = a | b; //OR
				4'b0010:	out = ~a;		 //NOT (a)
				4'b0011:	out = add_ab;//ADD
				4'b0100:	out = a;		 //MOV
				4'b0101:	out = a << 1;
				4'b0110:	out = a >> 1;
				4'b0111:	out = sub_ab;
				4'b1000:	out = add_ab;
				4'b1001:  out = sub_ab;
				4'b1010:  out = b;
				4'b1011:  out = out;
				default:	out = 9'bx;
		endcase
			
endmodule

module subtract(input logic [8:0] a, b,
								output logic [8:0] out);
		logic[8:0] two_comp;
		assign two_comp = ~b + 1;
		add subadd(a,two_comp,out);
		
endmodule

module add(input logic [8:0] a, b,
					 output logic [8:0] out);

		logic [2:0]cout;

		add3 myAdd1(a[2:0],b[2:0],1'b0,cout[0],out[2:0]);
		add3 myAdd2(a[5:3],b[5:3],cout[0],cout[1],out[5:3]);
		add3 myAdd3(a[8:6],b[8:6],cout[1],cout[2],out[8:6]);

endmodule

module add3(input logic [2:0] a, b,
						input logic cin,
						output logic cout,
						output logic [2:0] out);

		logic [2:0] ps, gs, carries;
		assign ps = a ^ b;
		assign gs = a & b;
		
		CLA myCLA(carries,cout,ps,gs,cin);

		assign out = a ^ b ^ carries;
endmodule

module CLA(output logic [2:0] carries,
					 output logic 			cout,
					 input logic	[2:0] ps, gs,
					 input cin);

				assign carries[0] = cin;
				assign carries[1] = (ps[0] & cin) | gs[0];
				assign carries[2] = gs[1] | (ps[1] & ((ps[0] & cin) | gs[0]));
				assign cout = gs[2] | (ps[2] & (gs[1] | (ps[1] & ((ps[0] & cin) | gs[0]))));

endmodule
