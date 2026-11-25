`timescale 1ns / 1ps

module async_fifo #(
	parameter DATA_WIDTH = 8,
	parameter DEPTH = 16
)(
	input logic i_wr_clk,
	input logic i_rst, // synchronous to write clock
	input logic [DATA_WIDTH-1:0] i_wr_data,
	input logic i_wr_en,
	input logic i_rd_clk,
	input logic i_rd_en,
	output logic [DATA_WIDTH-1:0] o_rd_data,
	output logic empty,
	output logic full
);

	localparam ADDR_WIDTH = $clog2(DEPTH);
	
	(* ASYNC_REG == "True" *) logic rd_rst_meta;
	(* ASYNC_REG == "True" *) logic rd_rst_sync;
	
	(* ASYNC_REG == "True" *) logic [ADDR_WIDTH:0] wr_ptr_gray_meta;
	(* ASYNC_REG == "True" *) logic [ADDR_WIDTH:0] wr_ptr_gray_sync;
	
	(* ASYNC_REG == "True" *) logic [ADDR_WIDTH:0] rd_ptr_gray_meta;
	(* ASYNC_REG == "True" *) logic [ADDR_WIDTH:0] rd_ptr_gray_sync;
	
	logic [ADDR_WIDTH:0] wr_ptr, wr_ptr_gray;
	logic [ADDR_WIDTH:0] rd_ptr, rd_ptr_gray;
	logic [DATA_WIDTH-1:0] mem [DEPTH];
	
	// 2-FF Read clock domain reset 
	always_ff @(posedge i_rd_clk) begin 
		rd_rst_meta <= i_rst;
		rd_rst_sync <= rd_rst_meta;
	end
	
	// 2-FF to sync wr_ptr to rd domain 
	always_ff @(posedge i_rd_clk) begin 
		if (rd_rst_sync ) begin 
			wr_ptr_gray_meta <= 0;
			wr_ptr_gray_sync <= 0;
		end else begin 
			wr_ptr_gray_meta <= wr_ptr_gray;
			wr_ptr_gray_sync <= wr_ptr_gray_meta ;
		end
	end
	
	// 2-FF to sync rd_ptr to wr domain 
	always_ff @(posedge i_wr_clk) begin 
		if (i_rst) begin 
			rd_ptr_gray_meta <= 0;
			rd_ptr_gray_sync <= 0;
		end else begin 
			rd_ptr_gray_meta  <= rd_ptr_gray;
			rd_ptr_gray_sync <= rd_ptr_gray_meta  ;
		end
	end
	
	// Write domain 
	always_ff @(posedge i_wr_clk) begin 
		if (i_rst) begin 
			wr_ptr <= 0;
		end else begin 
			if (i_wr_en && !full) begin
				mem[wr_ptr[ADDR_WIDTH-1:0]] <= i_wr_data;
				wr_ptr <= wr_ptr + 1;
			end
		end
	end
	
	// Read domain 
	always_ff @(posedge i_rd_clk) begin 
		if (rd_rst_sync ) begin 
			rd_ptr <= 0;
			o_rd_data <= 0;
		end else begin 
			if (i_rd_en && !empty) begin
				o_rd_data <= mem[rd_ptr[ADDR_WIDTH-1:0]];
				rd_ptr <= rd_ptr + 1;
			end
		end
	end
	
	assign empty = (rd_ptr_gray == wr_ptr_gray_sync);
	assign full = (wr_ptr_gray == {
								~rd_ptr_gray_sync[ADDR_WIDTH:ADDR_WIDTH-1],
						     rd_ptr_gray_sync[ADDR_WIDTH-2:0]});
	
	b2g_convertor #(
		.WIDTH(ADDR_WIDTH+1)
	) wr_ptr_gray_inst (
			.i_bin(wr_ptr),
			.o_gray(wr_ptr_gray)
	);
	
	b2g_convertor #(
		.WIDTH(ADDR_WIDTH+1)
	) rd_ptr_gray_inst (
			.i_bin(rd_ptr),
			.o_gray(rd_ptr_gray)
	);
	
	
	