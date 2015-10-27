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

module otl_spi
  (
   // inputs
   sys_clk, reset, wr_data, wr,
   spi_miso, new_data,

   //outputs
   spi_clk, spi_le, spi_mosi, busy, 
   rd_data, spi_done
   );

   // system signals
   input             sys_clk;
   input 	     reset;
   
   // bus signals
   input [7:0] 	     s_wrdata;
   input [7:0] 	     s_wraddr;
   input 	     s_wrvalid;
   output reg 	     s_wrready;  
   output reg [7:0]  s_rddata;
   input [7:0] 	     s_araddr;
   output reg 	     s_wrvalid;
   input 	     s_wrready;
   
   // spi signals
   input 	     spi_miso;
   output 	     spi_clk;
   output reg 	     spi_le;
   output reg 	     spi_mosi;
   
   
   
   // Parameters
   parameter SPI_DIV = 4;
   localparam IDLE      = 1'b0;
   localparam TRANSFERE = 1'b1;

   
   reg 		     spi_state;
   reg [23:0] 	     wr_data_reg;
   reg [SPI_DIV-1 : 0] spi_clk_div;
   reg [4:0] 	      bit_count;
   
   wire 	      rd_le;
   wire 	      wr_le;

   // Read latch enable, after rising edge of spi clk
   assign rd_le = ((spi_clk_div == {2'b10,{SPI_DIV-2{1'b1}}}));// & (bit_count == 16));
   // Write latch enable, before rising edge of spi clk
   assign wr_le = (spi_clk_div == {2'b00,{SPI_DIV-2{1'b1}}});
   // Spi clk
   assign spi_clk = spi_clk_div[SPI_DIV-1];
   
   
   
   always @ (posedge sys_clk)
     if(reset) begin
	spi_state <= IDLE;
	spi_write <= 1'b0;
	spi_le <= 1'b1;
	wr_data <= 'b0;
	s_rddata <= 'b0;
     end
     else
       case (spi_state)
	 IDLE : begin
	    busy <= 1'b0;
	    spi_clk_div <= 'b0;
	    bit_count <= 'b0;
	    s_wrready <= 1'b0;
	    s_rdvalid <= 1'b0;
	    
	    
	    if (s_wrvalid) begin
	       spi_write <= 1'b1;
	       wr_data[15:8] <= s_wraddr;
	       wr_data[7:0] <= s_wrdata;
	       wr_data[23:16] <= {1'b1,6'b0};
	       spi_state <= TRANSFERE;
	    end
	    
	    else if (s_rdready) begin
	       spi_write <= 1'b0;
	       wr_data[15:8] <= s_rdaddr;
	       wr_data[23:16] <= 0;
	       spi_state <= TRANSFERE;
	    end
	    
	 end

	 TRANSFERE : begin
	    spi_clk_div <= spi_clk_div +1;
	    spi_le <= 1'b0;
	    
	    if( wr_le )
	      spi_mosi <= wr_data_reg[23];
	    else if ( rd_le) begin
	       s_rddata <= {s_rddata[6:0],spi_miso};
	       wr_data <= {wr_data[22:0],1'b0};
	    end
	    else if (spi_clk_div == {SPI_DIV{1'b1}}) begin
	       bit_count <= bit_count +1;
	       if (bit_count == 5'd23) begin
		  spi_state <= IDLE;
		  spi_le <= 1'b1;
		  
		  if(spi_write)
		    s_wrready <= 1'b1;
		  else
		    s_rdvalid <= 1'b1;
		  
	       end
	    end
	 end // case: TRANSFERE
       endcase // case (spi_state)
   
       
endmodule     
   
