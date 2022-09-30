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

module delta_sigma(
	input wire clk,
	input wire [inbits-1:0] audio_i,
	output reg [outbits-1:0] audio_o
);

parameter inbits = 16;
parameter outbits = 4;

localparam N = 2**(inbits - outbits);
reg [$clog2(N)-1:0] counter;

// pcm counter
always @(posedge clk)
	if (counter == N - 1)
		counter <= 0;
	else 
		counter <= counter + 1;

// module least significant bit
always @(posedge clk)
	if (audio_i[inbits-outbits-1:0] > counter && !(&(audio_i[inbits-1:inbits-outbits])))
		audio_o <= audio_i[inbits-1:inbits-outbits] + 1;
	else
		audio_o <= audio_i[inbits-1:inbits-outbits];

endmodule
