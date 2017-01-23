module OT11_28(
	input clk,
	input rst_n,
	input in_valid,
	input[5:0] in_real,
	input[5:0] in_image,
    output reg out_valid,
	output reg[13:0] out_real,
	output reg[13:0] out_image
);
	parameter sortLatency=20,productLatency=20;
	reg[3*3*14-1:0] Ar,Ai,Br,Bi,Cr,Ci;
	reg[3*14-1:0] maxReal,maxImage;
	reg trigSortReal,trigSortImage,trigProduct;
	wire[3*14-1:0] maxRealRaw,maxImageRaw;
	wire[3*3*14-1:0] prodRealRaw,prodImageRaw;
	SortKernel Sr(clk,rst_n,trigSortReal,Cr,maxRealRaw);
	SortKernel Si(clk,rst_n,trigSortImage,Ci,maxImageRaw);
	ProductKernel prod(clk,rst_n,trigProduct,Ar,Ai,Br,Bi,prodRealRaw,prodImageRaw);
	
	reg[5:0] inCnt,outCnt;
	always@(posedge clk, negedge rst_n)begin
		if(!rst_n)
			{trigProduct,trigSortReal,trigSortImage,inCnt,outCnt,Ar,Ai,Br,Bi,Cr,Ci,out_valid,out_real,out_image}<=0;
		else if(in_valid)begin
			inCnt<=inCnt+1;
			if(inCnt<9)begin
				Ar[0+:14]<={{8{in_real[5]}},in_real};
				Ai[0+:14]<={{8{in_image[5]}},in_image};
				Ar[3*3*14-1:14]<=Ar[3*3*14-14-1:0];
				Ai[3*3*14-1:14]<=Ai[3*3*14-14-1:0];
			end else begin
				Br[0+:14]<={{8{in_real[5]}},in_real};
				Bi[0+:14]<={{8{in_image[5]}},in_image};
				Br[3*3*14-1:14]<=Br[3*3*14-14-1:0];
				Bi[3*3*14-1:14]<=Bi[3*3*14-14-1:0];
			end
		end else if(inCnt<9+9)
			inCnt<=inCnt;
		else if(inCnt<=9+9+productLatency+sortLatency)begin
			if(inCnt==9+9)
				trigProduct<=1;
			else if(inCnt<9+9+productLatency)
				trigProduct<=0;
			else if(inCnt==9+9+productLatency)begin
				Cr<=prodRealRaw;
				Ci<=prodImageRaw;
				trigSortReal<=1;
				trigSortImage<=1;
			end else begin
				trigSortReal<=0;
				trigSortImage<=0;
			end
			inCnt<=inCnt+1;
			maxReal<=maxRealRaw;
			maxImage<=maxImageRaw;
		end else if(inCnt>9+9+productLatency+sortLatency&&outCnt<3)begin
			out_valid<=1;
			outCnt<=outCnt+1;
			out_real<=maxReal[13:0];
			out_image<=maxImage[13:0];
			maxReal<={14'b0,maxReal[3*14-1:14]};
			maxImage<={14'b0,maxImage[3*14-1:14]};
		end else 
			{trigProduct,trigSortReal,trigSortImage,inCnt,outCnt,Ar,Ai,Br,Bi,Cr,Ci,out_valid,out_real,out_image}<=0;

	end
endmodule

module SortKernel(
	input clk,
	input rst_n,
	input in_valid,
	input[3*3*14-1:0] in,
	output[3*14-1:0] out
);
	reg[3*3*14-1:0] arr;
	reg odd;
	integer cnt;
	assign out=arr[14*3-1:0];
	always@(posedge clk,negedge rst_n)
		if(!rst_n){arr,odd}<=0;
		else if(in_valid)begin
			odd<=0;
			arr<=in;
		end else begin
			for(cnt=odd;cnt<=6+odd;cnt=cnt+2)begin
				if(~arr[cnt*14+13]&&~arr[(cnt+1)*14+13])
					if(arr[cnt*14+:14]<arr[(cnt+1)*14+:14])
						{arr[cnt*14+:14],arr[(cnt+1)*14+:14]}<={arr[(cnt+1)*14+:14],arr[cnt*14+:14]};
					else {arr[cnt*14+:14],arr[(cnt+1)*14+:14]}<={arr[cnt*14+:14],arr[(cnt+1)*14+:14]};
				else if(~arr[(cnt+1)*14+13])
					{arr[cnt*14+:14],arr[(cnt+1)*14+:14]}<={arr[(cnt+1)*14+:14],arr[cnt*14+:14]};
				else {arr[cnt*14+:14],arr[(cnt+1)*14+:14]}<={arr[cnt*14+:14],arr[(cnt+1)*14+:14]};
			end
			odd=~odd;
		end
endmodule

module ProductKernel(
	input clk,
	input rst_n,
	input in_valid,
	input[3*3*14-1:0] ar,
	input[3*3*14-1:0] ai,
	input[3*3*14-1:0] br,
	input[3*3*14-1:0] bi,
	output reg[3*3*14-1:0] Cr,
	output reg[3*3*14-1:0] Ci
);
	integer row,col,cnt;
	reg[3*3*14-1:0] Ar,Ai,Br,Bi;
	always@(posedge clk,negedge rst_n)
		if(!rst_n)begin
			cnt<=0;
			{Cr,Ci}<=0;
			{Ar,Ai,Br,Bi}<=0;
		end else if(in_valid)begin
			cnt<=0;
			{Cr,Ci}<=0;
			{Ar,Ai,Br,Bi}<={ar,ai,br,bi};
		end else if(cnt<3) begin
			cnt<=cnt+1;
			for(row=0;row<3;row=row+1)
			for(col=0;col<3;col=col+1)begin
				Cr[(row*3+col)*14+:14]<=Cr[(row*3+col)*14+:14]+(
					Ar[(row*3+cnt)*14+:14]*Br[(cnt*3+col)*14+:14]
					-Ai[(row*3+cnt)*14+:14]*Bi[(cnt*3+col)*14+:14]
				);
				Ci[(row*3+col)*14+:14]<=Ci[(row*3+col)*14+:14]+(
					Ar[(row*3+cnt)*14+:14]*Bi[(cnt*3+col)*14+:14]
					+Ai[(row*3+cnt)*14+:14]*Br[(cnt*3+col)*14+:14]
				);
			end //A[row][cnt]*B[cnt][col]
		end else cnt<=cnt;
endmodule




