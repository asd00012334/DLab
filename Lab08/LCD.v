module LCD(
	input clk,
	input BTN_SOUTH,
	input BTN_WEST,
	input BTN_NORTH,
	input BTN_EAST,
	input[3:0] SW,
	output[7:0] LED,
	output LCD_E,
	output LCD_RS,
	output LCD_RW,
	output[3:0] LCD_D
);
	integer cnt;
	reg[5:0] Apos, Bpos;
	wire[62*8-1:0] buffA,buffB;
	parameter sec=50000000;
    parameter mil=50000;
	reg[127:0] rowA,rowB;
	wire[7:0] zero="0";
	wire[7:0] lvalue;
	wire[7:0] rvalue=LED;
	wire[7:0] A0,Atrans,A1,A2;
	wire[7:0] B0,Btrans,B1,B2;
	wire[7:0] a0,a1,a2,b0,b1,b2;
	wire[17*8-1:0] lineA={"Last answer = ",a2,a1,a0};
	wire[20*8-1:0] lineB={"Current answer = ",b2,b1,b0};
	assign buffA={{20{" "}},lineA,{25{" "}}};
	assign buffB={{20{" "}},lineB,{22{" "}}};
	assign a0=zero+A0;
	assign a1=zero+A1;
	assign a2=zero+A2;
	assign b0=zero+B0;
	assign b1=zero+B1;
	assign b2=zero+B2;
	div dA0(.clk(clk),.dividend(lvalue),.divisor(10),.quotient(Atrans),.fractional(A0));
	div dA1(.clk(clk),.dividend(Atrans),.divisor(10),.quotient(A2),.fractional(A1));
	div dB0(.clk(clk),.dividend(rvalue),.divisor(10),.quotient(Btrans),.fractional(B0));
	div dB1(.clk(clk),.dividend(Btrans),.divisor(10),.quotient(B2),.fractional(B1));
	CAL c1(clk,BTN_SOUTH,BTN_WEST,BTN_NORTH,BTN_EAST,SW,LED,lvalue);
	LCD_module lcd(clk,BTN_SOUTH,rowA,rowB,LCD_E,LCD_RS,LCD_RW,LCD_D);
	always@(posedge clk, posedge BTN_SOUTH)
		if(BTN_SOUTH)begin
			rowA<={16{" "}};
			rowB<={16{" "}};
			Apos<=0;
			Bpos<=19;
			cnt<=0;
		end else begin
			if(cnt<500*mil) cnt<=cnt+1;
			else begin
				cnt<=0;
				if(Apos<42)Apos<=Apos+1;
				else Apos<=0;
				if(Bpos>0)Bpos<=Bpos-1;
				else Bpos<=41;
			end
			rowA<=buffA[(60-Apos)*8-1-:8*16];
			rowB<=buffB[(60-Bpos)*8-1-:8*16];
		end
endmodule