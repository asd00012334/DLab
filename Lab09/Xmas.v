module Xmas(
	input rst,
	input clk,
	output reg VGA_RED,
	output reg VGA_GREEN,
	output reg VGA_BLUE,
	output VGA_HSYNC,
	output VGA_VSYNC
    
   
    
);
	// 800*600
	parameter rowBase=23,colBase=104;
	parameter rowNum=600, colNum=800;
	parameter milli=50000;
    parameter sec=50000000;


	reg[10:0] row, col;

	assign VGA_HSYNC=~((919<=col)&(col<1039));
	assign VGA_VSYNC=~((659<=row)&(row<665));
	wire visible=((104<=col)&(col<904))&((23<=row)&(row<623));
	wire[10:0] r=row-rowBase;
    wire[10:0] c=col-colBase;

	always@(posedge clk, posedge rst)
		if(rst) col<=0;
		else if(col==1039) col<=0;
		else col<=col+1;

	always@(posedge clk, posedge rst)
		if(rst) row<=0;
		else if(row==665) row<=0;
		else if(col==1039) row<=row+1;
		else row<=row;

    reg [11:0]rowAnchor,colAnchor;
    reg [30:0] cnt;
    always@(posedge clk,posedge rst)
    begin
        if(rst)
        begin
            rowAnchor<=400;
            colAnchor<=400;
            cnt<=0;
        end
        else
        begin
            if(cnt<100*milli)
            cnt<=cnt+1;
            else
            begin
                cnt<=0;
                rowAnchor<=rowAnchor>500?  400: rowAnchor+10;
            end
        end
    end



wire [2:0]treeClr;
wire treeValid;

	addTree tree(
	.row(row),
	.col(col),
	.color(treeClr),
	.valid(treeValid)
);

wire [2:0] skyClr;
wire skyValid;

    addSky sky(
    .clk(clk),
    .rst(rst),
    .row(row),
    .col(col),
    .color(skyClr),
    .valid(skyValid)
    );






   
    always@(posedge clk, posedge rst)
		if(rst) {VGA_RED,VGA_GREEN,VGA_BLUE}<=0;
		else if(visible) begin
            if(skyValid)
                {VGA_RED,VGA_GREEN,VGA_BLUE}<=skyClr;
               else if(treeValid!=0)
                {VGA_RED,VGA_GREEN,VGA_BLUE}<=treeClr;
             else
                    {VGA_RED,VGA_GREEN,VGA_BLUE}<=3'b001;
        end else {VGA_RED,VGA_GREEN,VGA_BLUE}<=0;

endmodule
