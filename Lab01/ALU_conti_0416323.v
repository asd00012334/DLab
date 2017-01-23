module ALU(OUT,A,B,MODE);
	input[3:0] A,B;
	input[1:0] MODE;
	output[7:0] OUT;
	assign OUT =
		(0==MODE?~0:0)&({4'b0,A}+{4'b0,B})|
		(1==MODE?~0:0)&(A&B)|
		(2==MODE?~0:0)&(A>B?1:0)|
		(3==MODE?~0:0)&(A>>B);
endmodule