/*
 *  Copyright 2015 (c) Patrik Lindström, lindstroeem@gmail.com
 * 
 * 
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


module otl_pack
  (
   // inputs
   data_i, frame_i, clk,

   // outputs
   data_o, frame_o
   );


   // RX signals
   input [11:0] data_i;
   input 	frame_i;
   input 	clk;
   
   // ADC signals
   output [31:0] data_o;
   output reg  	 frame_o;
   

   reg [31:0] 	 data;
     
   reg [0:0] 	 data_ptr;

   // data pointer
   always @ (posedge rx_clk)
     if (~rx_frame)
       data_ptr <= 1'b0;
     else
       data_ptr <= data_ptr +1;

   // adc frame signal
   always @ (posedge rx_clk)
     frame_o <= data_ptr & frame_i & ~frame_o;
   
   always @ (*)
        case (data_ptr)
	 1'b0:
	   data[31:16] <= {4'b0,data_i};
	 1'b1:
	   data[15:0] <= {4'b0,data_i};
       endcase

   assign data_o = data;
   
   
   
endmodule
