`define CYCLE_PERIOD 4.0
`define TEST_SIZE 10000

module PATTERN(
	output reg clk,
	output reg[2:0] circle1,
	output reg[2:0] circle2,
	output reg[4:0]  in,
	output reg in_valid,
	output reg rst_n,
	input[5:0] out,
	input out_valid
);
	integer cnt, inCnt, outCnt, trans;
	integer form, latt, latency;
	integer times;
	integer seed;
	reg[4:0] inner[0:7];
	reg[4:0] outer[0:7];
	reg[5:0] array[0:7];
	
	initial begin
		clk=0;
		forever #`CYCLE_PERIOD clk = ~clk;
	end
	
	initial begin
		for(times=0;times<`TEST_SIZE;times=times+1)begin
			$random(times);
			init;
			giveInput;
			cntDelay;
			check;
		end
		$display("AC\n");
		$finish;
	end
	
	task init; begin
		latency=0;
		rst_n=1;
		@(negedge clk);
		rst_n=0;
		@(negedge clk);
		rst_n=1;
		if(out||out_valid)begin
			$display("Incomplete Reset:");
			if(out)$display("out not reset\n");
			else $display("out_valid not reset\n");
			$finish;
		end
	end endtask
	
	task cntDelay; begin
		while(!out_valid)begin
			@(negedge clk);
			latency=latency+1;
			if(latency>=100)begin
				$display("TLE\n");
				$finish;
			end
		end
	end endtask
	
	task giveInput; begin
		@(negedge clk);
		in_valid=1;
		for(inCnt=0;inCnt<16;inCnt=inCnt+1)begin
			if(times<10)
				in=31;
			else in={$random()}%32;
			if(!inCnt)begin
				circle1={$random()}%8;
				circle2={$random()}%8;
			end
			if(inCnt<8) inner[inCnt]=in;
			else outer[inCnt-8]=in;
			@(negedge clk);
		end
			
		for(inCnt=0;inCnt<circle1;inCnt=inCnt+1)begin
			trans=inner[7];
			for(cnt=6;cnt>=0;cnt=cnt-1)
				inner[cnt+1]=inner[cnt];
			inner[0]=trans;
		end
		
		for(inCnt=0;inCnt<circle2;inCnt=inCnt+1)begin
			trans=outer[7];
			for(cnt=6;cnt>=0;cnt=cnt-1)
				outer[cnt+1]=outer[cnt];
			outer[0]=trans;
		end
		
		for(inCnt=0;inCnt<8;inCnt=inCnt+1)begin
			array[inCnt]=(inner[inCnt]+outer[inCnt])%64;
		end
		
		for(form=1;form<8;form=form+1)
		for(latt=form;latt>0;latt=latt-1)
			if(array[latt-1]>array[latt])begin
				inCnt=array[latt-1];
				array[latt-1]=array[latt];
				array[latt]=inCnt;
			end
			
		
			
		inCnt=0;
		in_valid=0;
	end endtask
	
	task check; begin
		outCnt=0;
		while(out_valid) begin
			if(outCnt>=8) begin
				$display("Output too much\n");
				$finish;
			end
			if(array[outCnt]!==out)begin
				$display("WA: ans is %d, you give %d\n",array[outCnt],out);
				$finish;
			end
			outCnt=outCnt+1;
			@(negedge clk);
		end
		if(outCnt<8)begin
			$display("Output too little\n");
			$finish;
		end
	end endtask
	
endmodule