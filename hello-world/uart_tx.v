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
// 		quick 'n dirty uart sender
//
// Features:
// 		* Failsave generics.
//
// Input is read when busy is low and send is high.

module uart_tx #(
	parameter freq_hz = 100_000_000,
	parameter baudrate = 115_200
) (
	input clk,

	input [7:0] idata,
	input send,
	output busy,

	output reg tx = 1
);

localparam ticks_per_baud = freq_hz/baudrate;
localparam baud_counter_width = $clog2(ticks_per_baud);

reg [baud_counter_width:0] baud_counter = 0;
always @(posedge clk) 
	if (baud_counter == (ticks_per_baud[baud_counter_width:0]-1))
		baud_counter <= 0;
	else 
		baud_counter <= baud_counter + 1'b1;

	wire rising;
	assign rising = (baud_counter == 0);

	reg sending = 0;
	reg [7:0] data = 0;
	assign busy = sending;

	always @(posedge clk) begin
		if (!sending && send)
		begin
			sending <= 1;
			data <= idata;
		end
		else if (sending && (bit_counter == 11))
			sending <= 0;
	end

	reg [3:0] bit_counter = 0;
	always @(posedge clk) 
		if (sending && rising) 
			bit_counter <= bit_counter + 1;
		else if (!sending) 
			bit_counter <= 0;

		always @(posedge clk) 
			if (sending && rising) begin
				case (bit_counter)
					4'd0: tx <= 0;
					4'd1 , 4'd2 , 4'd3 , 4'd4 , 4'd5 , 4'd6 , 4'd7 , 4'd8:
						tx <= data[bit_counter-1];
					4'd9: tx <= 1;
					4'd10: tx <= 1;
					default: tx <= 1;
				endcase
			end

			endmodule
