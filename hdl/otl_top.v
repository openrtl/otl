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

module otl_top
  (
   //inputs
   s_axi_aclk, s_axi_aresetn, s_axi_awaddr,
   s_axi_awprot, s_axi_awvalid, s_axi_wdata,
   s_axi_wstrb, s_axi_wvalid, s_axi_bready,
   s_axi_araddr, s_axi_arprot, s_axi_arvalid,
   s_axi_rready,
 
   //ouputs
   s_axi_awready, s_axi_wready, s_axi_bresp,
   s_axi_bvalid, s_axi_arready, s_axi_rdata,
   s_axi_rresp, s_axi_rvalid
 );

   parameter ADDRW = 32;
   parameter DATAW = 32;
   
   
   // AXI slave interface
   input  	        s_axi_aclk;
   input 		s_axi_aresetn;
   input [ADDRW -1:0] 	s_axi_awaddr;
   input [2:0] 		s_axi_awprot;
   input 		s_axi_awvalid;
   output 		s_axi_awready;
   input [DATAW-1:0] 	s_axi_wdata;
   input [DATAW/8-1:0] 	s_axi_wstrb;
   input 		s_axi_wvalid;
   output 		s_axi_wready;
   output [1:0] 	s_axi_bresp;
   output 		s_axi_bvalid;
   input 		s_axi_bready;
   input [ADDRW -1:0] 	s_axi_araddr;
   input [2:0] 		s_axi_arprot;
   input 		s_axi_arvalid;
   output 		s_axi_arready;
   output [DATAW-1:0] 	s_axi_rdata;
   output [1:0] 	s_axi_rresp;
   output 		s_axi_rvalid;
   input 		s_axi_rready;
   
   
   /*AUTOWIRE*/

   otl_axi_dma otl_axi_dma_i
     (/*AUTOINST*/);
      
   otl_axi_slave otl_axi_slave_i
     (/*AUTOINST*/);

   otl_arbiter otl_arbiter_i
     (/*AUTOINST*/);

//   otl_trx otl_trx_i
//     (/*AUTOINST*/);
   
   otl_adc otl_adc_i
     (/*AUTOINST*/);

//   otl_dac otl_dac_i
//     (/*AUTOINST*/);
   
   
   
endmodule
