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

//TODO: Add idealy
module otl_adc_rx
  (
   //inputs
   rx_data_p, rx_data_n, rx_clk_p, rx_clk_n,
   rx_frame_p, rx_frame_n,

   //outputs
   rx_frame, rx_data, rx_clk
   );


   input [5:0] rx_data_p, rx_data_n;
   input       rx_frame_p, rx_frame_n;
   input       rx_clk_p, rx_clk_n;

   output [11:0] rx_data;
   output 	 rx_frame;
   output 	 rx_clk;
   
   

   //----------------------------
   // wires 
   //----------------------------

   wire [5:0]  rx_data_iddr;
   wire        rx_frame_iddr;
   wire        rx_clk_i;

   wire [11:0]  rx_data_i;
   wire [1:0] 	rx_frame_i;
   wire 	rx_clk;
   
   //----------------------------
   // Regs 
   //----------------------------
   reg [11:0]  rx_data;
   reg [17:0]  rx_frame_reg;
   reg 	       rx_frame;
      
   //----------------------------
   // input buffers
   //----------------------------

   //rx data
   IBUFDS #(.DIFF_TERM("TRUE"))
   ibufds_data[5:0]
     (
      .I(rx_data_p),
      .IB(rx_data_n),
      .O(rx_data_i));
   
   //rx frame
   IBUFDS #(.DIFF_TERM("TRUE"))
   ibufds_frame
     (
      .I(rx_frame_p),
      .IB(rx_frame_n),
      .O(rx_frame_i)); 
  
   //rx clk
   IBUFDS #(.DIFF_TERM("TRUE"))
   ibufds_clk
     (
      .I(rx_clk_p),
      .IB(rx_clk_n),
      .O(rx_clk_i));

   //----------------------------
   // IDDR
   //----------------------------
   //data
   IDDR #(.DDR_CLK_EDGE("SAME_EDGE"),.SRTYPE("ASYNC")) 
   iddr_data[5:0] 
     (
      .Q1(rx_data_i[11:6]), 
      .Q2(rx_data_i[5:0]), 
      .C(rx_clk), 
      .CE(1'b1), 
      .D(rx_data_iddr), 
      .R(1'b0),
      .S(1'b0));

   //frame
   IDDR #(.DDR_CLK_EDGE("SAME_EDGE"),.SRTYPE("ASYNC")) 
   iddr_frame 
     (
      .Q1(rx_frame_i[0]), 
      .Q2(rx_frame_i[1]), 
      .C(rx_clk), 
      .CE(1'b1), 
      .D(rx_frame_iddr), 
      .R(1'b0),
      .S(1'b0));

   //----------------------------
   // clk buffer
   //----------------------------
   //rx_clk
   BUFR rx_clk_bufr_i(.I(rx_clk_i),.O(rx_clk));
   
   //----------------------------
   // Data/frame align
   //----------------------------

   always @ (posedge rx_clk)
     rx_frame <= rx_frame_i[1];
   
   
   always @ (posedge rx_clk)
     case(rx_frame_i[1:0])
       2'b01 :
	 rx_data_reg[5:0] <= rx_data_i[5:0];

       2'b10 : begin
	 rx_data_reg[11:6] <= rx_data_i[11:6];
	  rx_data_reg[17:12] <= rx_data_reg[5:0];
       end
       
       2'b11 : begin
	  rx_data_reg[11:0] <= rx_data_i[11:0];
	  rx_data_reg[17:12] <= rx_data_reg[5:0];
       end
       
       default :
	 rx_data_reg <= rx_data_reg;
     endcase
   
endmodule
