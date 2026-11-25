`timescale 1ns / 1ps 

// binary to gray convertor
module b2g_convertor #(
	parameter WIDTH = 4
)(
	input logic [WIDTH-1:0] i_bin,
	output logic [WIDTH-1:0] o_gray
);
	assign o_gray = i_bin ^ (i_bin >> 1);
    
endmodule