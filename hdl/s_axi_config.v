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


module s_axi_config
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
   s_axi_rresp, s_axi_rvalid,
   
   mem_addr,
   mem_data,
   mem_wstrb
 );

   
   // Clock and reset
   input wire 	      s_axi_aclk;
   input wire 	      s_axi_aresetn;
   
   
   // axi write address channle
   input wire [3:0]   s_axi_awaddr;
   input wire [2:0]   s_axi_awprot;
   input wire 	      s_axi_awvalid;
   output reg 	      s_axi_awready;
   

   // Axi write data channle
   input wire [31:0]  s_axi_wdata;
   input wire [3:0]   s_axi_wstrb;
   input wire 	      s_axi_wvalid;
   output reg 	      s_axi_wready;
   
   // Axi write response channle
   output reg [1:0]  s_axi_bresp;
   output reg 	      s_axi_bvalid;
   input wire 	      s_axi_bready;
   
   // Axi read address channle
   input wire [3:0]   s_axi_araddr;
   input wire [2:0]   s_axi_arprot;
   input wire 	      s_axi_arvalid;
   output reg 	      s_axi_arready;
   
   // Axi read data channle
   output reg [31:0]  s_axi_rdata;
   output reg [1:0]   s_axi_rresp;
   output reg 	      s_axi_rvalid;
   input wire 	      s_axi_rready;
   
   // Memory interface
   output wire [31:0] m_addr;
   output reg [31:0]  m_data;
   output reg 	      m_wstrb;
   
	   
   
   
   reg [3:0] 	      axi_awaddr;
   reg [3:0] 	      axi_araddr;


   // Acknowledge signals
   wire 	      w_ack;
   wire 	      aw_ack;   
   wire 	      b_ack;
   wire 	      ar_ack;
   wire 	      r_ack;
   

   //----------------------------
   // Address write channel
   //----------------------------

   // Acknowledge signal
   assign aw_ack = ~s_axi_awready && s_axi_awvalid && s_axi_wvalid;

   // awready logic
   always @( posedge s_axi_aclk ) begin
      if ( ~s_axi_aresetn ) begin
	 s_axi_awready <= 1'b0;
      end 
      else begin    
	 if (aw_ack) begin
	    s_axi_awready <= 1'b1;
	 end
	 else begin
	    s_axi_awready <= 1'b0;
	 end
      end 
   end       

   // awaddr logic, needed ?
   always @( posedge s_axi_aclk )
     begin
	if ( ~s_axi_aresetn )
	  begin
	     axi_awaddr <= 0;
	  end 
	else
	  begin    
	     if (aw_ack) begin
	        axi_awaddr <= s_axi_awaddr;
	     end
	  end 
     end       
   
   //----------------------------
   // Write channel
   //----------------------------

   // write acknowledge signal
   assign w_ack = ~s_axi_wready && s_axi_wvalid && s_axi_awvalid;

   // wready logic
   always @( posedge s_axi_aclk ) begin
      if ( ~s_axi_aresetn ) begin
	 s_axi_wready <= 1'b0;
      end 
      else begin    
	 if (w_ack) begin
	    s_axi_wready <= 1'b1;
	 end
	 else begin
	    s_axi_wready <= 1'b0;
	 end
      end 
   end      


   //TODO: add write data logic


   //----------------------------
   // Write respones channel
   //----------------------------

   //assign reg_wren = s_axi_wready && s_axi_wvalid && s_axi_awready && s_axi_awvalid;
   
   
   always @( posedge s_axi_aclk ) begin
      if ( ~s_axi_aresetn )
	begin
	   s_axi_bvalid  <= 0;
	   s_axi_bresp   <= 2'b0;
	end 
      else begin    
	 if (s_axi_awready && s_axi_awvalid && ~s_axi_bvalid && s_axi_wready && s_axi_wvalid)
	   begin
	      s_axi_bvalid <= 1'b1;
	      s_axi_bresp  <= 2'b0;
	   end
	 else begin
	    if (s_axi_bready && s_axi_bvalid) begin
	       s_axi_bvalid <= 1'b0; 
	    end  
	 end
      end
   end   


   //----------------------------
   // Read address channel
   //----------------------------

   // read address acknowledge
   assign ar_ack = ~s_axi_arready && s_axi_arvalid;
   
   always @( posedge s_axi_aclk ) begin
      if ( ~s_axi_aresetn ) begin
	 s_axi_arready <= 1'b0;
	 axi_araddr  <= 32'b0;
      end 
      else begin    
	 if (ar_ack) begin
	    s_axi_arready <= 1'b1;
	    axi_araddr  <= s_axi_araddr;
	 end
	 else begin
	    s_axi_arready <= 1'b0;
	 end
      end 
   end       

   //----------------------------
   // Read data channel
   //----------------------------

   // Read data acknowledge
   assign r_ack = s_axi_arready && s_axi_arvalid && ~s_axi_rvalid;
   
   
   always @( posedge s_axi_aclk ) begin
      if ( ~s_axi_aresetn ) begin
	 s_axi_rvalid <= 0;
	 s_axi_rresp  <= 0;
      end 
      else begin    
	 if (r_ack)
	   begin
	      s_axi_rvalid <= 1'b1;
	      s_axi_rresp  <= 2'b0;
	   end   
	 else if (s_axi_rvalid && s_axi_rready) begin
	    s_axi_rvalid <= 1'b0;
	 end                
      end
   end    

   //assign slv_reg_rden = s_axi_arready & s_axi_arvalid & ~s_axi_rvalid;

   // read data logic
   always @( posedge s_axi_aclk ) begin
      if ( ~s_axi_aresetn ) begin
	 s_axi_rdata  <= 0;
      end 
      else begin    
	 if (slv_reg_rden) begin
	    s_axi_rdata <= reg_data_out;
	 end   
      end
   end    

endmodule
