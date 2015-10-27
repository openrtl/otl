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


module otl_trx_core
  (  
     // Inputs
     clk, reset,
     s_wrdata, s_wraddr, s_wrvalid, s_rdaddr,
     s_rdready,

     // Outputs
     s_wrready, s_rddata,  s_rdvalid, adc_wrdata,
     
   );
   
   parameter ADDRW = 4;
   parameter DATAW = 32;
   parameter MEMW = 32
   
   
   input [DATAW-1:0]   s_wrdata;
   input [ADDRW-1:0]   s_wraddr;
   input 	       s_wrvalid;
   output 	       s_wrready;
   
   output [DATAW-1:0]  s_rddata;
   input [ADDRW-1:0]   s_rdaddr;
   output 	       s_rdvalid;
   input 	       s_rdready;


   
   wire [7:0] 	       spi_wrdata;
   wire [7:0] 	       spi_wraddr;
   wire 	       spi_wrvalid;
   wire 	       spi_wrready;
   wire [7:0] 	       spi_rddata;
   wire [7:0] 	       spi_rdaddr;
   wire 	       spi_rdvalid;
   wire 	       spi_rdready;

   always @*
     case(s_rdaddr[11:9])
       `TRX_CORE_SPI_ADDR : begin
	  s_rddata = spi_rddata;
	  spi_rdaddr = s_rdaddr;
	  s_rdvalid = spi_rdvalid;
	  spi_rdready = s_rdready;
       end
     endcase
   
   always @*
     case(s_wraddr[11:9])
       `TRX_CORE_SPI_ADDR : begin
	  spi_wrdata = s_wrdata;
	  spi_wraddr = s_wraddr;
	  spi_wrvalid = s_wrvalid;
	  s_wrready = spi_wrready;
       end
     endcase
   
endmodule	  
	 
