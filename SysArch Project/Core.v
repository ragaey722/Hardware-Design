module MIPScore(
	input clk,
	input reset,
	// Connected to instruction memory
	output [31:0] pc,
	input  [31:0] instr,
	// Connected to data memory
	output        memwrite,
	output [31:0] aluout, writedata,
	input  [31:0] readdata
);
	wire       memtoreg, alusrcbimm, regwrite, dojump, dobranch, zero , isori , isupper,isjal,isjr;
	wire [4:0] destreg;
	wire [2:0] alucontrol;

	Decoder decoder(instr, zero, memtoreg, memwrite,
					dobranch, alusrcbimm, destreg,
					regwrite, dojump, alucontrol,isori,isupper,isjal,isjr);
	Datapath dp(clk, reset, memtoreg, dobranch,
				alusrcbimm, destreg, regwrite, dojump,
				alucontrol,
				zero, pc, instr,
				aluout, writedata, readdata,isori,isupper,isjal,isjr);
endmodule

