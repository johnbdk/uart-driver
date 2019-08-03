//Module that selects the 4 addresses to be printed , and shifts the message(addresses) if the button is pressed

module MemoryCounter(clk,reset,button,adr3,adr2,adr1,adr0);
	
	input clk,reset,button;
	output [3:0] adr0,adr1,adr2,adr3;
	
	//wire Rx_FERROR,Rx_PERROR,Rx_VALID;
	reg [7:0] Tx_DATA;
	//wire [7:0] Rx_DATA;
	//wire Tx_EN;
	
	
	
	always@(posedge clk or posedge reset)
		begin
			if(reset == 1)
			begin
				Tx_DATA = 8'b00000000; 
			end 
			else
			 begin
	
				if(button == 1)
				begin
					Tx_DATA = Tx_DATA + 1'b1;
				end
				
			end
		end
		
		assign adr0 = Tx_DATA[7:4];
		assign adr1 = Tx_DATA[3:0];
		assign adr2 = Tx_DATA[7:4];
		assign adr3 = Tx_DATA[3:0];
		
endmodule
