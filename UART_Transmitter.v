module UART_Transmitter(reset, clk, Tx_DATA, baud_select, Tx_WR, Tx_EN, TxD, Tx_BUSY);
input reset, clk;
input [7:0] Tx_DATA;
input [2:0] baud_select;
input Tx_EN;			//Tx is active
input Tx_WR;			//wnat to load data from Tx_DATA

output TxD;				//serial transmission
output reg Tx_BUSY;

wire Tx_sample_ENABLE;

parameter	IDLE 				= 5'd1,
			START_BIT 			= 5'd2,
			DATA_BITS 			= 5'd3,
			PARITY_BIT 			= 5'd4,
			STOP_BIT 			= 5'd5;

reg [3:0] data_counter, data_counter_next;
reg [4:0] Tx_state, Tx_next_state;
reg [2:0] bit_count, bit_count_next;
reg [7:0] b_reg, b_next;
reg Tx_bit, Tx_bit_next;

always @(posedge clk or posedge reset)
begin
	if (reset) 
	begin
		Tx_state = IDLE;
		data_counter = 4'd0;
		bit_count = 3'd0;
		b_reg = 8'd0;
		Tx_bit = 1'b1;
	end
	else
	begin
		Tx_state = Tx_next_state;
		data_counter = data_counter_next;
		bit_count = bit_count_next;
		b_reg = b_next;
		Tx_bit = Tx_bit_next;
	end
end

always @ (*)
begin
	Tx_BUSY = 1'b0; //added (multiple drives when it was on posedge)
	data_counter_next = data_counter;
	Tx_next_state = Tx_state;
	bit_count_next = bit_count;
	Tx_bit_next = Tx_bit;
	b_next = b_reg;
	case (Tx_state)
		IDLE:
		begin
			Tx_bit_next = 1'b1;
			if(Tx_EN && Tx_WR)
			begin
				Tx_next_state = START_BIT;
				data_counter_next = 4'd0;
				b_next = Tx_DATA;
			end
			else
				Tx_next_state = IDLE;
		end
		START_BIT:
		begin
			Tx_BUSY = 1'b1;
			Tx_bit_next = 1'b0;
			if(Tx_sample_ENABLE)
			begin
				if(data_counter == 4'd15)
				begin
					Tx_next_state = DATA_BITS;
					bit_count_next = 3'd0;
					data_counter_next = 4'd0;
				end
				else
					data_counter_next = data_counter + 1'b1;
			end
		end
		DATA_BITS:
		begin
			Tx_BUSY = 1'b1;
			Tx_bit_next = b_reg[0];
			if(Tx_sample_ENABLE)
			begin 
				if (data_counter == 4'd15)
				begin
					data_counter_next = 4'b0000;
					b_next = b_reg >> 1;
					if(bit_count == 3'b111)
						Tx_next_state = PARITY_BIT;
					else
						bit_count_next = bit_count + 1'b1;
				end
				else
					data_counter_next = data_counter + 1'b1;
			end	
		end
		PARITY_BIT:
		begin
			Tx_BUSY = 1'b1;
			Tx_bit_next = ^Tx_DATA;
			if(Tx_sample_ENABLE)
			begin
				if  (data_counter == 4'd15)
				begin
					data_counter_next = 4'b0000;
					Tx_next_state = STOP_BIT;
				end
				else
					data_counter_next = data_counter + 1'b1;
			end
		end
		STOP_BIT:
		begin
			Tx_bit_next = 1'b1;
			Tx_BUSY = 1'b1;
			if(Tx_sample_ENABLE)
			begin	
				if (data_counter == 4'd15)
				begin
					data_counter_next = 4'd0;
					Tx_next_state = IDLE;
				end
				else
					data_counter_next = data_counter + 1'b1;
			end
			
		end
		default:
		begin
			Tx_next_state = IDLE;
		end
	endcase
end

assign TxD = Tx_bit;
BaudController BaudController_Tx_INST(reset, clk, baud_select, Tx_sample_ENABLE);

endmodule