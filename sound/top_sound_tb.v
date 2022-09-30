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

`timescale 1ns/1ps
`default_nettype none

module top_sound_tb;

reg clk = 1;
initial forever #25 clk = !clk;

initial begin
	$dumpfile("top_sound_tb.vcd");
	$dumpvars;
end

initial begin
	#1000000000 $finish;
end

wire [3:0] audio_l;
wire [3:0] audio_r;

top_sound top_sound_inst(
	.clk_25mhz (clk),
	.audio_l,
	.audio_r
);

endmodule
