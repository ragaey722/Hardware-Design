module Division(
	input         clock,
	input         start,
	input  [31:0] a,
	input  [31:0] b,
	output [31:0] q,
	output [31:0] r
);
reg[31:0] A , B , R , Rdash ;
reg signed [7:0] counter=-1;

always @(posedge clock or posedge start) begin
if (start == 1 && clock == 1) begin
	counter= 31; R=0; A=a; B=b;
end	
else if (counter>=0) begin
Rdash = (R << 1) + A[31] ;
A=A<<1;
if(Rdash < B)begin 
A[0]=0;
R=Rdash;
end
else begin
A[0]=1;
R = Rdash-B ;
end
counter = counter -1;
end
end
assign q = A;
assign r = R;	

endmodule

