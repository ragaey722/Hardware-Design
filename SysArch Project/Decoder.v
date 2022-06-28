module Decoder(
	input     [31:0] instr,      // Instruction word
	input            zero,       // Does the current operation in the datapath return 0 as result?
	output reg       memtoreg,   // Use the loaded word instead of the ALU result as result
	output reg       memwrite,   // Write to the data memory
	output reg       dobranch,   // Perform a relative jump
	output reg       alusrcbimm, // Use the immediate value as second operand
	output reg [4:0] destreg,    // Number of the target register to (possibly) be written 
	output reg       regwrite,   // Write to the target register
	output reg       dojump,     // Perform an absolute jump
	output reg [2:0] alucontrol, // ALU control bits
	output reg       isori,		 // Choose zero extended immediate
	output reg       isupper,	 // Choose upper extended immediate
	output reg       isjal,
	output reg 		 isjr
);
	// Extract the primary and secondary opcode
	wire [5:0] op = instr[31:26];
	wire [5:0] funct = instr[5:0];

	always @*
	begin
		isjal=0;
		isjr=0;
		case (op)
			6'b000000: // R-type instruction
				begin
					regwrite = 1;
					destreg = instr[15:11];
					alusrcbimm = 0;
					dobranch = 0;
					memwrite = 0;
					memtoreg = 0;
					dojump = 0;
					isori=0;
					isupper=0;
					case (funct)
						6'b100001: alucontrol = 3'b101; // TODO // addition unsigned
						6'b100011: alucontrol = 3'b001; // TODO // subtraction unsigned
						6'b100100: alucontrol = 3'b111; // TODO // and
						6'b100101: alucontrol = 3'b110; // TODO // or
						6'b101011: alucontrol = 3'b000; // TODO // set-less-than unsigned
						6'b011001: alucontrol = 3'b010; // multu
						6'b010010: alucontrol = 3'b011; // mflo
						6'b010000: alucontrol = 3'b100; // mfhi
						6'b001000: begin				//jr
							regwrite=0;
							alucontrol=3'b110;
							isjr=1; end 
						default:   alucontrol = 3'bxxx; // TODO // undefined
					endcase
				end
			6'b100011, // Load data word from memory
			6'b101011: // Store data word
				begin
					regwrite = ~op[3];
					destreg = instr[20:16];
					alusrcbimm = 1;
					dobranch = 0;
					memwrite = op[3];
					memtoreg = 1;
					dojump = 0;
					isori=0;
					isupper=0;
					alucontrol = 3'b101;// TODO // Effective address: Base register + offset
				end
			6'b000100: // Branch Equal
				begin
					regwrite = 0;
					destreg = 5'bx;
					alusrcbimm = 0;
					dobranch = zero; // Equality test
					memwrite = 0;
					memtoreg = 0;
					dojump = 0;
					isori=0;
					isupper=0;
					alucontrol = 3'b001; // TODO // Subtraction
				end
			6'b000101: // Branch Not Equal
				begin
					regwrite = 0;
					destreg = 5'bx;
					alusrcbimm = 0;
					dobranch = !zero; // Equality test
					memwrite = 0;
					memtoreg = 0;
					dojump = 0;
					isori=0;
					isupper=0;
					alucontrol = 3'b001; // TODO // Subtraction
				end
			6'b001001: // Addition immediate unsigned
				begin
					regwrite = 1;
					destreg = instr[20:16];
					alusrcbimm = 1;
					dobranch = 0;
					memwrite = 0;
					memtoreg = 0;
					dojump = 0;
					isori=0;
					isupper=0;
					alucontrol = 3'b101; // TODO // Addition
				end
			6'b000010: // Jump immediate
				begin
					regwrite = 0;
					destreg = 5'bx;
					alusrcbimm = 0;
					dobranch = 0;
					memwrite = 0;
					memtoreg = 0;
					dojump = 1;
					isori=0;
					isupper=0;
					alucontrol = 3'bxxx;// TODO
				end
			6'b001101: // ORI
				begin
					regwrite = 1;
					destreg = instr[20:16];
					alusrcbimm = 1;
					dobranch = 0;
					memwrite = 0;
					memtoreg = 0;
					dojump = 0;
					isori=1;
					isupper=0;
					alucontrol = 3'b110; // OR 
				end
			6'b001111: // LUI
				begin
					regwrite = 1;
					destreg = instr[20:16];
					alusrcbimm = 1;
					dobranch = 0;
					memwrite = 0;
					memtoreg = 0;
					dojump = 0;
					isori=0;
					isupper=1;
					alucontrol = 3'b110 ; // OR 
				end	
			 6'b000011: // JAL
				begin
					regwrite = 1;
					destreg = 5'b11111;
					alusrcbimm = 0;
					dobranch = 0;
					memwrite = 0;
					memtoreg = 0;
					dojump = 1;
					isori=0;
					isupper=0;
					isjal =1;
					alucontrol = 3'bx ; // OR 
				end	
			default: // Default case
				begin
					regwrite = 1'bx;
					destreg = 5'bx;
					alusrcbimm = 1'bx;
					dobranch = 1'bx;
					memwrite = 1'bx;
					memtoreg = 1'bx;
					dojump =  1'bx;
					isori  =  1'bx;
					isupper=  1'bx;
					alucontrol = 3'bxxx; // TODO
				end
		endcase
	end
endmodule

