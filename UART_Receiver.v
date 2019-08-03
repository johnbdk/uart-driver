module UART_Receiver(reset, clk, Rx_DOUT, baud_select, Rx_EN, RxD,Rx_FERROR, Rx_PERROR, Rx_VALID);
input reset, clk;
input [2:0] baud_select;
input Rx_EN;
input RxD;
wire Rx_sample_ENABLE;

output reg [7:0] Rx_DOUT;
output wire Rx_FERROR; // Framing Error //
output wire Rx_PERROR; // Parity Error //
output wire Rx_VALID; // Rx_DATA is Valid //

parameter		IDLE			= 5'd1,
				RECEIVE_START	= 5'd2,
				RECEIVE_DATA	= 5'd3,
				RECEIVE_PARITY	= 5'd4,
				RECEIVE_STOP	= 5'd5;

reg [2:0] bit_count, bit_count_next;
reg [3:0] data_counter, data_counter_next;
reg [4:0] Rx_state, Rx_next_state;
reg [7:0] Rx_DATA_next, Rx_DATA;

always@(posedge clk or posedge reset)
begin
	if(reset)begin
		Rx_state = IDLE;
		data_counter = 4'b0000;
		bit_count = 3'b000;
		Rx_DATA = 8'd0;
	end
	else
	begin
		Rx_state = Rx_next_state;
		data_counter = data_counter_next;
		bit_count = bit_count_next;
		Rx_DATA = Rx_DATA_next;
	end
end

always@(*)
begin
	data_counter_next = data_counter;
	Rx_next_state = Rx_state;
	bit_count_next = bit_count;
	Rx_DATA_next = Rx_DATA;
	Rx_DOUT = Rx_DOUT;
	case(Rx_state)
		IDLE:
		begin
			if(Rx_EN && ~RxD) begin
				Rx_next_state = RECEIVE_START;			
				Rx_DATA_next = 8'd0;
				data_counter_next = 4'b0000;
			end
		end
		RECEIVE_START:
		begin
			if(Rx_sample_ENABLE)						
			begin
				if(data_counter == 4'b0111)
				begin
					if(RxD) 							// Frame error on start bit
					begin
						Rx_next_state = IDLE;
						data_counter_next = 4'b0000;
					end
					else
					begin
						Rx_next_state = RECEIVE_DATA;
						data_counter_next = 4'b0000;
						bit_count_next = 3'b000;
					end
				end
				else begin
					data_counter_next = data_counter + 1'b1;
				end
			end
		end
		RECEIVE_DATA:
		begin
			if(Rx_sample_ENABLE)
			begin
				if(data_counter == 4'b1111)
				begin
					Rx_DATA_next = {RxD, Rx_DATA[7:1]};
					data_counter_next = 4'b0000;
					if(bit_count == 3'b111)
						Rx_next_state = RECEIVE_PARITY;
					else
						bit_count_next = bit_count + 1'b1;
				end
				else data_counter_next = data_counter + 1'b1;
			end
		end
		RECEIVE_PARITY:
		begin
			if(Rx_sample_ENABLE)
			begin
				if(data_counter == 4'b1111)
				begin
					Rx_next_state = RECEIVE_STOP;
					data_counter_next = 4'b0000;
				end else 
					data_counter_next = data_counter + 1'b1;
			end
		end
		RECEIVE_STOP:
		begin
			if(Rx_sample_ENABLE)
			begin
				if(data_counter == 4'b1111)
				begin
					if(~Rx_FERROR && ~Rx_PERROR)
					begin
						Rx_DOUT = Rx_DATA;
					end
					Rx_next_state = IDLE;
					data_counter_next = 4'b0000;

				end else 
					data_counter_next = data_counter + 1'b1;
			end
		end
	endcase
end

assign Rx_VALID = ((Rx_state == RECEIVE_STOP ) && (Rx_sample_ENABLE) && (&data_counter) && (~Rx_FERROR && ~Rx_PERROR));
assign Rx_FERROR = (((Rx_state == RECEIVE_STOP) && (Rx_sample_ENABLE) && (&data_counter) && (~RxD)) ||
					 ((Rx_state == RECEIVE_START) && (Rx_sample_ENABLE) && (data_counter == 4'b0111) && RxD));
assign Rx_PERROR = ((Rx_state == RECEIVE_PARITY) && (Rx_sample_ENABLE) && (&data_counter) && ((^Rx_DATA) != RxD));

BaudController baud_controller_rx_instance(reset, clk, baud_select, Rx_sample_ENABLE);

endmodule