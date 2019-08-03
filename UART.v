`include "UART_Receiver.v"
`include "UART_Transmitter.v"
`include "BaudController.v"
module UART(reset, clk, baud_select, data, Tx_EN, Tx_WR,Rx_EN, Received_Data, busy, frame_error, parity_error,valid);

input reset;
input clk;
input [2:0] baud_select;
input [7:0] data;
input Tx_EN, Tx_WR;
input Rx_EN;


output [7:0] Received_Data;
output busy;
output frame_error;
output parity_error;
output valid;

wire transmission;
wire [7:0] Rx_DATA;
wire Tx_BUSY;
wire Rx_PERROR, Rx_FERROR;
wire Rx_VALID;

UART_Receiver UART_Receiver_INST(.reset(reset), .clk(clk), .Rx_DOUT(Rx_DATA), .baud_select(baud_select), .Rx_EN(Rx_EN), .RxD(transmission),.Rx_FERROR(Rx_FERROR), .Rx_PERROR(Rx_PERROR), .Rx_VALID(Rx_VALID));
UART_Transmitter UART_Transmitter_INST(.reset(reset), .clk(clk), .Tx_DATA(data), .baud_select(baud_select), .Tx_WR(Tx_WR), .Tx_EN(Tx_EN), .TxD(transmission), .Tx_BUSY(Tx_BUSY));
assign Received_Data = Rx_DATA;
assign busy = Tx_BUSY;
assign frame_error = Rx_FERROR;
assign parity_error = Rx_PERROR;
assign valid = Rx_VALID;

endmodule