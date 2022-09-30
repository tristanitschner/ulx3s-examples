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

module top_sound(
	input wire  clk_25mhz,
	output wire [3:0] audio_l,
	output wire [3:0] audio_r
);

parameter used_bits = 14;

reg [used_bits-1:0] audio_data [0:2**18-1];
initial $readmemh("audio.mem", audio_data);

// get a 44100 clock in here
// 25_000_000 / 44100 = 557
localparam divider = 557;
reg [$clog2(divider)-1:0] audio_clk_counter = 0;
always @(posedge clk_25mhz)
	if (audio_clk_counter == divider - 1)
		audio_clk_counter <= 0;
	else
		audio_clk_counter <= audio_clk_counter + 1;

wire audio_clk = (audio_clk_counter == 0); // high for one clk

reg [17:0] sample_counter = 0;
always @(posedge clk_25mhz)
	if (audio_clk)
		sample_counter <= sample_counter + 1;

reg [used_bits-1:0] current_audio;
always @(posedge clk_25mhz)
	current_audio <= audio_data[sample_counter];


wire [3:0] audio_o;
delta_sigma #(
	.inbits  (used_bits),
	.outbits (4)
) delta_sigma_inst (
	.clk (clk_25mhz),
	.audio_i (current_audio[$bits(current_audio)-1-:used_bits]),
	.audio_o
);

assign audio_l = audio_o;
assign audio_r = audio_o;

endmodule
