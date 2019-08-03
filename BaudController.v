module BaudController(reset, clk, baud_select, sample_ENABLE);
input reset, clk;
input [2:0] baud_select;
output sample_ENABLE;
reg [13:0] counter_max;
reg [13:0] counter;
reg temp_out;

always @(posedge clk)
begin
	case(baud_select)		//values - 1 because counter starts from 0
		3'b000:	counter_max = 14'd10416;	//300		(299.9904)
		3'b001: counter_max = 14'd2603;		//1200		(1200.0768) 
		3'b010: counter_max = 14'd650;		//4800		(4800.30722)
		3'b011:	counter_max = 14'd325;		//9600		(9585.88957)
		3'b100: counter_max = 14'd162;		//19200		(19171.7791)
		3'b101: counter_max = 14'd80;		//38400		(38580.2469)
		3'b110: counter_max = 14'd53;		//57600		(57870.3704)
		3'b111: counter_max = 14'd26;		//115200	(115740.741)
	endcase
end


always @(posedge clk or posedge reset)
begin
	if(reset) counter = 14'd0;

	else if(counter == counter_max)
	begin
		temp_out = 1'b1;
		counter = 14'd0;
	end
	else
	begin
		temp_out = 1'b0;
		if(~reset)
			counter = counter + 1'b1;
	end
end

assign sample_ENABLE = temp_out;
endmodule
