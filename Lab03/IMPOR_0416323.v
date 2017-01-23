module IMPOR(
	output reg  [2:0] out,
	output reg out_valid,
	output reg ready,
	input  [2:0] in,
	input  [2:0] mode,
	input  in_valid,
	input  clk,
	input  rst_n
);
	reg[26:0] state;
	reg[5:0] inCnt,transCnt;
	wire[26:0] out1,out2,out3,out4,out5,out6,out7;
	calc1 a1(out1,state);
	calc2 a2(out2,state);
	calc3 a3(out3,state);
	calc4 a4(out4,state);
	calc5 a5(out5,state);
	calc6 a6(out6,state);
	calc7 a7(out7,state);

	always@(posedge clk, negedge rst_n) // ready
		if(!rst_n) ready<=0;
		else if(!out_valid&&(!inCnt||inCnt&&in_valid)) ready<=1;
		else ready<=0;
	
	always@(posedge clk, negedge rst_n) //inCnt
		if(!rst_n) inCnt<=0;
		else if(in_valid) inCnt<=inCnt+1;
		else inCnt<=0;
	
	always@(posedge clk, negedge rst_n) // transCnt
		if(!rst_n) transCnt<=0;
		else if(inCnt>=9&&!mode||transCnt&&state) transCnt<=1;
		else transCnt<=0;
	
	always@(posedge clk, negedge rst_n) // out_valid
		if(!rst_n) out_valid<=0;
		else if(transCnt) out_valid<=1;
		else out_valid<=0;
	
	always@(posedge clk, negedge rst_n) // state
		if(!rst_n) state<=0;
		else if(inCnt<9&&in_valid)
			state<={in,state[26:3]};
		else if(in_valid)
			case(mode)
			1:state<=out1;
			2:state<=out2;
			3:state<=out3;
			4:state<=out4;
			5:state<=out5;
			6:state<=out6;
			7:state<=out7;
			default:state<=state;
			endcase
		else if(transCnt)
			state<={3'b0,state[26:3]};
		else state<=0;
		
	always@(posedge clk, negedge rst_n) // out
		if(!rst_n) out<=0;
		else if(transCnt) out<=state[2:0]; // inArr = {inArr[23:0], in};
		else out<=0;
	
endmodule

// for 9 array
/*
	[2:0]:   1		[20:18]: 7
	[5:3]:   2		[23:21]: 8
	[8:6]:   3		[26:24]: 9
	[11:9]:  4
	[14:12]: 5		
	[17:15]: 6		
	
*/

module calc1(
	output[26:0] out,
	input[26:0] in
	
);
	assign out[2:0]=in[8:6];
	assign out[8:6]=in[2:0];
	assign out[11:9]=in[17:15];
	assign out[17:15]=in[11:9];
	assign out[20:18]=in[26:24];
	assign out[26:24]=in[20:18];
	assign out[5:3]=in[5:3];
	assign out[14:12]=in[14:12];
	assign out[23:21]=in[23:21];
endmodule

module calc2(
	output [26:0] out,
	input[26:0] in
);
	assign out[2:0]=in[20:18];
	assign out[5:3]=in[23:21];
	assign out[8:6]=in[26:24];
	assign out[11:9]=in[11:9];
	assign out[14:12]=in[14:12];
	assign out[17:15]=in[17:15];
	assign out[20:18]=in[2:0];
	assign out[23:21]=in[5:3];
	assign out[26:24]=in[8:6];	
endmodule

module calc3(
	output[26:0] out,
	input[26:0] in
);
	assign out[2:0]=in[8:6];
	assign out[5:3]=in[17:15];
	assign out[8:6]=in[26:24];
	assign out[11:9]=in[5:3];
	assign out[14:12]=in[14:12];
	assign out[17:15]=in[23:21];
	assign out[20:18]=in[2:0];
	assign out[23:21]=in[11:9];
	assign out[26:24]=in[20:18];
endmodule

module calc4(
	output[26:0] out,
	input[26:0] in
);
	assign out[2:0]=in[20:18];
	assign out[5:3]=in[11:9];
	assign out[8:6]=in[2:0];
	assign out[11:9]=in[23:21];
	assign out[14:12]=in[14:12];
	assign out[17:15]=in[5:3];
	assign out[20:18]=in[26:24];
	assign out[23:21]=in[17:15];
	assign out[26:24]=in[8:6];
endmodule

module calc5(
	output[26:0] out,
	input[26:0] in
);
	assign out[2:0]=(in[2:0]==7)?7:(in[2:0]+1);
	assign out[5:3]=in[5:3];
	assign out[8:6]=in[8:6];
	assign out[11:9]=(in[11:9]==7)?7:(in[11:9]+1);
	assign out[14:12]=in[14:12];
	assign out[17:15]=in[17:15];
	assign out[20:18]=(in[20:18]==7)?7:(in[20:18]+1);
	assign out[23:21]=in[23:21];
	assign out[26:24]=in[26:24];								   
endmodule

module calc6(
	output[26:0] out,
	input[26:0] in
);
	assign out[2:0]=in[2:0];
	assign out[5:3]=(in[5:3]==7)?7:(in[5:3]+1);
	assign out[8:6]=in[8:6];
	assign out[11:9]=in[11:9];
	assign out[14:12]=(in[14:12]==7)?7:(in[14:12]+1);
	assign out[17:15]=in[17:15];
	assign out[20:18]=in[20:18];
	assign out[23:21]=(in[23:21]==7)?7:(in[23:21]+1);
	assign out[26:24]=in[26:24];
endmodule

module calc7(
	output[26:0] out,
	input[26:0] in
);
	assign out[2:0]=in[2:0];
	assign out[5:3]=in[5:3];
	assign out[8:6]=(in[8:6]==7)?7:(in[8:6]+1);
	assign out[11:9]=in[11:9];
	assign out[14:12]=in[14:12];
	assign out[17:15]=(in[17:15]==7)?7:(in[17:15]+1);
	assign out[20:18]=in[20:18];
	assign out[23:21]=in[23:21];
	assign out[26:24]=(in[26:24]==7)?7:(in[26:24]+1);
endmodule

