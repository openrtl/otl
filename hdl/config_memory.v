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

module register_map
  (
   //inputs
   wr_addr, wr_data, wr_strb,
   rd_addr,clk, reset, 

   //outputs
   rd_data, mem_expose
   );

   parameter MEM_WIDTH = 32;
   parameter ADDR_WIDTH = 4;

   //Read signals
   input [ADDR_WIDTH-1 : 0]     rd_addr;
   output reg [MEM_WIDTH-1 :0 ] rd_data;
   
   //Write signals
   input [ADDR_WIDTH-1 : 0] 	wr_addr;
   input [MEM_WIDTH-1 : 0] 	wr_data;
   input 			wr_strb; //byte select?
   
   //Clock and reset
   input 			clk;
   input 			reset;

   output [MEM_WIDTH-1:0] 	mem_expose [1<<ADDR_WIDTH-1 : 0];
   
   
   reg [MEM_WIDTH-1:0] 		memory [1<<ADDR_WIDTH-1 : 0];


   //Memory expose port
   assign mem_expose = memory;
   
   
   //Write logic
   always @ (posedge clk)
     if(reset)
       memory <= 0;
     else if(wr_strb) //byte select?
       memory[wr_addr] <= wr_data;

   //Read logic
   always @ (posedge clk)
     if(reset) // not needed?
       rd_data <= 'b0;
     else
       rd_data <= memory[rd_addr];
   
   
   
   
		    