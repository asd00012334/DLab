module SORT(
	// Input signals
	input clk,
	input rst_n,
	input in_valid1,
	input in_valid2,
	input[4:0] in,
	input mode,
	input[1:0] op,
	// Output signals
	output reg out_valid,
	output reg[4:0] out
);
	wire[4:0] stkTop,queTop;
	wire[54:0] stkRaw,queRaw,outRaw,outRawMask;
	wire[1:0] opStk,opQue;
	wire[4:0] max;
	wire[9:0] maxLocation;
	reg modeReg;
	reg[3:0] outCnt;
	reg[54:0] outReg;
	integer cnt;
	wire containerRst_n;
	assign containerRst_n=rst_n&&!(out_valid&&outCnt==1);
	
	assign outRaw=(out_valid?outReg:(modeReg?queRaw:stkRaw));
	assign opStk=(in_valid1&&modeReg==0)?op:2;
	assign opQue=(in_valid1&&modeReg==1)?op:2;
	Stack stk(clk,opStk,in,containerRst_n,stkTop,stkRaw);
	Queue que(clk,opQue,in,containerRst_n,queTop,queRaw);
	MaxFind kernel(outRaw,max,maxLocation);
	BitMask mask(maxLocation,maxLocation,outRaw,outRawMask);
	always@(posedge clk, negedge rst_n)begin
		if(!rst_n)begin
			out_valid<=0;
			out<=0;
			outCnt<=0;
			outReg<=0;
		end else if(in_valid2)
			modeReg<=mode;
		else if(in_valid1&&op==2)begin
			out<=max;
			outReg<=outRawMask;
			outCnt<=1;
			out_valid<=1;
		end else if(outCnt&&outCnt<10)begin
			out<=max;
			outReg[maxLocation*5+:5]<=0;
			out<=max;
			outCnt<=outCnt+1;
		end else if(outCnt==10)begin
			out_valid<=0;
			out<=0;
			outCnt<=0;
			outReg<=0;
		end
	end
	
endmodule

module BitMask(
	input[9:0] lower,
	input[9:0] upper,
	input[54:0] in,
	output[54:0] out
);
	genvar cnt;
	generate
		for(cnt=0;cnt<=54;cnt=cnt+1)begin:a
			assign out[cnt]=(lower*5<=cnt&&cnt<upper*5+5)?0:in[cnt];
		end
	endgenerate
	
endmodule

module MaxFind(
	input[11*5-1:0] in,
	output[4:0] out,
	output[9:0] idx
);
	wire[4:0] a,b,c,d,e,f,g,h,i,j;
	wire[9:0] A,B,C,D,E,F,G,H,I,J;
	assign {a,b,c,d,e}={
		in[0 +:5]>in[1*5+:5]?in[0+:5]:in[1*5+:5],
		in[2*5+:5]>in[3*5+:5]?in[2*5+:5]:in[3*5+:5],
		in[4*5+:5]>in[5*5+:5]?in[4*5+:5]:in[5*5+:5],
		in[6*5+:5]>in[7*5+:5]?in[6*5+:5]:in[7*5+:5],
		in[8*5+:5]>in[9*5+:5]?in[8*5+:5]:in[9*5+:5]
	};
	assign {A,B,C,D,E}={
		in[0+:5]>in[1*5+:5]?10'b0:10'b1,
		in[2*5+:5]>in[3*5+:5]?10'b10:10'b11,
		in[4*5+:5]>in[5*5+:5]?10'b100:10'b101,
		in[6*5+:5]>in[7*5+:5]?10'b110:10'b111,
		in[8*5+:5]>in[9*5+:5]?10'b1000:10'b1001
	};
	assign {f,g,h,i,j}={
		a>b?a:b,
		c>d?c:d,
		e>in[10*5+:5]?e:in[10*5+:5],
		f>g?f:g,
		i>h?i:h
	};
	assign {F,G,H,I,J}={
		a>b?A:B,
		c>d?C:D,
		e>in[10*5+:5]?E:10'b1010,
		f>g?F:G,
		i>h?I:H
	};
	assign out=j;
	assign idx=J;

endmodule



module Stack(
	input clk,
	input[1:0] mode,
	input[4:0] in,
	input rst_n,
	output[4:0] top,
	output reg[54:0] data
);
	// Idle: 2,3
	// Push: 1
	// Pop:  0
	assign top=data[4:0];	
	always@(posedge clk, negedge rst_n)begin
		if(!rst_n) data<=0;
		else case(mode)
		0: data<={5'b0,data[54:5]};
		1: data<={data[49:0],in};
		default: data<=data;
		endcase
	end
endmodule

module Queue(
	input clk,
	input[1:0] mode,
	input[4:0] in,
	input rst_n,
	output[4:0] top,
	output reg[54:0]data
);
	// Idle: 2,3
	// Push: 1
	// Pop:  0
	reg[8:0] size;
	assign top=data[4:0];
	
	always@(posedge clk, negedge rst_n)begin
		if(!rst_n)begin
			data<=0;
			size<=0;
		end else case(mode)
		0:begin
			data<={5'b0,data[54:5]};
			size<=size-5;
		end 1:begin
			data[size+:5]<=in;
			size<=size+5;
		end default:begin
			data<=data;
			size<=size;
		end
		endcase
	end
endmodule