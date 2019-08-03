/************************************************************************
* This module implements a memory structure where values 0,1,...,F are	*
* stored. Given four addresses, outputs four characters which will then *
* be decoded by another module.										 	*
************************************************************************/
module Memory(addr3, addr2, addr1, addr0, reset, char3, char2, char1, char0);

input [3:0] addr3, addr2, addr1, addr0;
input reset;
output [3:0] char3, char2, char1, char0;

reg [3:0] memory [15:0];

always@(posedge reset)
begin
	memory[0] = 4'b1010;
	memory[1] = 4'b1010;
	memory[2] =	4'b0101;
	memory[3] = 4'b0101;
	memory[4] = 4'b1100;
	memory[5] = 4'b1100;
	memory[6] = 4'b1000;
	memory[7] = 4'b1001;
	memory[8] = 4'b1010;
	memory[9] = 4'b1010;
	memory[10] = 4'b0101;
	memory[11] = 4'b0101;
	memory[12] = 4'b1100;
	memory[13] = 4'b1100;
	memory[14] = 4'b1000;
	memory[15] = 4'b1001;
end

assign char0 = memory[addr0];
assign char1 = memory[addr1];
assign char2 = 4'b0000;
assign char3 = 4'b0000;

endmodule