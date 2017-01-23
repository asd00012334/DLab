module CAL(
    input clk,
    input BTN_SOUTH,
    input BTN_WEST,
    input BTN_NORTH,
    input BTN_EAST,
    input[3:0] SW,
    output[7:0] LED
);
    parameter bound=1000000;
    reg[1:0] mode;
    wire[3:0] BTN;
    wire[7:0] result,rvalue;
    reg[7:0] lvalue;
    reg[20:0] antiVibrateCnt;
    wire[7:0] rstResult,sqrtResult,multiResult,addResult;
    
    assign LED=result;
    assign rvalue={4'b0,SW};
    assign BTN={BTN_SOUTH,BTN_WEST,BTN_NORTH,BTN_EAST};
    assign result=
        (mode==0)?rstResult:
        (mode==1)?sqrtResult:
        (mode==2)?multiResult:
        addResult;
        
    assign rstResult=rvalue;
    sqrt s1(.x_out(sqrtResult[4:0]),.x_in(lvalue));
    assign sqrtResult[7:5]=0;
    assign multiResult=lvalue*rvalue;
    assign addResult=lvalue+rvalue;
    
    always@(posedge clk, posedge BTN_SOUTH)
        if(BTN_SOUTH)begin
            mode<=0;
            lvalue<=0;
            antiVibrateCnt<=0;
        end else if(BTN)begin
            if(antiVibrateCnt<bound) antiVibrateCnt<=antiVibrateCnt+1;
            else if(antiVibrateCnt>bound) antiVibrateCnt<=antiVibrateCnt;
            else begin
                case(BTN)
                4'b1000:mode<=0;
                4'b0100:mode<=1;
                4'b0010:mode<=2;
                default:mode<=3;
                endcase
                lvalue<=result;
                antiVibrateCnt<=antiVibrateCnt+1;
            end
        end else antiVibrateCnt<=0;
        
endmodule
