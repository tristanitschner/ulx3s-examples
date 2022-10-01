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

`default_nettype none

module top_sound(
	input wire clk_25mhz,
	output wire [3:0] audio_l,
	output wire [3:0] audio_r,
	input  wire [6:0] btn
);

parameter RESOLUTION = 14;
parameter SAMPLES = 2*12;
parameter PHASEWIDTH = 48;

localparam M_one_hz = 344;
// FORMULA: M = frequency*(2^(PHASEWIDTH - RESOLUTION - 1))/25000000;
// localparam M = 48'd151182; // 440Hz

reg [PHASEWIDTH-1:0] M = 100*M_one_hz;
always @(posedge clk_25mhz)
	case ({btn[3], btn[4]})
		0:       M <= 100*M_one_hz;
		1:       M <= 50*M_one_hz;
		2:       M <= 200*M_one_hz;
		default: M <= 100*M_one_hz;
	endcase


reg [RESOLUTION-1:0] audio;
sound #(
	.RESOLUTION (RESOLUTION),
	.SAMPLES    (SAMPLES),
	.PHASEWIDTH (PHASEWIDTH)
) sound_inst (
	.clk  (clk_25mhz),
	.mode,
	.fsel (M),
	.audio
);

wire [1:0] mode = {btn[1], btn[2]};

wire [3:0] audio_o;
delta_sigma #(
	.inbits  (RESOLUTION),
	.outbits (4)
) delta_sigma_inst (
	.clk (clk_25mhz),
	.audio_i (audio),
	.audio_o
);

assign audio_l = audio_o;
assign audio_r = audio_o;

endmodule
