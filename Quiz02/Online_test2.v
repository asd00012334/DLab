module Online_test2(
	// Input signals
	input clk,
	input rst_n,
	input in_valid1,
	input in_valid2,
	input[5:0] in,
	input[3:0] mode,
	// Output signals
	output reg out_valid,
	output reg[5:0] out
);

	reg proc; 
	reg[63:0] traversed;
	reg[53:0] map; // 9*[5:0]
	reg[39:0] modeArr;
	
	always@(posedge clk, negedge rst_n)begin
		if(!rst_n)begin
			map<=0;
			modeArr<=0;
			proc<=0;
			out_valid<=0;
			out<=0;
			traversed<=0;
		end else if(!proc)begin
			if(in_valid1)
				if(in==0) proc<=1;
				else if(!traversed[in])begin
					map <= {in,map[53:6]};
					traversed[in]<=1;
				end else map<=map;
			else map<=map;
			
			if(in_valid2)
				modeArr<={mode,modeArr[39:4]};
			else modeArr<=modeArr;
			
		end else begin
			if(!modeArr&&map)begin
				out_valid<=1;
				out<= map[5:0];
				map<=(map>>6);
			end else if(out_valid)begin
				out_valid<=0;
				map<=0;
				modeArr<=0;
				proc<=0;
				out<=0;
				traversed<=0;
			end else begin
				case(modeArr[3:0])
				1:{map[5:0],map[11:6]}<={map[11:6],map[5:0]};
				2:{map[11:6],map[17:12]}<={map[17:12],map[11:6]};
				3:{map[5:0],map[23:18]}<={map[23:18],map[5:0]};
				4:{map[11:6],map[29:24]}<={map[29:24],map[11:6]};
				5:{map[17:12],map[35:30]}<={map[35:30],map[17:12]};
				6:{map[23:18],map[29:24]}<={map[29:24],map[23:18]};
				7:{map[29:24],map[35:30]}<={map[35:30],map[29:24]};
				8:{map[23:18],map[41:36]}<={map[41:36],map[23:18]};
				9:{map[29:24],map[47:42]}<={map[47:42],map[29:24]};
				10:{map[35:30],map[53:48]}<={map[53:48],map[35:30]};
				11:{map[41:36],map[47:42]}<={map[47:42],map[41:36]};
				12:{map[47:42],map[53:48]}<={map[53:48],map[47:42]};
				default:map<=map;
				endcase
				modeArr<=(modeArr>>4);
			end
		end
	end
	
	
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
//---------------------------------------------------------------------
// PARAMETER DECLARATION
//---------------------------------------------------------------------
//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION                             
//---------------------------------------------------------------------
//---------------------------------------------------------------------
//   Finite-State Mechine                                          
//---------------------------------------------------------------------
//---------------------------------------------------------------------
//   Design Description                                          
//---------------------------------------------------------------------


endmodule
