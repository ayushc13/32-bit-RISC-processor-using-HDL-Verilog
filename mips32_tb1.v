`timescale 1ns / 1ps
`include "mips32.v"

//  TEST BENCH TO ADD THREE NOS 10 , 20 AND 25


module mips32_tb1;

	// Inputs
	reg clk1;
	reg clk2;

	integer k;

	// Instantiate the Unit Under Test (UUT)
	mips32 uut (
		.clk1(clk1), 
		.clk2(clk2)
	);

	initial
	begin
		// Initialize Inputs
		clk1 = 0;
		clk2 = 0;
	repeat(200)
		begin
			#5 clk1 = 1; #5 clk1 = 0;
			#5 clk2 = 1; #5 clk2 = 0;
		end

	end
	
	
	initial
		begin	

			for(k=0 ; k<31 ; k = k + 1)
				uut.Reg[k] = k;
				
			uut.Mem[0] = 32'h2801000a; // ADDI R1,R0,10                0010 1000 0000 0001 0000 0000 1010
			uut.Mem[1] = 32'h28020014; // ADDI R2,R0,20                0010 1000 0000 0010 0000 0001 0100
			uut.Mem[2] = 32'h28030019; // ADDI R3,R0,25					0010 1000 0000 0011 0000 0000 0001 1001
			uut.Mem[3] = 32'h0ce77800; // OR R7,R7,R7 -- dummy instr.	
			uut.Mem[4] = 32'h0ce77800; // OR R7,R7,R7 -- dummy instr.
			uut.Mem[5] = 32'h0ce77800; // OR R7,R7,R7 -- dummy instr.
			uut.Mem[6] = 32'h00222000; // ADD R4,R1,R2
			uut.Mem[7] = 32'h0ce77800; // OR R7,R7,R7 -- dummy instr.
			uut.Mem[8] = 32'h00832800; // ADD R5,R4,R3
			uut.Mem[9] = 32'hfc000000; // HLT	
		
			uut.HALTED = 0;
			uut.PC = 0;
			uut.TAKEN_BRANCH = 0;

				#280
				for (k=0; k<6; k= k+1)
					$display ("R%1d - %2d", k, uut.Reg[k]);
			end
				initial
				begin
					$dumpfile ("mips32_tb1.vcd");
					$dumpvars (0, mips32_tb1);
					#300 $finish;				
				end
      
endmodule

