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

// Direct digital synthesis

`define M_PI 3.141592

module sound(
	input wire clk,
	input wire [PHASEWIDTH-1:0] fsel,
	input wire [1:0] mode, // 0 = sine, 1 = sawtooth, 2 = triangle, 3 = unused
	output reg [RESOLUTION-1:0] audio
);

parameter RESOLUTION = 14;
parameter SAMPLES = 2**12;
parameter PHASEWIDTH = 48;

reg [RESOLUTION-1:0] sine_lookup [SAMPLES-1:0];
initial begin
	integer i;
	for (i = 0; i < SAMPLES; i += 1) begin
		sine_lookup[i] = ((2**(RESOLUTION - 1) - 1)
											*($sin(2*`M_PI*i/SAMPLES) + 1.0));
	end
end

reg [RESOLUTION-1:0] sawtooth_lookup [SAMPLES-1:0];
initial begin
	integer i;
	for (i = 0; i < SAMPLES; i += 1) begin
		sawtooth_lookup[i] = (2**(RESOLUTION) - 1)*i/SAMPLES;
	end
end

reg [RESOLUTION-1:0] triangle_lookup [SAMPLES-1:0];
initial begin
	integer i;
	for (i = 0; i < SAMPLES; i += 1) begin
		if (i < (SAMPLES >> 1)) 
			triangle_lookup[i] = (2*2**(RESOLUTION) - 1)*i/SAMPLES;
		else
			triangle_lookup[i] = (2**(RESOLUTION) - 1) 
						- (2*2**(RESOLUTION) - 1)*(i - (SAMPLES >> 1))/SAMPLES;
	end
end

reg [PHASEWIDTH-1:0] phase = 0;
always @(posedge clk)
	phase <= phase + fsel;

always @(posedge clk)
	case (mode)
		0: audio <=     sine_lookup[phase[31-:$clog2(SAMPLES)]];
		1: audio <= sawtooth_lookup[phase[31-:$clog2(SAMPLES)]];
		2: audio <= triangle_lookup[phase[31-:$clog2(SAMPLES)]];
		default: ;
	endcase

endmodule
