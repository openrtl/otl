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

module otl_cfg_mem
  (
   //inputs
   wraddr, wrdata, wrvalid, rdready,
   rdaddr, clk, reset, 

   //outputs
   rddata, rdvalid, wrready mem_expose
   );

   parameter DATAW = 32;
   parameter ADDRW = 4;

   //Read signals
   input [ADDRW-1 : 0]     rdaddr;
   output reg [DATAW-1 :0 ] rddata;
   output 		   rdvalid;
   input 		   rdready;
   
   
   //Write signals
   input [ADDRW-1 : 0] 	wraddr;
   input [DATAW-1 : 0] 	wrdata;
   input 		wrvalid;
   output 		wrready;
   
   
   //Clock and reset
   input 			clk;
   input 			reset;

   output [DATAW-1:0] 	mem_expose [1<<ADDRW-1 : 0];
   
   
   reg [DATAW-1:0] 		memory [1<<ADDRW-1 : 0];


   //Memory expose port
   assign mem_expose = memory;

   assign wrready = 1'b1; // Always ready
   
   
   //Write logic
   always @ (posedge clk)
     if(reset)
       memory <= 0;
     else if(wrvalid)
       memory[wraddr] <= wrdata;

   //Read logic
   always @ (posedge clk)
     if(reset) // not needed?
       rddata <= 'b0;
     else if(rd_ready) begin
	rddata <= memory[rdaddr];
	rdvalid <= 1'b1;
     end
     else
       rdvalid <= 1'b0;
   
   
   
   
		    
