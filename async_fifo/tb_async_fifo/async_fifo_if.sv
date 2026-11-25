interface async_fifo_if #(
    parameter DATA_WIDTH = 8;
)(
    input logic i_wr_clk,
    input logic i_rd_clk,
);
    logic                  i_rst, 
	logic [DATA_WIDTH-1:0] i_wr_data,
	logic                  i_wr_en,
	logic                  i_rd_en,
	logic [DATA_WIDTH-1:0] o_rd_data,
	logic                  o_empty,
	logic                  o_full

endinterface