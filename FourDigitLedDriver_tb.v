module FourDigitLEDdriver_tb;

reg clk, reset,button;
wire an3, an2, an1, an0;
wire a, b, c, d, e, f, g, dp;

FourDigitLEDdriver FourDigitLEDdriverINST(reset, clk, button, an3, an2, an1, an0, a, b, c, d, e, f, g, dp);

initial 
begin 
	clk = 0;
	#50 reset = 1'b0;

	
	#150 reset = 1'b1;
	#1000 reset = 1'b0;
	#100 button = 1'b1;
	#400 button = 0;
	#1000000 button = 1;
	#400 button = 0;
end

always
begin
	#10 clk = ~clk;
end


endmodule