//CASE 1 complex multiplier system with finite state machine control 
//assume only one 2-input multiplier and one adder/subtractor unit available
//fixed point range removed for quartus

module complex_multi1_quartus (
    input clk, reset, input_rdy,
    input signed [4:0] areal, aimag, breal, bimag, creal, cimag,    //signed complex number inputs
    output reg signed [15:0] preal, pimag,
	 output reg [3:0] state, nstate);                             

    reg [1:0] ac_sel, bab_sel;
    reg pp1_e, pp2_e, sub;           //control signals for FMS
    reg pr_e, pi_e;

    wire signed [15:0] preal_w, pimag_w;
    wire signed [15:0] operand1, operand2;
    wire signed [15:0] pp;                            //internal signals 
    wire signed [15:0] sum;
    reg signed [15:0] pp1, pp2;        

    parameter [3:0] step1 = 4'b0000, step2 = 4'b0001, step3 = 4'b0010, step4 = 4'b0011, step5 = 4'b0100, step6 = 4'b0101, step7 = 4'b0110,
                    step8 = 4'b0111, step9 = 4'b1000;

    reg [3:0] current_state, next_state;


    assign pimag_w = pimag;
    assign preal_w = preal;
    assign operand1 = ac_sel[1] ? (ac_sel[0] ? cimag : creal) : (ac_sel[0] ? aimag : areal);   //4-1 mux's
    assign operand2 = bab_sel[1] ? (bab_sel[0] ? pimag_w : preal_w) : (bab_sel[0]? bimag : breal);
    assign pp = operand1 * operand2;                                                           //multiplier

    always @(posedge clk)           //assign register 1 partial product
        if (pp1_e) pp1 <= pp;
    
    always @(posedge clk)           //assign register 2 partial product
        if (pp2_e) pp2 <= pp;

    assign sum = sub ? pp1 - pp2 : pp1 + pp2;       //add or subtract control switch

    always @(posedge clk)
        if(pr_e) preal <= sum;                      // assign register 3 real part

    always @(posedge clk)
        if(pi_e) pimag <= sum;                      //assign register 4 imaginary part

    always @(posedge clk or posedge reset) 
    begin
        if (reset) current_state <= step1;
        else current_state <= next_state;
    end
    
    always @(negedge clk)               //change during negedge and set current state signals during posedge
        begin
            case(current_state)

                step1: if (!input_rdy | reset)  next_state = step1;        //only progress if input_rdy = 1 and go back to step 1 if reset = 1
                       else                     next_state = step2;
                step2:                          next_state = step3;
                step3:                          next_state = step4;
                step4:                          next_state = step5;
                step5:                          next_state = step6;
                step6:                          next_state = step7;
                step7:                          next_state = step8;
                step8:                          next_state = step9;
                step9:                          next_state = step1;
            endcase
        end

        always @(posedge clk)
            begin
                ac_sel = 1'b0; bab_sel = 1'b0; pp1_e = 1'b0;
                pp2_e = 1'b0; sub = 1'b0; pr_e = 1'b0; pi_e = 1'b0;

                case (current_state)
                    step1 : begin
                        ac_sel = 2'b00;                          //areal * breal stored in r1
                        bab_sel = 2'b00;
                        pp1_e = 1'b1;
                        pp2_e = 1'b0;
                        sub = 1'b0;
                        pr_e = 1'b0;
                        pi_e = 1'b0;
                    end
                    step2: begin
                        ac_sel = 2'b01;                         //aimag * bimag stored in r2
                        bab_sel = 2'b01;
                        pp1_e = 1'b0;
                        pp2_e = 1'b1;
                        sub = 1'b0;
                        pr_e = 1'b0;
                        pi_e = 1'b0;
                    end
                    step3: begin
                        ac_sel = 2'b00;                         //r1 - r2 stored in r3 - areal * bimag stored in r1
                        bab_sel = 2'b01;
                        pp1_e = 1'b1;
                        pp2_e = 1'b0;
                        sub = 1'b1;
                        pr_e = 1'b1;
                        pi_e = 1'b0;
                    end
                    step4: begin
                        ac_sel = 2'b01;                         //aimag * breal stored in r2
                        bab_sel = 2'b00;
                        pp1_e = 1'b0;
                        pp2_e = 1'b1;
                        sub = 1'b0;
                        pr_e = 1'b0;
                        pi_e = 1'b0;
                    end
                    step5: begin
                        ac_sel = 2'b10;                         //creal * ABreal stored in r1 - ABimag stored in r4
                        bab_sel = 2'b10;
                        pp1_e = 1'b1;
                        pp2_e = 1'b0;
                        sub = 1'b0;
                        pr_e = 1'b0;
                        pi_e = 1'b1;
                    end
                    step6: begin
                        ac_sel = 2'b11;                         //cimag * ABimag stored in r2
                        bab_sel = 2'b11;
                        pp1_e = 1'b0;
                        pp2_e = 1'b1;
                        sub = 1'b0;
                        pr_e = 1'b0;
                        pi_e = 1'b0;
                    end
                    step7: begin
                        ac_sel = 2'b11;                         //cimag * ABreal stored in r1 - CABreal stored in r3
                        bab_sel = 2'b10;
                        pp1_e = 1'b1;
                        pp2_e = 1'b0;
                        sub = 1'b1;
                        pr_e = 1'b1;
                        pi_e = 1'b0;
                    end
                    step8: begin
                        ac_sel = 2'b10;                         //creal * ABimag stored in r2
                        bab_sel = 2'b11;
                        pp1_e = 1'b0;
                        pp2_e = 1'b1;
                        sub = 1'b0;
                        pr_e = 1'b0;
                        pi_e = 1'b0;
                    end
                    step9: begin
                        ac_sel = 2'b10;                         // CABimag stored in r4 (final product finished)
                        bab_sel = 2'b11;
                        pp1_e = 1'b0;
                        pp2_e = 1'b0;
                        sub = 1'b0;
                        pr_e = 1'b0;
                        pi_e = 1'b1;
                    end
                endcase
            end
endmodule