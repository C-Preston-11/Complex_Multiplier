module twoscompsequence_4 (
    input [15:0] din, 
    input start, clk, reset,
    output reg stopled,
    output reg [15:0] dout
);

reg[1:0] state, nstate;
parameter idle = 2'b00;
parameter copy = 2'b01;
parameter compliment = 2'b10;
parameter stop = 2'b11;

reg[3:0] counter;
reg[15:0] shiftreg;

initial begin
    stopled = 1'b0;
    counter = 4'b0000;
end

always @* begin
    dout[15:0] <= shiftreg[15:0];
end

always @(negedge clk) begin    
    state <= nstate;
end

always @(posedge clk) begin
    case (state)
        idle: begin
            if(start) begin
                shiftreg = din;
                nstate = copy;
            end
            else begin
                nstate = idle;
            end
        end

        copy: begin
            if (shiftreg[0]) begin
                shiftreg = {shiftreg[0], shiftreg[15:1]}; // Rotate right
                nstate = compliment;
            end
            else begin
                nstate = copy;
            end
        end

        compliment: begin
            // Perform 2's complement operation
            shiftreg[0] = ~shiftreg[0];
            shiftreg = {shiftreg[0], shiftreg[15:1]}; // Rotate right
            nstate = (counter == 4'b1111) ? stop : compliment; // Check for end condition
            counter <= counter + 1; // Increment counter
        end

        stop: begin
            if (reset) begin
                nstate = idle;
            end
            else begin
                nstate = stop;
            end
        end
    endcase
end

endmodule

