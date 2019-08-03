`include "ledDecoder.v"
`include "debounceButton.v"
`include "DigitSelection.v"
`include "UART.v"

module FourDigitLEDdriver(reset, clk,button, an3, an2, an1, an0, a, b, c, d, e, f, g, dp);

input clk, reset;
input button;
output reg an3, an2, an1, an0;
output a, b, c, d, e, f, g, dp;

wire [7:0] data_in;
wire CLKDV;
wire [3:0] char;
wire reset_debounced;
wire CLK0;
wire increment;			//wire used to determine when the addresses need
						//to be incremented for a new character
wire [2:0] baud_select = 3'b111;
reg [2:0] next_state;
//reg [2:0] FSMstate;
wire Tx_WR;
wire Tx_EN, Rx_EN;

reg Tx_WR_temp;

DCM #(
  .SIM_MODE("SAFE"),  // Simulation: "SAFE" vs. "FAST", see "Synthesis and Simulation Design Guide" for details
  .CLKDV_DIVIDE(16.0), // Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
                      //   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
  .CLKFX_DIVIDE(1),   // Can be any integer from 1 to 32
  .CLKFX_MULTIPLY(4), // Can be any integer from 2 to 32
  .CLKIN_DIVIDE_BY_2("FALSE"), // TRUE/FALSE to enable CLKIN divide by two feature
  .CLKIN_PERIOD(20.0),  // Specify period of input clock
  .CLKOUT_PHASE_SHIFT("NONE"), // Specify phase shift of NONE, FIXED or VARIABLE
  .CLK_FEEDBACK("1X"),  // Specify clock feedback of NONE, 1X or 2X
  .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), // SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                        //   an integer from 0 to 15
  .DFS_FREQUENCY_MODE("LOW"),  // HIGH or LOW frequency mode for frequency synthesis
  .DLL_FREQUENCY_MODE("LOW"),  // HIGH or LOW frequency mode for DLL
  .DUTY_CYCLE_CORRECTION("TRUE"), // Duty cycle correction, TRUE or FALSE
  .FACTORY_JF(16'hC080),   // FACTORY JF values
  .PHASE_SHIFT(0),     // Amount of fixed phase shift from -255 to 255
  .STARTUP_WAIT("FALSE")   // Delay configuration DONE until DCM LOCK, TRUE/FALSE
) DCM_inst (
  .CLK0(CLK0),     // 0 degree DCM CLK output
  .CLKDV(CLKDV),   // Divided DCM CLK out (CLKDV_DIVIDE)
  .CLKFB(CLK0),   // DCM clock feedback
  .CLKIN(clk),   // Clock input (from IBUFG, BUFG or DCM)
  .RST(reset) // DCM asynchronous reset input
);


debounceButton debounceButton_reset(clk, reset, reset_debounced);
reg [7:0] data;
wire [6:0] temp;
wire [3:0] state;
reg [3:0] counter;

assign {a,b,c,d,e,f,g} = temp;
assign dp = 1'b1;

wire [7:0] Rx_DATA;
wire Tx_BUSY, Rx_FERROR, Rx_PERROR, Rx_VALID;
UART inst1(reset_debounced,clk,baud_select, data_in, Tx_EN, Tx_WR, Rx_EN, Rx_DATA, Tx_BUSY, Rx_FERROR, Rx_PERROR, Rx_VALID);
ledDecoder ledDecoderINST(char, temp);
DigitSelection DigitSelectionINST(Rx_DATA[7:4], Rx_DATA[3:0], data_in[7:4], data_in[3:0], state, char);
debounceButton debounceButton_button(clk, button, button_debounced);
assign state = counter;
assign data_in = data;
//22-bit counter, when max value is reached, a new character will be selected
reg [21:0] counter22;		
always@ (posedge CLKDV or posedge reset_debounced)
	if(reset_debounced)
		counter22 = 22'b0;
	else
	counter22 = counter22 + 1'b1;
	
assign increment = &counter22;


//anode counter
always@ (posedge CLKDV or posedge reset_debounced)
begin
	if(reset_debounced)
		begin
			counter = 4'b1111;
		end
	else
		begin
			counter = counter + 1'b1;
		end
end
	
always @(*)
begin
	case (counter)
		4'b1110 :
		begin
			an3 = 1'b0;
			an2 = 1'b1;
			an1 = 1'b1;
			an0 = 1'b1;
		end
		4'b1010 : 
		begin
			an3 = 1'b1;
			an2 = 1'b0;
			an1 = 1'b1;
			an0 = 1'b1;
		end
		4'b0110 : 
		begin
			an3 = 1'b1;
			an2 = 1'b1;
			an1 = 1'b0;
			an0 = 1'b1;
		end
		4'b0010 :
		begin
			an3 = 1'b1;
			an2 = 1'b1;
			an1 = 1'b1;
			an0 = 1'b0;
		end
		default:
		begin
			an3 = 1'b1;
			an2 = 1'b1;
			an1 = 1'b1;
			an0 = 1'b1;
		end
	endcase
end

assign Rx_EN = 1'b1;
assign Tx_EN = 1'b1;


parameter 	State_0 = 3'd0,
			State_1 = 3'd1,
			State_2 = 3'd2,
			State_3 = 3'd3;
reg [2:0] digit_state;
reg [2:0] digit_n_state;
assign Tx_WR = Tx_WR_temp;
always @(posedge CLKDV or posedge reset_debounced)
begin
	if(reset_debounced)
		digit_state <= State_0;
	else
		digit_state <= digit_n_state;
end

always @ (*)
begin
	case(digit_state)

	State_0:
	begin
		Tx_WR_temp = 1'b0;
		if (button_debounced && ~Tx_BUSY)
			digit_n_state = State_1;
	end
	State_1:
	begin
		Tx_WR_temp = 1'b1;
		data = 8'hAA;
		digit_n_state = State_2;
	end
	
	State_2:
	begin
		Tx_WR_temp = 1'b0;
		if (button_debounced && ~Tx_BUSY) 
			digit_n_state = State_3;
	end

	State_3:
	begin
		Tx_WR_temp = 1'b1;
		data = 8'hBB;
		digit_n_state = State_0;
	end
endcase
end
endmodule