module LCD_module(
	input rst,
	input clk,
	input[16*8-1:0] rowA,
	input[16*8-1:0] rowB,
	output LCD_E,
	output LCD_RS,
	output LCD_RW,
	output[3:0] LCD_D
);
	reg inited;
	reg init_e,init_rs,init_rw;
	reg text_e,text_rs,text_rw;
	reg[3:0] init_d,text_d;
	wire[6:0] tCnt;
	reg[30:0] init_cnt,text_cnt;
	reg[3:0] icode,tcode;

	assign tCnt=text_cnt[23:17];
	assign LCD_E=inited?text_e:init_e;
	assign LCD_RS=inited?text_rs:init_rs;
	assign LCD_RW=inited?text_rw:init_rw;
	assign LCD_D=inited?text_d:init_d;
	
	wire [12*4-1:0] cmdLine=48'h333228060c01;
	
	always@(posedge clk,posedge rst)
		if(rst)begin
			init_e<=0;
			init_rs<=0;
			init_rw<=1;
			inited<=0;
			init_d<=0;
			init_cnt<=0;
			icode<=0;
		end else if(!inited)begin
			init_rs<=0;
			init_rw<=0;
			init_e<=init_cnt[19];
			init_cnt<=(init_cnt[23:20]<12)?init_cnt+1:init_cnt;
			init_d<=icode;
			/*if(init_cnt[23:20]<12)
				icode<={3'b0,cmdLine[(11-init_cnt[23:20])*4+:1]};
			else
				{init_rw,inited}<=2'b11;*/
			case(init_cnt[23:20])
			0:icode<=4'h3;
			1:icode<=4'h3;
			2:icode<=4'h3;
			3:icode<=4'h2;

			4:icode<=4'h2;
			5:icode<=4'h8;

			6:icode<=4'h0;
			7:icode<=4'h6;

			8:icode<=4'h0;
			9:icode<=4'hC;
			10:icode<=4'h0;
			11:icode<=4'h1;
			default:
			{init_rw,inited}<=2'b11;
			endcase
		end
	
	always@(posedge clk, posedge rst)
		if(rst)begin
			text_e<=0;
			text_rs<=0;
			text_rw<=0;
			text_d<=0;
			text_cnt<=0;
			tcode<=0;
		end else if(inited)begin
			text_rs<=1;
			text_rw<=0;
			text_e<=text_cnt[16];
			text_cnt<=(text_cnt[23:17]<68)?text_cnt+1:0;
			text_d<=tcode;
			if(tCnt==0)
				{text_rs,text_rw,tcode}<=6'b001000;
			else if(tCnt==1)
				{text_rs,text_rw,tcode}<=0;
			else if(tCnt<2+32)
				tcode<=rowA[(33-tCnt)*4+:4];
			else if(tCnt==2+32+0)
				{text_rs,text_rw,tcode}<=6'b001100;
			else if(tCnt==2+32+1)
				{text_rs,text_rw,tcode}<=0;
			else if(tCnt<2+32+2+32)
				tcode<=rowB[(67-tCnt)*4+:4];
			else
				{text_rs,text_rw,tcode}<=6'b010000;
		end
endmodule