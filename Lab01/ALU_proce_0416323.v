module ALU(OUT,A,B,MODE);
	input [3:0] A,B;
	input [1:0] MODE;
	output reg [7:0] OUT;
	always@(*)
		if(0==MODE)
			OUT = {4'b0,A}+{4'b0,B};
		else if(1==MODE)
			OUT=A&B;
		else if(2==MODE)
			OUT=A>B?1:0;
		else if(3==MODE)
			OUT=A>>B;
endmodule