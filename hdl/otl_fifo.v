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


module otl_fifo
(
 //inputs
 wr_data, wr_clk, wr_en, rd_clock,
 rd_en, reset,
 
 //outputs
 rd_data, almost_empty, amlost_full,
 empty, full
 
 );


   // Write signals
   input [31:0] wr_data;
   input wr_clk;
   input wr_en;
   
   // Read signals
   output [31:0] rd_data;
   input rd_clock;
   input rd_en;

   // Reset
   input reset;
   
   // Status flags
   output almost_empty;
   output amlost_full;
   output empty;
   output full;
   
   
   FIFO18E1 #
     (
      .ALMOST_EMPTY_OFFSET(13'h0080),
      .ALMOST_FULL_OFFSET(13'h0080),
      .DATA_WIDTH(36),
      .DO_REG(1), // Must be 1 if EN_SYN = FALSE
      .EN_SYN("FALSE"), // dual clock
      .FIFO_MODE("FIFO18"),
      .FIRST_WORD_FALL_THROUGH("TRUE"),
      .INIT(36'h000000000), 
      .SIM_DEVICE("7SERIES"),
      .SRVAL(36'h000000000)
      )
   FIFO18E1_inst
     (
      .DO(rd_data),  // read data
      .DOP(),
      .ALMOSTEMPTY(almost_empty), // programable empty flag
      .ALMOSTFULL(almost_full),   // programable full flag
      .EMPTY(empty), // fifo empty
      .FULL(full),   // fifo full
      .RDCOUNT(), 
      .RDERR(), 
      .WRCOUNT(), 
      .WRERR(),
      .RDCLK(rd_clk), // read clock
      .RDEN(rd_en),   // read enable
      .RST(reset),    // async reset
      .WRCLK(wr_clk), // write clock 
      .WREN(wr_en),   // write enable
      .DI(wr_data),   // write data
      .DIP());
   
endmodule
