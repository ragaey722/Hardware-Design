module Datapath(
	input         clk, reset,
	input         memtoreg,
	input         dobranch,
	input         alusrcbimm,
	input  [4:0]  destreg,
	input         regwrite,
	input         jump,
	input  [2:0]  alucontrol,
	output        zero,
	output [31:0] pc,
	input  [31:0] instr,
	output [31:0] aluout,
	output [31:0] writedata,
	input  [31:0] readdata,
	input 		  isori,
	input   	  isupper,
	input		  isjal,
	input		  isjr
);
	wire [31:0] pc;
	wire [31:0] signimm,zeroimm,uppimm,link;
	wire [31:0] srca, srcb, srcbimm;
	wire [31:0] result;
	// Fetch: Pass PC to instruction memory and update PC
	ProgramCounter pcenv(clk, reset, dobranch, signimm, jump, instr[25:0], pc,isjr,aluout,link);

	// Execute:
	// (a) Select operand
	SignExtension se(instr[15:0], signimm);
	ZeroExtension ze(instr[15:0], zeroimm);
	UpperExtension ue(instr[15:0], uppimm);
	assign srcbimm = alusrcbimm ? ( isupper? uppimm :( isori? zeroimm: signimm) ): srcb;
	// (b) Perform computation in the ALU
	ArithmeticLogicUnit alu(srca, srcbimm, alucontrol, aluout, zero);
	// (c) Select the correct result
	assign result = isjal? link : memtoreg ? readdata : aluout;

	// Memory: Data word that is transferred to the data memory for (possible) storage
	assign writedata = srcb;

	// Write-Back: Provide operands and write back the result
	RegisterFile gpr(clk, regwrite, instr[25:21], instr[20:16],
				   destreg, result, srca, srcb);
endmodule

module ProgramCounter(
	input         clk,
	input         reset,
	input         dobranch,
	input  [31:0] branchoffset,
	input         dojump,
	input  [25:0] jumptarget,
	output [31:0] progcounter,
	input		  isjr,
	input  [31:0] injr,
	output [31:0] link
);
	reg  [31:0] pc;
	wire [31:0] incpc, branchpc, nextpc;

	// Increment program counter by 4 (word aligned)
	Adder pcinc(.a(pc), .b(32'b100), .cin(1'b0), .y(incpc));
	// Calculate possible (PC-relative) branch target
	Adder pcbranch(.a(incpc), .b({branchoffset[29:0], 2'b00}), .cin(1'b0), .y(branchpc));
	// Select the next value of the program counter
	assign nextpc = isjr ? injr : dojump   ? {incpc[31:28], jumptarget, 2'b00} :
					dobranch ? branchpc :
							   incpc;
	assign link = incpc;

	// The program counter memory element
	always @(posedge clk)
	begin
		if (reset) begin // Initialize with address 0x00400000
			pc <= 'h00400000;
		end else begin
			pc <= nextpc;
		end
	end

	// Output
	assign progcounter = pc;

endmodule

module RegisterFile(
	input         clk,
	input         we3,
	input  [4:0]  ra1, ra2, wa3,
	input  [31:0] wd3,
	output [31:0] rd1, rd2
);
	reg [31:0] registers[31:0];

	always @(posedge clk)
		if (we3) begin
			registers[wa3] <= wd3;
		end

	assign rd1 = (ra1 != 0) ? registers[ra1] : 0;
	assign rd2 = (ra2 != 0) ? registers[ra2] : 0;
endmodule

module Adder(
	input  [31:0] a, b,
	input         cin,
	output [31:0] y,
	output        cout
);
	assign {cout, y} = a + b + cin;
endmodule

module SignExtension(
	input  [15:0] a,
	output [31:0] y
);
	assign y = {{16{a[15]}}, a};
endmodule

module ZeroExtension(
	input  [15:0] a,
	output [31:0] y
);
	assign y = {{16{1'b0}}, a};
endmodule

module UpperExtension(
	input  [15:0] a,
	output [31:0] y
);
	assign y = {a, {16{1'b0}}};
endmodule

module ArithmeticLogicUnit(
	input  [31:0] a, b,
	input  [2:0]  alucontrol,
	output [31:0] result,
	output        zero
);
reg [31:0] res,lo,hi;

reg zero_reg;
always @* begin
case (alucontrol)
3'b000	: res = a<b? 1 : 0;
3'b001	: res = a - b;
3'b101	: res = a + b;
3'b110	: res = a | b;
3'b111	: res = a & b;
3'b010  : {hi,lo} = a * b;
3'b011  : res = lo;
3'b100  : res = hi;
endcase
if (res == 0)
zero_reg = 1;
else
zero_reg = 0;
end
assign zero = zero_reg;
assign result = res;


endmodule


