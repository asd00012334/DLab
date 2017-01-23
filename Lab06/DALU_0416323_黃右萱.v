module DALU(
	input clk,
	input rst,
	input[18:0] instruction,
	input in_valid,
	output reg[15:0] out,
	output reg out_valid
);
	wire signed[2:0] pre;
	wire signed[3:0] post;
	wire signed[5:0] s,t;
	wire signed[9:0] i;
	reg signed[15:0] outReg;
	reg trans;
	assign {pre,s,t,post}=instruction;
	assign i={t,post};
	always@(posedge clk)begin
		if(rst)begin
			out<=0;
			out_valid<=0;
			trans<=0;
		end else if(in_valid)begin
			trans<=1;
			if(!pre)case(post)
			0:outReg<=s&t;
			1:outReg<=s|t;
			2:outReg<=s^t;
			3:outReg<=s+t;
			default:outReg<=s-t;
			endcase else case(pre)
			1:outReg<=s*t*post;
			2:outReg<=(s+t+post)*(s+t+post);
			3:outReg<=s+i;
			default:outReg<=s-i;
			endcase
		end else if(trans) begin
			out<=outReg;
			out_valid<=1;
			trans<=0;
		end else begin
			out<=0;
			out_valid<=0;
		end
	end
endmodule
