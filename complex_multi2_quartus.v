//CASE b complex multiplier system with finite state machine control 
//assume two 2-input multiplier and one adder/subtractor unit available
//fixed point size removed for quartus

module complex_multi2_quartus (
    input clk, reset, input_rdy,
    input signed [4:0] areal, aimag, breal, bimag, creal, cimag,    //signed complex number inputs
    output reg signed [15:0] preal, pimag,
	 output reg [3:0] state, nstate);

    reg [1:0] sel1, sel3;           //two 4:1 MUXs
    reg sel0, sel2;                 //two 2:1 MUXs
    reg pp1_e, pp2_e, sub;           //control signals for FMS
    reg pr_e, pi_e;                 //output register enable

    wire signed [15:0] preal_w, pimag_w;
    wire signed [15:0] operand1, operand2, operand3, operand4;
    wire signed [15:0] product1, product2;                            //internal signals 
    wire signed [15:0] sum;
    reg signed [15:0] pp1, pp2;        

    parameter [2:0] step1 = 3'b000, step2 = 3'b001, step3 = 3'b010, step4 = 3'b011, step5 = 3'b100, step6 = 3'b101, step7 = 3'b110, step8 = 3'b111;

    reg [2:0] current_state, next_state;

    assign pimag_w = pimag;
    assign preal_w = preal;
    assign operand1 = sel0 ? preal : areal;                //2-1 mux
    assign operand3 = sel2 ? pimag : aimag;                //2-1 mux
    assign operand2 = sel1[1] ? (sel1[0] ? cimag : creal) : (sel1[0]? bimag : breal);  //4-1 mux
    assign operand4 = sel3[1] ? (sel3[0] ? creal : cimag) : (sel3[0]? breal : bimag);  //4-1 mux
    assign product1 = operand1 * operand2;                  // 2 multipliers
    assign product2 = operand3 * operand4;                                                          


    always @(posedge clk)           //assign register 1 partial product
        if (pp1_e) pp1 <= product1;
    
    always @(posedge clk)           //assign register 2 partial product
        if (pp2_e) pp2 <= product2;

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

                step1: if (!input_rdy | reset) next_state = step1;        //only progress if input_rdy = 1 and go back to step 1 if reset = 1
                       else                    next_state = step2;
                step2:                         next_state = step3;
                step3:                         next_state = step4;
                step4:                         next_state = step5;
                step5:                         next_state = step6;
                step6:                         next_state = step7;
					 step7:                         next_state = step8;
					 step8:                         next_state = step8;
            endcase
        end

        always @(posedge clk)
            begin
                sel0 = 1'b0; sel1 = 1'b0; sel2 = 1'b0; sel3 = 1'b0; pp1_e = 1'b0;
                pp2_e = 1'b0; sub = 1'b0; pr_e = 1'b0; pi_e = 1'b0;

                case (current_state)
                    step1 : begin
                        sel0 = 1'b0;                          
                        sel1 = 2'b00;
                        sel2 = 1'b0;
                        sel3 = 2'b00;
                        pp1_e = 1'b1;
                        pp2_e = 1'b1;
                        sub = 1'b0;
                        pr_e = 1'b0;
                        pi_e = 1'b0;
                    end
                    step2: begin
                        sel0 = 1'b0;                          
                        sel1 = 2'b01;
                        sel2 = 1'b0;
                        sel3 = 2'b01;
                        pp1_e = 1'b1;
                        pp2_e = 1'b1;
                        sub = 1'b1;
                        pr_e = 1'b1;
                        pi_e = 1'b0;
                    end
                    step3: begin
                        sel0 = 1'b0;                          
                        sel1 = 2'b01;
                        sel2 = 1'b0;
                        sel3 = 2'b01;
                        pp1_e = 1'b0;
                        pp2_e = 1'b0;
                        sub = 1'b0;
                        pr_e = 1'b0;
                        pi_e = 1'b1;
                    end
                    step4: begin
                        sel0 = 1'b1;                         
                        sel1 = 2'b10;
                        sel2 = 1'b1;
                        sel3 = 2'b10;
                        pp1_e = 1'b1;
                        pp2_e = 1'b1;
                        sub = 1'b1;
                        pr_e = 1'b0;
                        pi_e = 1'b0;
                    end
                    step5: begin
                        sel0 = 1'b1;                          
                        sel1 = 2'b11;
                        sel2 = 1'b1;
                        sel3 = 2'b11;
                        pp1_e = 1'b1;
                        pp2_e = 1'b1;
                        sub = 1'b1;
                        pr_e = 1'b1;
                        pi_e = 1'b0;
                    end
                    step6: begin
                        sel0 = 1'b0;                          
                        sel1 = 2'b00;
                        sel2 = 1'b0;
                        sel3 = 2'b00;
                        pp1_e = 1'b0;
                        pp2_e = 1'b0;
                        sub = 1'b0;
                        pr_e = 1'b0;
                        pi_e = 1'b1;
                    end
                    step7: begin
                        sel0 = 1'b0;                          
                        sel1 = 2'b00;
                        sel2 = 1'b0;
                        sel3 = 2'b00;
                        pp1_e = 1'b0;
                        pp2_e = 1'b0;
                        sub = 1'b0;
                        pr_e = 1'b0;
                        pi_e = 1'b1;
                    end
                    step8: begin
                        sel0 = 1'b0;                          
                        sel1 = 2'b00;
                        sel2 = 1'b0;
                        sel3 = 2'b00;
                        pp1_e = 1'b0;
                        pp2_e = 1'b0;
                        sub = 1'b0;
                        pr_e = 1'b0;
                        pi_e = 1'b1;
                    end
						  
                endcase
            end
endmodule