module plane(
	output vsyn,hsyn,
	output reg[2:0] color,
	input clk,
	input rst,
	input kclk,
	input kData,
	output reg[7:0] LED
);
	//VGA-Kernel
	reg[10:0] pC,pR;
	wire[10:0] col,row;
	wire visible;
	always@(posedge clk, posedge rst)
		if(rst)pC<=0;
		else if(pC==1039)pC<=0;
		else pC<=pC+1;
	always@(posedge clk, posedge rst)
		if(rst)pR<=0;
		else if(pR==665)pR<=0;
		else if(pC==1039)pR<=pR+1;
		else pR<=pR;
	assign hsyn=~((pC>=919)&pC<1039);
	assign vsyn=~((pR>=659)&(pR<665));
	assign visible=(104<=pC&&pC<904)&&(23<=pR&&pR<623);
	assign col=pC-104;
	assign row=pR-23;
	
	
	//KeyBoard
	//Interface:
	// - use
	// Afire, Amove,
	// Bfire, Bmove
	// To determine a press event
	wire [7:0] pressed;
	ps2Control ps2(
		.clk(clk),
		.rst(rst),
		.kclk(kclk),
		.kData(kData),
		.pressed(pressed)
		);
	wire [1:0] Amove,Bmove;
	wire Afire,Bfire;
	ps2Out ps2O(
	.pressed(pressed),
	.Afire(Afire),
	.Amove(Amove),
	.Bfire(Bfire),
	.Bmove(Bmove)
	);
	
	
	//Kernel
	reg[10:0] plane1,plane2;
	reg[11*20-1+1:0] bulletRowA,bulletRowB,bulletColA,bulletColB;
	reg[20-1:0] aliveA,aliveB;
	reg[5:0] takenA,takenB;
	always@(posedge clk, posedge rst)
		if(rst)begin
			plane1<=400-20;
		end else begin
			case(Amove)
			2'b10:plane1<=plane1>20?plane1-20:plane1;
			2'b01:plane1<=plane1<600-20?plane1+20:plane1;
			default:plane1<=plane1;
			endcase
		end
	always@(posedge clk, posedge rst)
		if(rst)begin
			plane2<=400-20;
		end else begin
			case(Bmove)
			2'b10:plane2<=plane2>20?plane2-10:plane2;
			2'b01:plane2<=plane2<600-20?plane2+10:plane2;
			default:plane1<=plane1;
			endcase
		end
		
		
	parameter milli=50000,sec=50000000;
	integer timing,i;
	always@(posedge clk, posedge rst)
		if(rst) timing<=0;
		else if(timing<500*milli) timing<=timing+1;
		else timing<=0;
	always@(posedge clk, posedge rst)
		if(rst)begin
			bulletRowA<=0;
			bulletColA<=0;
			takenA<=0;
			aliveA<=0;
		end else if(!timing)begin
			for(i=0;i<20;i=i+1)
				if(aliveA[i])begin
					if(bulletColA[i*11+:11]<800-4)
						bulletColA[i*11+:11]<=bulletColA[i*11+11]+4;
					else aliveA[i]<=0;
				end
		end else if(Afire)begin
			takenA<=takenA+1;
			aliveA[takenA]<=1;
			case(takenA)
			0:bulletColA[0*11+:11]<=150;
			1:bulletColA[1*11+:11]<=150;
			2:bulletColA[2*11+:11]<=150;
			3:bulletColA[3*11+:11]<=150;
			4:bulletColA[4*11+:11]<=150;
			5:bulletColA[5*11+:11]<=150;
			6:bulletColA[6*11+:11]<=150;
			7:bulletColA[7*11+:11]<=150;
			8:bulletColA[8*11+:11]<=150;
			9:bulletColA[9*11+:11]<=150;
			10:bulletColA[10*11+:11]<=150;
			11:bulletColA[11*11+:11]<=150;
			12:bulletColA[12*11+:11]<=150;
			13:bulletColA[13*11+:11]<=150; 
			14:bulletColA[14*11+:11]<=150;
			15:bulletColA[15*11+:11]<=150;
			16:bulletColA[16*11+:11]<=150;
			17:bulletColA[17*11+:11]<=150;
			18:bulletColA[18*11+:11]<=150;
			19:bulletColA[19*11+:11]<=150;
			endcase
			case(takenA)
			0:bulletRowA[0*11+:11]<=plane1;
			1:bulletRowA[1*11+:11]<=plane1;
			2:bulletRowA[2*11+:11]<=plane1;
			3:bulletRowA[3*11+:11]<=plane1;
			4:bulletRowA[4*11+:11]<=plane1;
			5:bulletRowA[5*11+:11]<=plane1;
			6:bulletRowA[6*11+:11]<=plane1;
			7:bulletRowA[7*11+:11]<=plane1;
			8:bulletRowA[8*11+:11]<=plane1;
			9:bulletRowA[9*11+:11]<=plane1;
			10:bulletRowA[10*11+:11]<=plane1;
			11:bulletRowA[11*11+:11]<=plane1;
			12:bulletRowA[12*11+:11]<=plane1;
			13:bulletRowA[13*11+:11]<=plane1;
			14:bulletRowA[14*11+:11]<=plane1;
			15:bulletRowA[15*11+:11]<=plane1;
			16:bulletRowA[16*11+:11]<=plane1;
			17:bulletRowA[17*11+:11]<=plane1;
			18:bulletRowA[18*11+:11]<=plane1;
			19:bulletRowA[19*11+:11]<=plane1;
			endcase
		end
	
	always@(posedge clk, posedge rst)
		if(rst)begin
			bulletRowB<=0;
			bulletColB<=0;
			takenB<=0;
			aliveB<=0;
		end else if(!timing)begin
			for(i=0;i<20;i=i+1)
				if(aliveB[i])begin
					if(bulletColB[i*11+:11]<800-4)
						bulletColB[i*11+:11]<=bulletColB[i*11+11]+4;
					else aliveB[i]<=0;
				end
		end else if(Bfire)begin
			takenB<=takenB+1;
			aliveB[takenB]<=1;
			case(takenB)
			0:bulletColB[0*11+:11]<=650;
			1:bulletColB[1*11+:11]<=650;
			2:bulletColB[2*11+:11]<=650;
			3:bulletColB[3*11+:11]<=650;
			4:bulletColB[4*11+:11]<=650;
			5:bulletColB[5*11+:11]<=650;
			6:bulletColB[6*11+:11]<=650;
			7:bulletColB[7*11+:11]<=650;
			8:bulletColB[8*11+:11]<=650;
			9:bulletColB[9*11+:11]<=650;
			10:bulletColB[10*11+:11]<=650;
			11:bulletColB[11*11+:11]<=650;
			12:bulletColB[12*11+:11]<=650;
			13:bulletColB[13*11+:11]<=650; 
			14:bulletColB[14*11+:11]<=650;
			15:bulletColB[15*11+:11]<=650;
			16:bulletColB[16*11+:11]<=650;
			17:bulletColB[17*11+:11]<=650;
			18:bulletColB[18*11+:11]<=650;
			19:bulletColB[19*11+:11]<=650;
			endcase
			case(takenA)
			0:bulletRowA[0*11+:11]<=plane1;
			1:bulletRowA[1*11+:11]<=plane1;
			2:bulletRowA[2*11+:11]<=plane1;
			3:bulletRowA[3*11+:11]<=plane1;
			4:bulletRowA[4*11+:11]<=plane1;
			5:bulletRowA[5*11+:11]<=plane1;
			6:bulletRowA[6*11+:11]<=plane1;
			7:bulletRowA[7*11+:11]<=plane1;
			8:bulletRowA[8*11+:11]<=plane1;
			9:bulletRowA[9*11+:11]<=plane1;
			10:bulletRowA[10*11+:11]<=plane1;
			11:bulletRowA[11*11+:11]<=plane1;
			12:bulletRowA[12*11+:11]<=plane1;
			13:bulletRowA[13*11+:11]<=plane1;
			14:bulletRowA[14*11+:11]<=plane1;
			15:bulletRowA[15*11+:11]<=plane1;
			16:bulletRowA[16*11+:11]<=plane1;
			17:bulletRowA[17*11+:11]<=plane1;
			18:bulletRowA[18*11+:11]<=plane1;
			19:bulletRowA[19*11+:11]<=plane1;
			endcase
		end
	
	// Collision
	reg[19:0] collisionA;
	wire deadA=|collisionA;
	integer j;
	always@(posedge clk, posedge rst)
		if(rst) collisionA<=0;
		else for(j=0;j<20;j=j+1)
			if(aliveA[j])
				if(
					plane2<=bulletRowA[j*11+:11]+2&&
					bulletRowA[j*11+:11]+2<plane2+40&&
					700<=bulletColA[j*11+:11]+2&&
					bulletColA[j*11+:11]+2<700+40
				) collisionA[j]<=1;
				else collisionA[j]<=0;
			else collisionA[j]<=0;
		
	// Draw bullet of A
	wire validBulletA;
	wire[2:0] colorBulletA;
	drawBulletShower dBS(
		.row(row), .col(col),
		.bulletRow(bulletRowA), .bulletCol(bulletColA),
		.alive(aliveA),
		.valid(validBulletA),
		.color(colorBulletA)
	);
	//Plane 
	wire validA,validB;
	wire[2:0] colorA,colorB;
	drawPlane planeA(
		.row(row),.col(col),
		.rowAnchor(plane1),.colAnchor(100),
		.type(1),
		.valid(validA),
		.color(colorA)
	);
	drawPlane planeB(
		.row(row),.col(col),
		.rowAnchor(plane2),.colAnchor(700),
		.type(0),
		.valid(validB),
		.color(colorB)
	);
	//VGA-interface
	always@(posedge clk, posedge rst)
		if(rst) color<=0;
		else if(visible)begin
			// Interface:
			// - use row, col pair to determine
			// current location
			if(validBulletA) color<=colorBulletA;
			else if(validA) color<=colorA;
			else if(validB) color<=colorB;
			else color<=3'b010;
		end else color<=0;
	
	
	//LED-interface
	always@(posedge clk, posedge rst)
		if(rst) LED<=0;
		else if(Afire)
			LED<=1;
		else LED<=LED;
endmodule
