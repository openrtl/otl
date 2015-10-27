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


module otl_adc_core
  (  
     // Inputs
     clk, reset, enable,
     dma_wrdata, dma_wraddr, dma_wrvalid,
     fifo_full, fifo_rddata,

     // Outputs
     dma_wrready, fifo_rden 
   );
   
   parameter ADDRW = 32;
   parameter DATAW = 32;

   input clk;
   input reset;
   input enable;
      
   input [DATAW-1:0]   dma_wrdata;
   input [ADDRW-1:0]   dma_wraddr;
   input 	       dma_wrvalid;
   output 	       dma_wrready;

   input 	       fifo_full;
   input [DATAW-1:0]   fifo_rddata;
   output 	       fifo_rden;
   
   
   assign dma_wrdata = fifo_rddata;
   assign dma_wrready = (enable & fifo_full & dma_wrvalid);

   assign fifo_rden = (enable & fifo_full & dma_wrvalid);
			 
       
       

endmodule
