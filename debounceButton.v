module debounceButton(clk, buttin, deb_buttout);

input clk, buttin;
output reg deb_buttout;

reg [2:0] counter;	// enter delay to reach the safe state
reg ff1; 			// output from flipflop 1
reg ff2; 			// output from flipflop 2
wire async_button; 		// compare the output of two flipflops


always @(posedge clk)		//Two FF's in series for 1 cycle delay on buttin
begin
	ff1 = buttin;
end

always @(posedge clk)		//ff2 is the async output of second FF
begin
	ff2 = ff1;
end


assign async_button = ff2;
wire counter_max = &counter;	//when every bit of the counter is 1,
								//it has reached its max value


/*Counter to filter any remaning bounces
  only when the counter gets asyc = 1 for
  8 clock cycles we are sure that we have
  a debounced signal. Flag is used to 
  prevent output 1 for more than one cycles*/
reg flag;

always @(posedge clk)			
begin
	if(async_button)
	begin
		if (counter_max && flag)
		begin
			deb_buttout = 1'b1;
			flag = 1'b0;
		end
		else if (!flag)
		begin
			deb_buttout = 1'b0;
		end
		else begin
			counter = counter + 1'b1;
			deb_buttout = 1'b0;
		end
	end
	else
	begin
		counter = 1'b0;
		flag = 1'b1;
		deb_buttout = 1'b0;
	end
end
endmodule