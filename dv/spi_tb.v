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

module spi_tb();
   
   
   reg        clk;
   reg 	      reset;
   reg [15:0] wr_data;
   reg 	      wr;
   reg 	      spi_miso;
   reg 	      new_data;
   
   wire       spi_clk;
   wire       spi_le;
   wire       spi_mosi;
   wire       busy;
   wire [7:0] rd_data;

   initial begin
      clk = 1'b1;
      reset = 1'b1;
      new_data = 1'b0;
      
      wr_data = 16'habcd;
      wr = 1'b1;

      # 50 reset = 1'b0;
      # 50 new_data = 1'b1;
      # 20 new_data = 1'b0;
   end // initial begin

   always #5 clk = !clk;
   

    
  otl_spi dut
    (
     // inputs
     .sys_clk(clk), 
     .reset(reset), 
     .wr_data(wr_data), 
     .wr(wr),
     .spi_miso(spi_mosi), 
     .new_data(new_data),
     
     //outputs
     .spi_clk(spi_clk), 
     .spi_le(spi_le), 
     .spi_mosi(spi_mosi), 
     .busy(busy), 
     .rd_data(rd_data), 
     .spi_done(done));
endmodule
