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

module otl_arbiter
  ( 
    // Inputs
    s_wrdata, s_wraddr, s_wrvalid, s_rdaddr,
    s_rdready, adc_wrready, adc_rddata, adc_rdvalid,
    dac_wrready, dac_rddata, dac_rdvalid, trx_wrready,  
    trx_rddata, trx_rdvalid,
    
    // Outputs
    s_wrready, s_rddata,  s_rdvalid, adc_wrdata,
    adc_wraddr, adc_wrvalid, adc_rdaddr, 
    adc_rdready, dac_wrdata, dac_wraddr, dac_wrvalid,
    dac_rdaddr, dac_rdready, trx_wrdata, trx_wraddr,
    trx_wrvalid, trx_rdaddr,trx_rdready,
   );


   parameter ADDRW = 32;
   parameter DATAW = 32;
   

   input [DATAW-1:0]   s_wrdata;
   input [ADDRW-1:0]   s_wraddr;
   input 	       s_wrvalid;
   output 	       s_wrready;
   
   output [DATAW-1:0]  s_rddata;
   input [ADDRW-1:0]   s_rdaddr;
   output 	       s_rdvalid;
   input 	       s_rdready;

   // ADC core signals 
   output [DATAW-1:0]  adc_wrdata;
   output [ADDRW-1:0]  adc_wraddr;
   output 	       adc_wrvalid;
   input 	       adc_wrready;  
   input [DATAW-1:0]   adc_rddata;
   output [ADDRW-1:0]  adc_rdaddr;
   input 	       adc_rdvalid;
   output 	       adc_rdready;

   // DAC core signals
   output [DATAW-1:0]  dac_wrdata;
   output [ADDRW-1:0]  dac_wraddr;
   output 	       dac_wrvalid;
   input 	       dac_wrready;  
   input [DATAW-1:0]   dac_rddata;
   output [ADDRW-1:0]  dac_rdaddr;
   input 	       dac_rdvalid;
   output 	       dac_rdready;

   // TRX core signals
   output [DATAW-1:0]  trx_wrdata;
   output [ADDRW-1:0]  trx_wraddr;
   output 	       trx_wrvalid;
   input 	       trx_wrready;  
   input [DATAW-1:0]   trx_rddata;
   output [ADDRW-1:0]  trx_rdaddr;
   input 	       trx_rdvalid;
   output 	       trx_rdready;

   
   // Write channel
   always @*
     case (s_wraddr[15:12])
       `ADC_CORE_ADDR : begin
	  adc_wrdata = s_wrdata;
	  adc_wraddr = s_wraddr;
	  adc_wrvalid = s_wrvalid;
	  s_wrready =  adc_wrready;
       end
     
       `DAC_CORE_ADDR : begin
	  dac_wrdata = s_wrdata;
	  dac_wraddr = s_wraddr;
	  dac_wrvalid = s_wrvalid;
	  s_wrready =  dac_wrready;
       end
       `TRX_CORE_ADDR : begin
	  trx_wrdata = s_wrdata;
	  trx_wraddr = s_wraddr;
	  trx_wrvalid = s_wrvalid;
	  s_wrready =  trx_wrready;
       end
     endcase  

   // Read channel
   always @*
     case (s_rdaddr[15:12])
       `ADC_CORE_ADDR : begin
	  s_rddata = adc_rddata;
	  adc_rdaddr = s_rdaddr;
	  s_rdvalid = adc_rdvalid;
	  s_rdready= adc_rdready;
       end
       `DAC_CORE_ADDR : begin
	  s_rddata = adc_rddata;
	  adc_rdaddr = s_rdaddr;
	  s_rdvalid = adc_rdvalid;
	  s_rdready= adc_rdready;
       end
       `TRX_CORE_ADDR : begin
	  s_rddata = adc_rddata;
	  adc_rdaddr = s_rdaddr;
	  s_rdvalid = adc_rdvalid;
	  s_rdready= adc_rdready;
       end
     endcase
