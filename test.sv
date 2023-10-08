/* module test(
    input logic [15:0] SW,
    input logic [3:0] KEY,
    input CLOCK_50,
    output logic [6:0] HEX0, HEX1, HEX2, HEX3,
    output logic [17:0] LEDR
);

// Declare state variables
logic [1:0] PS, NS;
parameter S0 = 2'b00;

// State machine
always @(posedge CLOCK_50) begin
    if (!KEY[0])
    begin
        PS <= S0;
        LEDR[0] <= 1'b1;
        //LEDR[1] <= 1'b0; // Turn off LEDR[1]
    end
    else
    begin
        PS <= NS;
        LEDR[0] <= 1'b0; // Turn off LEDR[0]
        LEDR[1] <= 1'b1;
    end
end

endmodule */

module test(
		input logic [15:0] SW,
		input logic [3:0] KEY,
		input CLOCK_50,
		output logic [6:0] HEX0, HEX1, HEX2, HEX3,
		output logic [17:0]LEDR,
		output logic LEDG[7]);
		
		parameter S0=2'b00, S1=2'b01, S2=2'b10, S3=2'b11;
		logic i;
		logic [15:0] a,b,swap,rem;
		logic [6:0] yyy0, yyy1, yyy2, yyy3;
		logic [15:0] ans;
		logic [1:0] PS, NS;
		logic go;
		logic [15:0]out;
		logic done = 1'b0;
		
		assign g0 = 1'b0;
		
		//To toggle between states depending on the key that has been pressed
		always @(KEY[3:0],CLOCK_50)
			begin
				if (!KEY[0])
					begin
						PS <= S0;
						LEDR[0] <= 1'b1;
						LEDR[1] <= 1'b0;
					end
				 else
					begin
						PS <= NS;
						LEDR[0] <= 1'b0;
						LEDR[1] <= 1'b1;
					end
			end
			
			always @(PS,KEY[3:0],CLOCK_50)
					begin: state_table
						case (PS)
								S0: 
									begin
										NS <= !(KEY[1]) ? S1: S0;
										LEDR[5:4] <= S1;
										LEDR[17:16] <= S0;
										LEDR[15:6] <= 10'b0000000000;
									end
								S1: 
									begin
										NS = !(KEY[2]) ? S2 : S1;
										LEDR[5:4] <= S2;
										LEDR[17:16] <= S1;
										LEDR[15:6] <= 10'b0000000000;
									end
								S2: 
									begin
										NS <= !(KEY[3]) ? S3 : S2;
										LEDR[5:4] <= S3;
										LEDR[17:16] <= S2;
										LEDR[15:6] <= 10'b0000000000;
									end
								S3:
									begin
											if(!(KEY[3]))
												begin
													//NS <= ? S0 : S3;
														LEDR[5:4] <= S0;
														LEDR[17:16] <= S3;
														LEDR[15:6] <= 10'b0000000000;
												end
										//NS <= !(KEY[3]) ? S0 : S3;
										//LEDR[5:4] <= S0;
										//LEDR[17:16] <= 2'b11;
										//LEDR[15:6] <= 10'b0000000000;
										//go <= 1'b1;
										/*if (!(KEY[1]))
											NS = S1;
										else if (!(KEY[0]))
											NS = S0;
										else if (i==1)
											NS = S3;*/
									end
								//default: NS = 2'bxx;
						endcase
				end
				
				always @(CLOCK_50,PS)
					begin
						if(PS == 2'b00)
							begin
								a = SW[15:0];
							end
						if(PS == 2'b01)
								b = SW[15:0];
						if(PS == 2'b11)
							
							begin
								if( a == {16{1'b0}})
									begin
										out = b;
										done = 1'b1;
										LEDG[0] <= 1'b1;
									end
								else if(b == {16{1'b0}} )
									begin
										out = a;
										done = 1'b1;
										LEDG[1] <= 1'b1;
									end
								else if( a == b)
									begin
										out = a;
										done = 1'b1;
										LEDG[2] <= 1'b1;
									end
								else if ( a > b )
										a = a - b;
								else
									begin
										swap = a;
										a = b;
										b = swap;
									end
									
//								else if (b|16'b0)
//									a = a - b;
									
								LEDG[6] <= 1'b1;
							end
							
						else
							LEDG[6] <= 1'b0;
							LEDG[0] <= 1'b0;
							LEDG[1] <= 1'b0;
							LEDG[2] <= 1'b0;
							done <= 1'b0;
					end
				
				
				/* always @(CLOCK_50)
					begin
						if (NS == S1)
							a = SW[15:0];
						else if (NS == S2)
							b = SW[15:0];
						else if (NS == S3)
							begin
								if ( a<b )
									begin
										swap = a;
										a = b;
										b = swap;
									end
								else if (b|16'b0)
									a = a - b;
							end
				//a', b' := a % b, b % (a % b);
			 	end */
				
//			assign i = |b;
//			assign ans = ((i == 0) & (PS == S3)) ? a : {16{1'bz}};
			//assign ans = ((i == 1'b1) & (PS == S3)) ? out : {16{1'b0}};
			assign ans = out;
			assign LEDG[5] = done;
			seven_seg A (ans[3:0], yyy0);
			seven_seg B (ans[7:4], yyy1);
			seven_seg C (ans[11:8], yyy2);
			seven_seg D (ans[15:12], yyy3);
			assign HEX0 = yyy0;
			assign HEX1 = yyy1;
			assign HEX2 = yyy2;
			assign HEX3 = yyy3;
			
endmodule



module seven_seg (
		input logic [3:0] in1,
		output logic [6:0] HEX_out);
		
		always @(in1)
			begin
				case (in1)
					4'b0000: HEX_out = 7'b100_0000;
					4'b0001: HEX_out = 7'b111_1001;
					4'b0010: HEX_out = 7'b010_0100;
					4'b0011: HEX_out = 7'b011_0000;
					4'b0100: HEX_out = 7'b001_1001;
					4'b0101: HEX_out = 7'b001_0010;
					4'b0110: HEX_out = 7'b000_0010;
					4'b0111: HEX_out = 7'b111_1000;
					4'b1000: HEX_out = 7'b000_0000;
					4'b1001: HEX_out = 7'b001_1000;
					4'b1010: HEX_out = 7'b000_1000;
					4'b1011: HEX_out = 7'b000_0011;
					4'b1100: HEX_out = 7'b100_0110;
					4'b1101: HEX_out = 7'b010_0001;
					4'b1110: HEX_out = 7'b000_0110;
					4'b1111: HEX_out = 7'b000_1110;
					default: HEX_out = 7'b111_1111;
				endcase
		end
		
endmodule