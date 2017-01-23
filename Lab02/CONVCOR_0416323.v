module CONVCOR(	
	clk, 
	rst_n, 
	in_valid, 
	in_a,
	in_b,
	in_mode,	
	out_valid, 
	out
);

	input clk,rst_n,in_valid,in_mode;
	input[15:0] in_a,in_b;
	output reg out_valid;
	output reg[35:0] out;
	reg signed[7:0] Ar[0:2],Br[0:2],Ai[0:2],Bi[0:2];
	wire clkL,clkH;
	assign clkL = !clk;
	assign clkH = clk;
	reg reset;
	reg valid;	
	reg mode;
	reg[3:0] inputCnt;
	reg inputValid;	
	//input
	always@(posedge clkH)begin
		if(!rst_n||!reset)begin
			Ar[0]=0;Br[0]=0;
			Ar[1]=0;Br[1]=0;
			Ar[2]=0;Br[2]=0;
			Ai[0]=0;Bi[0]=0;
			Ai[1]=0;Bi[1]=0;
			Ai[2]=0;Bi[2]=0;
			inputCnt=0;
			out_valid=0;
			valid=0;
			inputValid=0;
			out=0;
			reset=1;
		end else if(in_valid)begin
			case(inputCnt)
			2:begin
				{Ar[2],Ai[2]}=in_a;
				{Br[2],Bi[2]}=in_b;
			end
			1:begin
				{Ar[1],Ai[1]}=in_a;
				{Br[1],Bi[1]}=in_b;
			end
			0:begin
				mode=in_mode;
				inputValid=1;
				{Ar[0],Ai[0]}=in_a;
				{Br[0],Bi[0]}=in_b;
			end
			endcase
			//after input, inputCnt==3
		end
		if(inputValid) inputCnt=inputCnt+1;
	end
	
	reg[3:0] outputCnt;
	wire signed[35:0] conv[0:4];
	wire signed[35:0] core;
	
	wire[17:0] coreR,coreI;
	assign coreR=core[35:18];
	assign coreI=core[17:0];
	
	
	
	//Corelation
	
	assign core[35:18]=(
		Ar[0]*Br[0]+Ar[1]*Br[1]+Ar[2]*Br[2]+
		Ai[0]*Bi[0]+Ai[1]*Bi[1]+Ai[2]*Bi[2]
	);
	assign core[17:0]= (
		(-Ar[0]*Bi[0]+Ai[0]*Br[0])+
		(-Ar[1]*Bi[1]+Ai[1]*Br[1])+
		(-Ar[2]*Bi[2]+Ai[2]*Br[2])
	);
	
	//Convolution
	//Real Part
	assign conv[0][35:18]=Ar[0]*Br[0]-Ai[0]*Bi[0];
	assign conv[1][35:18]=(
		Ar[0]*Br[1]-Ai[0]*Bi[1]+
		Ar[1]*Br[0]-Ai[1]*Bi[0]
	);
	assign conv[2][35:18]=(
		Ar[0]*Br[2]-Ai[0]*Bi[2]+
		Ar[1]*Br[1]-Ai[1]*Bi[1]+
		Ar[2]*Br[0]-Ai[2]*Bi[0]
	);
	assign conv[3][35:18]=(
		Ar[1]*Br[2]-Ai[1]*Bi[2]+
		Ar[2]*Br[1]-Ai[2]*Bi[1]
	);
	assign conv[4][35:18]=Ar[2]*Br[2]-Ai[2]*Bi[2];
	
	//Imaginary Part
	assign conv[0][17:0]=Ar[0]*Bi[0]+Ai[0]*Br[0];
	assign conv[1][17:0]=(
		Ar[0]*Bi[1]+Ai[0]*Br[1]+
		Ar[1]*Bi[0]+Ai[1]*Br[0]
	);
	assign conv[2][17:0]=(
		Ar[0]*Bi[2]+Ai[0]*Br[2]+
		Ar[1]*Bi[1]+Ai[1]*Br[1]+
		Ar[2]*Bi[0]+Ai[2]*Br[0]
	);
	assign conv[3][17:0]=(
		Ar[1]*Bi[2]+Ai[1]*Br[2]+
		Ar[2]*Bi[1]+Ai[2]*Br[1]
	);
	assign conv[4][17:0]=Ar[2]*Bi[2]+Ai[2]*Br[2];
	
	//Output
	always@(negedge clkL)begin
		if(inputCnt==5)begin
			outputCnt=~0;
			inputCnt=0;
			inputValid=0;
			valid=1;
		end
		if(valid)begin
			if(outputCnt==2)out_valid=1;
			if(!mode)begin
				case(outputCnt)
				6: out=conv[4];
				5: out=conv[3];
				4: out=conv[2];
				3: out=conv[1];
				2: out=conv[0];
				endcase
			end else begin
				if(outputCnt==2)
					out=core;
				
			end
			outputCnt=outputCnt+1;
		end
	end

	always@(posedge clk)
		if((mode&&outputCnt==3)||(!mode&&outputCnt==7))begin
			out_valid=0;
			out=0;
			reset=0;
			outputCnt=0;
		end
//---------------------------------
//  input and output declaration
//---------------------------------  



//----------------------------------
// reg and wire declaration
//--------------------------------- 

 

 
 //----------------------------------
//
//         My design
//
//----------------------------------


endmodule

