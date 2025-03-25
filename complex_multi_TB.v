`timescale 1ns/1ns

module complex_multi_TB;

parameter t_c = 50;   //clock generation 50ns

    wire signed [9:-5] preal, pimag;
    wire signed [9:-5] ppout;
    wire signed [9:-5] sumout;
    wire signed [2:-2] areal, aimag, breal, bimag, creal, cimag;
    wire signed [9:-5] op_1, op_2;
    wire ac_sel_o, bab_sel_o;
    wire [3:0] state, nstate;
    reg clk, reset, input_rdy;


    real real_areal, real_aimag, real_breal, real_bimag, real_creal, real_cimag;

    task apply_test(input real areal_test, aimag_test, 
                    input real breal_test, bimag_test,
                    input real creal_test, cimag_test);

                    begin
                        real_areal = areal_test;
                        real_aimag = aimag_test;
                        real_breal = breal_test;
                        real_bimag = bimag_test;
                        real_creal = creal_test;
                        real_cimag = cimag_test;
                        input_rdy = 1'b1;
                        @(negedge clk) input_rdy = 1'b0;
                        repeat (10) @(negedge clk);
                    end
    endtask

    complex_multi duv (.preal(preal), .pimag(pimag), .areal(areal), .aimag(aimag), .breal(breal), .bimag(bimag), .creal(creal), .cimag(cimag),
                        .clk(clk), .reset(reset), .input_rdy(input_rdy), .ppout(ppout), .sumout(sumout), .state(state), .op_1(op_1), .op_2(op_2),
                        .ac_sel_o(ac_sel_o), .bab_sel_o(bab_sel_o), .nstate(nstate));

    always begin
        #(t_c/2)        clk = 1'b1;   //clock generation
        #(t_c - t_c/2)  clk = 1'b0;
    end

    initial begin
        reset <= 1'b1;
        #(2*t_c) reset <= 1'b0;
    end

    initial begin
        @(negedge reset)
        @(negedge clk)
        apply_test(3.75, 3.0, 3.75, -4.0, 3.75, 3.0);   //(3+2j)*(3-2j)*(3+2j)  = 39+26j
        $wait;
    end

    assign areal = $rtoi(real_areal * 2**2);    //convert back to integer
    assign aimag = $rtoi(real_aimag * 2**2);
    assign breal = $rtoi(real_breal * 2**2);
    assign bimag = $rtoi(real_bimag * 2**2);
    assign creal = $rtoi(real_creal * 2**2);        
    assign cimag = $rtoi(real_cimag * 2**2);

endmodule  