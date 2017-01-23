module LED_ctrl(
	input isOver,
	input clk,
	input rst,
	output [7:0] LED
);

reg [23:0] cnt;

always@(posedge clk,posedge rst)
begin
	if(rst)
	cnt<=0;
	else if(isOver)
	cnt<=cnt+1;
	else
	cnt<=0;
end

assign LED = (cnt[23]==1)? 7'b1111111:0;

endmodule