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


module adc_pack
  (
   // inputs
   rx_data, rx_frame, rx_clk,

   // outputs
   adc_data, adc_frame
   );


   // RX signals
   input [11:0] rx_data;
   input 	rx_frame;
   input 	rx_clk;
   
   // ADC signals
   output [31:0] adc_data;
   output reg  	 adc_frame;
   

   reg [15:0] 	 data_i;
   reg [15:0] 	 data_q;
   
   reg [0:0] 	 data_ptr;

   // data pointer
   always @ (posedge rx_clk)
     if (~rx_frame)
       data_ptr <= 1'b0;
     else
       data_ptr <= data_ptr +1;

   // adc frame signal
   always @ (posedge rx_clk)
     adc_frame <= data_ptr & rx_frame & ~adc_frame;
   
   always @ (*)
        case (data_ptr)
	 1'b0:
	   data_i <= {4'b0,rx_data};
	 1'b1:
	   data_q <= {4'b0,rx_data};
       endcase

   assign adc_data = {data_i,data_q};
   
   
   
endmodule
