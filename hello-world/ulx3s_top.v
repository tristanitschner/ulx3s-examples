//  Copyright (C) 2022  Tristan Itschner
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

// Description:
// 		A true "Hello World!" example for an FPGA board.

`default_nettype none 

`include "pll.v"
`include "uart_tx.v"

module ulx3s_top (
	input clk_25mhz,

	// these are switched, see constraints
	output ftdi_rxd,
	input  ftdi_txd,
	input  ftdi_nrts,
	input  ftdi_ndtr,
	input  ftdi_txden,

	output [7:0] led,

	input [6:0] btn,

	input [3:0] sw,
);

wire clk_100mhz;
wire LOCK;

pll pll_i (
	.CLKI  ( clk_25mhz  ),
	.CLKOP ( clk_100mhz ),
	.LOCK
);

reg [26:0] divider;
always @(posedge clk_100mhz)
	divider <= divider + 1;

// just so we see that the board is actually active
assign led[6:0] = divider[26:20];

reg [26:0] trigger = 0;
always @(posedge clk_100mhz) begin
	if (btn[1])
		trigger <= trigger + 1;
	else
		trigger <= 0;
end

wire start = &(trigger[22:0]);

reg [8*13-1:0] hello_world = "Hello World!\n";
reg [3:0] charcounter = 0;

reg running = 0;
reg send = 0;
always @(posedge clk_100mhz)
	if (charcounter >= 13) begin
		send <= 0;
		running <= 0;
		charcounter <= 0;
	end
	else if (charcounter == 0) begin
		if (!running && start && !busy) begin
			running <= 1;
			send <= 1;
			txdata <= hello_world[8*13-1-:8];
			charcounter <= charcounter + 1;
		end
	end
	else if (running) begin
		if (send && busy) 
			send <= 0;
		else if (!send && !busy) begin
			charcounter <= charcounter + 1;
			send <= 1;
			txdata <= hello_world[8*13-1-8*(charcounter)-:8];
		end
	end

wire busy;
reg [7:0] txdata;
uart_tx #(
	.freq_hz  (100_000_000),
	.baudrate (115_200)
) uart_tx_inst (
	.clk   (clk_100mhz),
	.idata (txdata),
	.send  (send),
	.busy  (busy),
	.tx    (ftdi_rxd)
);

endmodule
