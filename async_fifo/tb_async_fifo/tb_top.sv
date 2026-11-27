module tb_top;

    localparam DATA_WIDTH = 8;
    localparam DEPTH = 16;

    async_fifo_if #(
        .DATA_WIDTH(DATA_WIDTH)
    ) aif (
        .i_wr_clk (i_wr_clk),
        .i_rd_clk (i_rd_clk)
    );

    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) async_fifo_inst (
        .i_wr_clk  (aif.i_wr_clk),
        .i_rst     (aif.i_rst),
        .i_wr_data (aif.i_wr_data),
        .i_wr_en   (aif.i_wr_en),
        .i_rd_clk  (aif.i_rd_clk),
        .i_rd_en   (aif.i_rd_en),
        .o_rd_data (aif.o_rd_data),
        .o_empty   (aif.o_empty),
        .o_full    (aif.o_full)
    );

    always #5 i_wr_clk = ~i_wr_clk;  // 100MHz
    always #10 i_wr_clk = ~i_wr_clk; // 50MHz

    initial begin 


    end
endmodule 