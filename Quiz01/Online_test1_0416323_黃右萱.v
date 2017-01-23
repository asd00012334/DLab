module Online_test1(out, out_valid, clk, rst_n, in, in_valid, in_mode);
	input clk,rst_n,in_valid,in_mode;
	input [15:0] in;
	output reg out_valid;
	output reg[35:0] out;
	reg[5:0] inCnt,outCnt;
	reg mode;
	
	wire[35:0] out0[0:2];
	wire[3:0] out1[0:2];
	
	
	
	//Counting and Interface
	always@(posedge clk)begin
		if(rst_n)begin
			out=0;
			inCnt=63;// 63 means -1
			outCnt=63;// 63 means -1
			out_valid=0;
		end else if(in_valid) begin
			if(inCnt==63) mode = in_mode;
			inCnt = inCnt+1;
		end else if(inCnt!=63&&outCnt==63)begin
			inCnt=63;
			outCnt=outCnt+1;
			out_valid=1;
			if(mode==0) out=out0[outCnt];
			else out={32'b0,out1[outCnt]};
			outCnt=outCnt+1;
		end else if(out_valid&&outCnt<3)begin
			if(mode==0) out=out0[outCnt];
			else out={32'b0,out1[outCnt]};
			outCnt=outCnt+1;
		end else if(out_valid&&outCnt==3)begin
			out_valid=0;
			out=0;
			inCnt=63;
			outCnt=63;
			mode=0;
		end
		
	end


	// For mode 0----------------------------------------------------
	reg signed[7:0] Ar0[0:1];
	reg signed[7:0] Ai0[0:1];
	reg signed[7:0] Br0[0:1];
	reg signed[7:0] Bi0[0:1];
	wire signed[17:0] outR0[0:2];
	wire signed[17:0] outI0[0:2];
	
	wire[7:0] obs0,obs1,obs2,obs3;
	assign obs0=Ai0[0];
	assign obs1=Ai0[1];
	assign obs2=Bi0[0];
	assign obs3=Bi0[1];
	
	// Real calc of mode 0
	assign outR0[0]=Ar0[0]*Br0[0]+Ai0[0]*Bi0[0];
	assign outR0[1]=
		Ar0[0]*Br0[1]+Ai0[0]*Bi0[1]+
		Ar0[1]*Br0[0]+Ai0[1]*Bi0[0];
	assign outR0[2]=Ar0[1]*Br0[1]+Ai0[1]*Bi0[1];

	// Imag calc of mode 0
	assign outI0[0]=Ar0[0]*Bi0[0]-Ai0[0]*Br0[0];
	assign outI0[1]=
		Ar0[0]*Bi0[1]-Ai0[0]*Br0[1]+
		Ar0[1]*Bi0[0]-Ai0[1]*Br0[0];
	assign outI0[2]=Ar0[1]*Bi0[1]-Ai0[1]*Br0[1];

	// Result Formalize
	assign out0[0]={outR0[0],outI0[0]};
	assign out0[1]={outR0[1],outI0[1]};
	assign out0[2]={outR0[2],outI0[2]};

	// Input of mode 0
	always@(inCnt)begin
		if(in_valid)begin
			if(inCnt<=1)begin // Get A
				Ar0[inCnt]=in[15:8];
				Ai0[inCnt]=in[7:0];
			end else begin // Get B
				Br0[inCnt-2]=in[15:8];
				Bi0[inCnt-2]=in[7:0];
			end
		end
	end


	// For mode 1----------------------------------------------------
	reg[3:0] max, min;

	// Result Formalize
	assign out1[0]=max;
	assign out1[1]=min;
	assign out1[2]=max-min;

	always@(posedge clk)begin //For max and min
		if(rst_n)begin // reset
			max=0;
			min=15;
		end else if(in_valid)begin // For input and update of max and min
			
			if(in[3:0]<min) min=in[3:0];
			if(in[7:4]<min) min=in[7:4];
			if(in[11:8]<min) min=in[11:8];
			if(in[15:12]<min) min=in[15:12];
			if(in[3:0]>max) max=in[3:0];
			if(in[7:4]>max) max=in[7:4];
			if(in[11:8]>max) max=in[11:8];
			if(in[15:12]>max) max=in[15:12];
			
		end else if(outCnt==3)begin
			max=0;
			min=15;
		end
	end
	
endmodule
