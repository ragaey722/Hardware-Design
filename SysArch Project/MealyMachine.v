module MealyPattern(
	input        clock,
	input        i,
	output [1:0] o
);
	reg [2:0] seq;
    reg [1:0] outreg;
    reg [2:0] countin;
	initial begin
	seq=0;
	countin=0;
	outreg=0;
	end
    always @ (negedge clock or posedge clock) begin
        seq = seq << 1 ;
        seq = seq + i ; 
      if (countin <3 ) begin
       countin= countin+1;
      end
      else begin
        if (seq == 6) 
        outreg = 2;
        else if ( seq == 1) 
        outreg = 1; 
        else 
        outreg = 0 ;
      end
    end
assign o = outreg;


endmodule

module MealyPatternTestbench();

	reg clk = 1'b0;
	reg in=1'b1;
	wire[1:0] out;
	reg[9:0] samplein = 10'b1110011001;
	reg signed [6:0] j=9;

	MealyPattern machine(.clock(clk), .i(in), .o(out));
initial
begin
$dumpfile( "mealy.vcd" ) ;
$dumpvars ;
$monitor ("%d %b %b %d",$time,clk,in,out );
end
always begin
clk = 1'b0;
in = samplein[j];
#5
clk =1'b1;
#5
j = j-1;
if(j<0) $finish;
end
	

endmodule

