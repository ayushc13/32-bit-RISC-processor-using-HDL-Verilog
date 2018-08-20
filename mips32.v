`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:08:21 03/10/2018 
// Design Name: 
// Module Name:    mips32 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
	module mips32(clk1 , clk2);

	input clk1 ;
	input clk2;
	reg [31:0] PC ;
	reg [31:0] IF_ID_IR ;
	reg [31:0] IF_ID_NPC;
	reg [31:0] ID_EX_IR;
	reg [31:0] ID_EX_NPC;
	reg [31:0] ID_EX_A;
	reg [31:0] ID_EX_B;
	reg [31:0] ID_EX_Imm;
	reg [2:0] ID_EX_type;
	reg [2:0] EX_MEM_type;
	reg [2:0] MEM_WB_type;
	reg [31:0] EX_MEM_IR;
	reg [31:0] EX_MEM_ALUOut;
	reg [31:0] EX_MEM_B;
	reg EX_MEM_cond;
	reg [31:0] MEM_WB_IR;
	reg [31:0] MEM_WB_ALUOut;
	reg [31:0] MEM_WB_LMD;

	reg [31:0] Reg [0:31];
	reg [31:0] Mem [0:1023];

	parameter ADD=6'b000000;
	parameter SUB=6'b000001;
	parameter AND=6'b000010;
	parameter OR=6'b000011;
	parameter SLT=6'b000100;
	parameter MUL=6'b000101;
	parameter HLT=6'b111111;
	parameter LW=6'b001000;
	parameter SW=6'b001001;
	parameter ADDI=6'b001010;
	parameter SUBI=6'b001011;
	parameter SLTI=6'b001100;
	parameter BNEQZ=6'b001101;
	parameter BEQZ=6'b001110; 

	parameter RR_ALU= 3'b000;
	parameter RM_ALU=3'b001;
	parameter LOAD=3'b010;
	parameter STORE=3'b011;
	parameter BRANCH=3'b100;
	parameter HALT=3'b101;

	reg HALTED;			//set after HALted instrcn
	reg TAKEN_BRANCH;	//req to disable instrcn after branch

	always @(posedge clk1)   //IF stage
		if(HALTED == 0)
			begin
				if(((EX_MEM_IR[31:26] == BEQZ) && (EX_MEM_cond == 1)) || ((EX_MEM_IR[31:26] == BNEQZ) && (EX_MEM_cond == 0)))
					begin
						IF_ID_IR <= #2 Mem[EX_MEM_ALUOut];
						TAKEN_BRANCH <= #2 1'b1;
						IF_ID_NPC <= #2 EX_MEM_ALUOut + 1;
						PC <= #2 EX_MEM_ALUOut + 1;
					end
					
				else
					begin
						IF_ID_IR <= #2 Mem[PC];
						IF_ID_NPC <= #2 PC + 1;
						PC <= #2 PC + 1;
					end
			end

	always @(posedge clk2)    //ID Stage
		if(HALTED == 0)
			begin
				if(IF_ID_IR[25:21] == 5'b00000)
					ID_EX_A <= 0;
					
				else
					ID_EX_A <= #2 Reg[IF_ID_IR[25:21]];  //rs
					
				if(IF_ID_IR[20:16] == 5'b00000)
					ID_EX_B <= 0;
					
				else
					ID_EX_B <= #2 Reg[IF_ID_IR[20:16]];   //rt
					
				ID_EX_NPC <= #2 IF_ID_NPC;
				ID_EX_IR <= #2 IF_ID_IR;
				ID_EX_Imm <= #2 {{16{IF_ID_IR[15]}} , {IF_ID_IR[15:0]}};
				
				case(IF_ID_IR[31:26])
					ADD: ID_EX_type <= #2 RR_ALU;
					SUB: ID_EX_type <= #2 RR_ALU;
					AND: ID_EX_type <= #2 RR_ALU;
					OR: ID_EX_type <= #2 RR_ALU;
					SLT: ID_EX_type <= #2 RR_ALU;
					MUL: ID_EX_type <= #2 RR_ALU;
					ADDI: ID_EX_type <= #2 RM_ALU;
					SUBI: ID_EX_type <= #2 RM_ALU;
					SLTI: ID_EX_type <= #2 RM_ALU;
					LW: ID_EX_type <= #2 LOAD;
					SW: ID_EX_type <= #2 STORE;
					BNEQZ: ID_EX_type <= #2 BRANCH;
					BEQZ: ID_EX_type <= #2 BRANCH;
					HLT:  ID_EX_type <= #2 HALT;
					default:  ID_EX_type <= #2 HALT;
					
				endcase	
					
			end
			
	always @(posedge clk1)  //EX stage
	if(HALTED == 0)
			begin
				EX_MEM_type <= #2 ID_EX_type;
				EX_MEM_IR <= #2 ID_EX_IR;
				TAKEN_BRANCH <= #2 0;
				
				case(ID_EX_type)
					RR_ALU:begin
						case(ID_EX_IR[31:26]) //opcode
							
							ADD: EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_B;
							SUB: EX_MEM_ALUOut <= #2 ID_EX_A - ID_EX_B;
							AND: EX_MEM_ALUOut <= #2 ID_EX_A & ID_EX_B;
							OR : EX_MEM_ALUOut <= #2 ID_EX_A | ID_EX_B;
							SLT: EX_MEM_ALUOut <= #2 ID_EX_A < ID_EX_B;
							MUL: EX_MEM_ALUOut <= #2 ID_EX_A * ID_EX_B;
							default: EX_MEM_ALUOut <= #2 32'hxxxx;
							endcase
							end
							
					RM_ALU: begin
								case (ID_EX_IR[31:26]) 
								ADDI: EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_Imm;
								SUBI: EX_MEM_ALUOut <= #2 ID_EX_A - ID_EX_Imm;
								SLTI: EX_MEM_ALUOut <= #2 ID_EX_A < ID_EX_Imm;
								default: EX_MEM_ALUOut <= #2 32'hxxxxxxxx;
								endcase
								end	
							
							
						LOAD:
							begin
								EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_Imm;
								EX_MEM_B <= #2 ID_EX_B;
							end
							
							
						STORE:
							begin
								EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_Imm;
								EX_MEM_B <= #2 ID_EX_B;
							end

						BRANCH:
							begin
								EX_MEM_ALUOut <= #2 ID_EX_NPC + ID_EX_Imm;
								EX_MEM_B <= #2 (ID_EX_A == 0);	
							end
				endcase
			end
			
	always @(posedge clk2)    //MEM stage
	if(HALTED ==0)
			begin
				MEM_WB_type <= EX_MEM_type;
				MEM_WB_IR <= #2 EX_MEM_IR;
				
					case (EX_MEM_type)
					
					RR_ALU : MEM_WB_ALUOut <= #2 EX_MEM_ALUOut;
					RM_ALU : MEM_WB_ALUOut <= #2 EX_MEM_ALUOut;
					LOAD : MEM_WB_LMD <= #2 Mem[EX_MEM_ALUOut];
					STORE : if(TAKEN_BRANCH == 0)    //disable write
										Mem[EX_MEM_ALUOut] <= EX_MEM_B;
					endcase					
			end
			
			
	always @(posedge clk1)       //WB stage
			begin
				if(TAKEN_BRANCH == 0)    //disable write if branch taken
				case(MEM_WB_type)
					RR_ALU: Reg[MEM_WB_IR[15:11]] <= #2 MEM_WB_ALUOut;  //rd
					RM_ALU: Reg[MEM_WB_IR[20:16]] <= #2 MEM_WB_ALUOut;  //rt
					LOAD: Reg[MEM_WB_IR[20:16]] <= #2 MEM_WB_LMD;   //rt
					HALT : HALTED <= #2 1'b1;
				endcase	
			end


	endmodule
