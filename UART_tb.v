module UART_tb;

	// Inputs
	reg reset;
	reg clk;
	reg [2:0] baud_select;
	reg [7:0] data;
	reg Tx_EN;
	reg Tx_WR;
	reg Rx_EN;

	// Outputs
	wire [7:0] Received_Data;
	wire busy;
	wire frame_error;
	wire parity_error;
	wire valid;

	//string output?
	reg [5*8:0] Rx_state_string;
	reg [5*8:0] Tx_state_string;

	// Instantiate the Unit Under Test (UUT)
	UART uut (
		.reset(reset), 
		.clk(clk), 
		.baud_select(baud_select), 
		.data(data), 
		.Tx_EN(Tx_EN), 
		.Tx_WR(Tx_WR), 
		.Rx_EN(Rx_EN), 
		.Received_Data(Received_Data), 
		.busy(busy), 
		.frame_error(frame_error), 
		.parity_error(parity_error), 
		.valid(valid)
	);

	reg [1:0] counter;
	initial begin
		// Initialize Inputs
		reset = 1;
		clk = 0;
		data = 8'b0000000;
		#10 reset = 1'b0;
		data = 8'b10101010;
		baud_select = 3'b111;
		
		Tx_EN = 1;
		Tx_WR = 1;
		Rx_EN = 1;
		counter = 2'b00;
		#100 counter = counter + 1'b1;
	end
	
	
	
	always@(valid)
	begin
		if(~valid && (counter == 2'b01))
		begin
			counter = counter +1'b1;
			reset = 1'b1;
			Tx_EN = 0;
			Rx_EN = 0;
			Tx_WR = 0;
			#100
			reset = 1'b0;
			data = 8'b01010101;
			Tx_EN = 1;
			Rx_EN = 1;
			Tx_WR = 1;
		end
		else if(~valid && (counter == 2'b10))
		begin
			counter = counter + 1'b1;
			reset = 1'b1;
			Tx_EN = 0;
			Rx_EN = 0;
			Tx_WR = 0;
			#100
			reset = 1'b0;
			data = 8'b11001100;
			Tx_EN = 1;
			Rx_EN = 1;
			Tx_WR = 1;
		end
		else if(~valid && (counter == 2'b11))
		begin
			counter = counter + 1'b1;
			reset = 1'b1;
			Tx_EN = 0;
			Rx_EN = 0;
			Tx_WR = 0;
			#100
			reset = 1'b0;
			data = 8'b11001100;
			Tx_EN = 1;
			Rx_EN = 1;
			Tx_WR = 1;
		end
		else
		begin
			counter = counter;
			data = data;
		end
	end
   always #10 clk=~clk;
   

endmodule

