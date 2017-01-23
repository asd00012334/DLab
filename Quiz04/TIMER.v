module TIMER(
	input clk,
	input BTN_SOUTH,
	input BTN_WEST,
	input BTN_NORTH,
	input BTN_EAST,
	input[3:0] SW,
	output [7:0] LED,
	output LCD_E,
	output LCD_RS,
	output LCD_RW,
	output[3:0] LCD_D
);
	parameter mili=50000;
	parameter sec=1000*mili;
	reg[16*8-1:0] rowA,rowB;
	reg isOver;
	wire rst=BTN_SOUTH;
	wire[1:0] stat;
	wire dec,inc;
	LCD_module lcd(
		.rst(BTN_SOUTH),
		.clk(clk),
		.LCD_E(LCD_E),
		.LCD_RS(LCD_RS),
		.LCD_RW(LCD_RW),
		.LCD_D(LCD_D),
		.rowA(rowA),
		.rowB(rowB)
	);
	
	BTN_ctrl btn(
		.clk(clk),
		.BTN_SOUTH(BTN_SOUTH),
		.BTN_NORTH(BTN_NORTH),
		.BTN_WEST(BTN_WEST),
		.BTN_EAST(BTN_EAST),
		.stat(stat),
		.dec(dec),
		.inc(inc)
	);

	LED_ctrl LED_control(
	.clk(clk),
	.rst(rst),
	.LED(LED),
	.isOver(isOver)
	);
	reg[127:0] origLine;
	reg[3:0] minA,minB,secA,secB;
	wire[7:0] zero="0";
	
	integer cnt;
	always@(posedge clk, posedge rst)
		if(rst)begin
			rowA<={16{" "}};
			rowB<={16{" "}};
			cnt<=0;
			{minA,minB,secA,secB}<=0;
			isOver<=0;
		end else begin
			case(stat)
			0:begin
				origLine<={"TIME ",zero+minA,zero+minB,":",zero+secA,zero+secB,{6{" "}}};
				case(SW)
				4'b0001:begin
					if(secB+inc-dec==10) secB<=0;
					else if(secB+inc-dec>9)secB<=9;
					else secB<=secB+inc-dec;
				end 4'b0010:begin
					if(secA+inc-dec==6) secA<=0;
					else if(secA+inc-dec>5)secA<=5;
					else secA<=secA+inc-dec;
				end 4'b0100:begin
					if(minB+inc-dec==10) minB<=0;
					else if(minB+inc-dec>9)minB<=9;
					else minB<=minB+inc-dec;
				end 4'b1000:begin
					if(minA+inc-dec==6) minA<=0;
					else if(minA+inc-dec>5)minA<=5;
					else minA<=minA+inc-dec;
				end 4'b0000: {minA,minB,secA,secB}<={minA,minB,secA,secB};
				default: {minA,minB,secA,secB}<={minA,minB,secA,secB}; 
				endcase
			end 1:begin
				rowB<=origLine;
				if(cnt<sec)cnt<=cnt+1;
				else begin
					cnt<=0;
					if(&{!minA,!minB,!secA,!secB}) isOver<=1;
					else if(secB>0) secB<=secB-1;
					else begin
						secB<=9;
						if(secA>0) secA<=secA-1;
						else begin
							secA<=5;
							if(minB>0) minB<=minB-1;
							else begin
								minB<=9;
								minA<=minA-1;
							end
						end
					end
				end
			end default: begin
				/*{minA,minB,secA,secB}<={minA,minB,secA,secB};
				cnt<=cnt;*/
			end endcase
			rowA[127:8*11]<={zero+minA,zero+minB,":",zero+secA,zero+secB};
			if(isOver)begin
				if(cnt<500*mili)begin
					rowA[8*11-1:0]<={11{" "}};
					cnt<=cnt+1;
				end else if(cnt<sec)begin
					rowA[8*11-1:0]<=" Time's UP!";
					cnt<=cnt+1;
				end else cnt<=0;
			end else if(secB!=5&&secB!=0)
				rowA[8*11-1:0]<={11{" "}};
			else
				rowA[8*11-1:0]<="FIVE <3 OWO";
			
			
		end
endmodule
