module Frogger(
    output reg VGA_RED,
	output reg VGA_GREEN,
	output reg VGA_BLUE,
	output VGA_HSYNC,
	output VGA_VSYNC,
    input PS2_CLK,	
    input PS2_DATA,
	input clk,
    input rst,
    output[7:0] LED
);
    //VGA-var
    wire[10:0] r,c;
    reg alive;
    //State-var
    wire[4:0] isOver;
    reg signed[15:0] centerRow,centerCol;
    assign LED=isOver;
    
    //Draw Car
    wire carValid;
    wire[2:0] carColor;
    drawCar cars(
        .clk(clk),
        .rst(rst),
        .row(r),.col(c),
        .valid(carValid),
        .color(carColor),
        .headRow(centerRow),.headCol(centerCol),
        .isOver(isOver[0])
    );
    //Draw BackGround
    wire[2:0] backGroundColor;
    drawBackGround bkG(
        .row(r), .col(c),
        .color(backGroundColor)
    );
    //Draw Train
    wire trainValid;
    wire[2:0] trainColor;
    drawTrain train(
        .clk(clk),
        .rst(rst),
        .row(r), .col(c),
        .valid(trainValid),
        .color(trainColor),
        .headRow(centerRow),
        .headCol(centerCol),
        .isOver(isOver[1])
    );
    //Draw Lotus
    wire lotusMoving;
    wire lotusValid;
    wire[2:0] lotusColor;
    drawLotus lotus(
        .clk(clk),
        .rst(rst),
        .row(r), .col(c),
        .valid(lotusValid),
        .color(lotusColor),
        .isOver(isOver[2]),
        .headRow(centerRow),
        .headCol(centerCol),
        .isMoving(lotusMoving)
    );
    //Draw Dest
    wire destValid;
    wire[2:0] destColor;
    drawDest destination(
        .row(r),.col(c),
        .valid(destValid),
        .color(destColor),
        .headRow(centerRow), .headCol(centerCol),
        .isOver(isOver[3])
    );
    // KeyBoard
    wire[7:0] pressed;
    PS2Control ps2(
        .clk(clk),
        .kData(PS2_DATA),
        .kclk(PS2_CLK),
        .pressed(pressed)
    );
    // Kernel
    wire outOfBound=!(
        0<=centerRow&&centerRow<600&&
        0<=centerCol&&centerCol<800
    );
    parameter VK_UP=8'h75, VK_LEFT=8'h6B, VK_RIGHT=8'h74, VK_DOWN=8'h72;
    reg signed[15:0] offset;
    always@(*)
        if(80<=centerRow&&centerRow<160)
            offset=lotusMoving?6:0;
        else if(160<=centerRow&&centerRow<240)
            offset=lotusMoving?-6:0;
    always@(posedge clk, posedge rst)
        if(rst)begin
            centerRow<=6*80+50;
            centerCol<=800-40;
        end else if(alive)begin
            case(pressed)
            VK_UP:centerRow<=centerRow-80;
            VK_DOWN:centerRow<=centerRow+80;
            VK_LEFT:centerCol<=centerCol-60+offset;
            VK_RIGHT:centerCol<=centerCol+60+offset;
            default:centerCol<=centerCol+offset;
            endcase
        end
    
    assign isOver[4]=outOfBound;
    wire turtleValid;
    wire[2:0] turtleColor;
    drawCircle dc(
        .row(r), .col(c),
        .rowAnchor(centerRow-40),
        .colAnchor(centerCol-40),
        .valid(turtleValid),
        .color(turtleColor),
        .setColor(3'b110),
        .diameter(60)
    );
    //Draw End
    wire endValid;
    wire[2:0] endColor;
    drawEnd de(
        .row(r), .col(c),
        .valid(endValid),
        .color(endColor)
    );
    
    //VGA
	parameter rowBase=23,colBase=104;
	reg signed[15:0] row, col;
	assign VGA_HSYNC=~((919<=col)&(col<1039));
	assign VGA_VSYNC=~((659<=row)&(row<665));
	wire visible=((104<=col)&(col<904))&((23<=row)&(row<623));
	assign r=row-rowBase;
    assign c=col-colBase;
	always@(posedge clk, posedge rst)
		if(rst) col<=0;
		else if(col==1039) col<=0;
		else col<=col+1;
	always@(posedge clk, posedge rst)
		if(rst) row<=0;
		else if(row==665) row<=0;
		else if(col==1039) row<=row+1;
		else row<=row;
	always@(posedge clk, posedge rst)
		if(rst) {VGA_RED,VGA_GREEN,VGA_BLUE}<=0;
		else if(visible) begin
			/*-----------------TO DO: Control Screen-------------------------- */
			/*Interface:
				--r: current row;
				--c: current column;
                RGB value: {VGA_RED,VGA_GREEN,VGA_BLUE}
			*/
            if(!alive)begin
                if(endValid){VGA_RED,VGA_GREEN,VGA_BLUE}<=endColor;
                else {VGA_RED,VGA_GREEN,VGA_BLUE}<=0;
			end else if(carValid) {VGA_RED,VGA_GREEN,VGA_BLUE}<=carColor;
            else if(trainValid) {VGA_RED,VGA_GREEN,VGA_BLUE}<=trainColor;
            else if(turtleValid) {VGA_RED,VGA_GREEN,VGA_BLUE}<=turtleColor;
            else if(lotusValid) {VGA_RED,VGA_GREEN,VGA_BLUE}<=lotusColor;
            else if(destValid) {VGA_RED,VGA_GREEN,VGA_BLUE}<=destColor;
            else {VGA_RED,VGA_GREEN,VGA_BLUE}<=backGroundColor;
		end else {VGA_RED,VGA_GREEN,VGA_BLUE}<=0;
    always@(posedge clk, posedge rst)
        if(rst) alive<=1;
        else if(isOver) alive<=0;
        else alive<=alive;
endmodule
