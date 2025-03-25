//two compliment using FSM with 16 bit input 

module twoscompsequence_1 (
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


reg[3:0] counter = 0;

reg[15:0] shiftreg = 0;

initial begin
stopled = 1'b0;
end




always @(negedge clk) begin
state <= nstate;
end

always @* begin    
dout <= shiftreg;
end


always @(posedge clk or posedge start) begin
		
		case (state)
			idle: begin
			if (start)			nstate = copy;
					else 			nstate = idle;
									shiftreg <= din;
			end


			copy: begin
					if (shiftreg[7] == 1) 
					nstate = compliment;
					else
					nstate = copy;
				

	            shiftreg <= {shiftreg[0], shiftreg[15:1]}; //rotate right 
		
        	    	counter <= counter + 1'b1; //increment shift counter
					
			end
		
			compliment: begin
					if (counter < 15) nstate = compliment;
					else 					nstate = stop;
	
					shiftreg[7] <= ~shiftreg[7];        //compliment bit    

            	shiftreg <= {shiftreg[0], shiftreg[15:1]}; //rotate right 

           		counter <= counter + 1'b1; //increment shift counter
	   
    			end
		
			stop: begin
			if (reset) 					nstate = idle;
					else 					nstate = stop;
											stopled = 1'b1;
			end
endcase

end
endmodule
                    







        



