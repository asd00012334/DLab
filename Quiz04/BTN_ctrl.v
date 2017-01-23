module BTN_ctrl(
	input clk,
	input BTN_SOUTH,
	input BTN_NORTH,
	input BTN_EAST,
	input BTN_WEST,
	output reg [1:0] stat,
	output reg dec,
	output reg inc
);
	parameter mili=50000;
	parameter hold=100*mili;
	wire rst=BTN_SOUTH;
	wire onclick=|{BTN_EAST,BTN_NORTH,BTN_WEST};
	integer cnt;
	
	
	always@(posedge clk, posedge rst)
		if(rst)
			{stat,dec,inc,cnt}<=0;
		else if(onclick)
			if(cnt<hold)cnt<=cnt+1;
			else if(cnt==hold)begin
				if(BTN_EAST&&stat==0){dec,inc}<=2'b01;
				else if(BTN_WEST&&stat==0){dec,inc}<=2'b10;
				else case(stat)
				0:stat<=1;
				1:stat<=2;
				2:stat<=1;
				default:stat<=2;
				endcase
				cnt<=cnt+1;
			end else begin
				cnt<=cnt;
				{dec,inc}<=0;
			end
		else cnt<=0;
endmodule