/*
 *  Copyright 2015 (c) Patrik Lindstr�m, lindstroeem@gmail.com
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


module s_axi_config
  (
   //inputs
   s_axi_aclk, s_axi_aresetn, s_axi_awaddr,
   s_axi_awprot, s_axi_awvalid, s_axi_wdata,
   s_axi_wstrb, s_axi_wvalid, s_axi_bready,
   s_axi_araddr, s_axi_arprot, s_axi_arvalid,
   s_axi_rready, m_rdata,
 
   //ouputs
   s_axi_awready, s_axi_wready, s_axi_bresp,
   s_axi_bvalid, s_axi_arready, s_axi_rdata,
   s_axi_rresp, s_axi_rvalid,
   
   m_addr, m_wdata, m_wstrb

 );

   parameter ADDR_WIDTH = 32;
   parameter DATA_WIDTH = 32;
   
   
   
   // Clock and reset
   input wire 	      s_axi_aclk;
   input wire 	      s_axi_aresetn;
   
   
   // axi write address channle
   input wire [ADDR_WIDTH -1:0]    s_axi_awaddr;
   input wire [2:0] 		   s_axi_awprot;
   input wire 			   s_axi_awvalid;
   output reg 			   s_axi_awready;
   
   
   // Axi write data channle
   input wire [DATA_WIDTH-1:0] 	   s_axi_wdata;
   input wire [DATA_WIDTH/8 -1:0]  s_axi_wstrb;
   input wire 			   s_axi_wvalid;
   output reg 			   s_axi_wready;
   
   // Axi write response channle
   output reg [1:0] 		   s_axi_bresp;
   output reg 			   s_axi_bvalid;
   input wire 			   s_axi_bready;
   
   // Axi read address channle
   input wire [ADDR_WIDTH -1:0]    s_axi_araddr;
   input wire [2:0] 		   s_axi_arprot;
   input wire 			   s_axi_arvalid;
   output reg 			   s_axi_arready;
   
   // Axi read data channle
   output reg [DATA_WIDTH-1:0] 	   s_axi_rdata;
   output reg [1:0] 		   s_axi_rresp;
   output reg 			   s_axi_rvalid;
   input wire 			   s_axi_rready;
   
   // Memory interface
   output wire [ADDR_WIDTH-1:0]    m_addr;
   input wire [DATA_WIDTH-1:0] 	   m_rdata;
   output reg [DATA_WIDTH-1:0] 	   m_wdata;
   output reg 			   m_wstrb;
   
	   
   reg [ADDR_WIDTH-1:0] 	   rd_addr;
   reg [ADDR_WIDTH-1:0] 	   wr_addr;

   

   // Acknowledge signals
   wire 	      w_ack;
   wire 	      aw_ack;   
   wire 	      ar_ack;
   wire 	      r_ack;
   

   //----------------------------
   // Address write channel
   //----------------------------

   // Acknowledge signal
   assign aw_ack = s_axi_awvalid & s_axi_wvalid;

   // awready logic
   always @( posedge s_axi_aclk )
      if ( ~s_axi_aresetn )
	 s_axi_awready <= 1'b0;
      else    
	if (~s_axi_awready && aw_ack)
	  s_axi_awready <= 1'b1;
	else
	  s_axi_awready <= 1'b0;
      
      
   // awaddr logic, needed ?
   always @( posedge s_axi_aclk )
     if ( ~s_axi_aresetn )
       wr_addr <= 0;
     else
       if (~s_axi_awready && aw_ack)
	 wr_addr <= s_axi_awaddr;
   
   
   //----------------------------
   // Write channel
   //----------------------------

   // write acknowledge signal
   assign w_ack = s_axi_wready & s_axi_wvalid & s_axi_awready & s_axi_awvalid;

   // wready logic
   always @( posedge s_axi_aclk )
     if ( ~s_axi_aresetn )
       s_axi_wready <= 1'b0;
     else    
       if ( ~s_axi_wready && aw_ack) 
	 s_axi_wready <= 1'b1;
       else
	 s_axi_wready <= 1'b0;


   
   always @ ( posedge s_axi_aclk ) begin
      m_wstrb <= w_ack;
      if ( ~s_axi_aresetn ) //TODO: reset needed?
	m_wdata <= 'b0;
      else if( w_ack )
	m_wdata <= s_axi_wdata;
   end
   


   //----------------------------
   // Write respones channel
   //----------------------------
   
   
   always @( posedge s_axi_aclk )
     if ( ~s_axi_aresetn ) begin
	s_axi_bvalid  <= 0;
	s_axi_bresp   <= 2'b0;
     end 
     else 
       if (~s_axi_bvalid && w_ack)
	 begin
	    s_axi_bvalid <= 1'b1;
	    s_axi_bresp  <= 2'b0;
	 end
       else
	 if (s_axi_bready && s_axi_bvalid)
	   s_axi_bvalid <= 1'b0; 
   
  


   //----------------------------
   // Read address channel
   //----------------------------

   // read address acknowledge
   assign ar_ack = ~s_axi_arready && s_axi_arvalid;
   
   always @( posedge s_axi_aclk )
     if ( ~s_axi_aresetn ) begin
	s_axi_arready <= 1'b0;
	rd_addr  <= 32'b0;
     end 
     else    
       if (ar_ack) begin
	  s_axi_arready <= 1'b1;
	  rd_addr  <= s_axi_araddr;
       end
       else 
	 s_axi_arready <= 1'b0;
   

   
   //----------------------------
   // Read data channel
   //----------------------------

   // Read data acknowledge
   assign r_ack = s_axi_arready & s_axi_arvalid & ~s_axi_rvalid;
   
   
   always @( posedge s_axi_aclk )
     if ( ~s_axi_aresetn ) begin
	s_axi_rvalid <= 0;
	s_axi_rresp  <= 0;
     end 
     else    
       if (r_ack)  begin
	  s_axi_rvalid <= 1'b1;
	  s_axi_rresp  <= 2'b0;
       end   
       else if (s_axi_rvalid && s_axi_rready)
	 s_axi_rvalid <= 1'b0;


   // read data logic
   always @( posedge s_axi_aclk )
     if ( ~s_axi_aresetn ) 
       s_axi_rdata  <= 0; 
     else 
       if (r_ack)
	 s_axi_rdata <= m_rdata;



   //----------------------------
   // Memory logic
   //----------------------------
    assign m_addr = (m_wstrb) ? wr_addr : rd_addr;

   
endmodule
