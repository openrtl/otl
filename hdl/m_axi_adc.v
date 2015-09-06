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

module axi_dma
  (
   //inouts
   m_axi_aclk, m_axi_aresetn, m_axi_awready, m_axi_wready,
   m_axi_bid, m_axi_bresp, m_axi_buser, m_axi_bvalid,
   m_axi_arready, dma_wraddr, dma_wrinit, dma_wrdata,
   m_axi_rid, m_axi_rdata, m_axi_rresp, m_axi_rlast,
   m_axi_ruser, m_axi_rvalid, dma_rdaddr, dma_rdinit,

   //outputs
   m_axi_awid, m_axi_awaddr, m_axi_awlen, m_axi_awsize,
   m_axi_awburst, m_axi_awlock, m_axi_awcache, m_axi_awprot,
   m_axi_awqos, m_axi_awuser, m_axi_awvalid, m_axi_wdata,
   m_axi_wstrb, m_axi_wlast, m_axi_wuser, m_axi_wvalid,
   m_axi_bready, m_axi_arid, m_axi_araddr, m_axi_arlen,
   m_axi_arsize, m_axi_arburst, m_axi_arlock, m_axi_arcache,
   m_axi_arprot, m_axi_arqos, m_axi_aruser, m_axi_arvalid,
   m_axi_rready, dma_rddata, dma_rdvalid, dma_wrready
   );
   
   parameter  BURST_LENGTH	        = 16;
   parameter  ID_WIDTH	                = 1;
   parameter  DATA_WIDTH                = 32;
   parameter BURST_LENGTH_LOG = clog2(BURST_LENGTH-1);
   

   
   input wire 			     m_axi_aclk;
   input wire 			     m_axi_aresetn;
   
   // write address channel
   output wire [ID_WIDTH-1 : 0]      m_axi_awid;
   output reg [31 : 0] 		     m_axi_awaddr;
   output reg [7 : 0] 		     m_axi_awlen;
   output wire [2 : 0] 		     m_axi_awsize;
   output wire [1 : 0] 		     m_axi_awburst;
   output wire 			     m_axi_awlock;
   output wire [3 : 0] 		     m_axi_awcache;
   output wire [2 : 0] 		     m_axi_awprot;
   output wire [3 : 0] 		     m_axi_awqos;
   output wire 			     m_axi_awuser;
   output reg 			     m_axi_awvalid;
   input wire 			     m_axi_awready;

   // write data channel
   output reg [DATA_WIDTH-1 : 0]     m_axi_wdata;
   output wire [DATA_WIDTH/8-1 : 0]  m_axi_wstrb;
   output reg 			     m_axi_wlast;
   output wire 			     m_axi_wuser;
   output reg 			     m_axi_wvalid;
   input wire 			     m_axi_wready;
   
   // write response channel
   input wire [ID_WIDTH-1 : 0] 	     m_axi_bid;
   input wire [1 : 0] 		     m_axi_bresp;
   input wire 			     m_axi_buser;
   input wire 			     m_axi_bvalid;
   output reg 			     m_axi_bready;
   
   // read address channel
   output wire [ID_WIDTH-1 : 0]      m_axi_arid;
   output reg [31 : 0] 		     m_axi_araddr;
   output reg [7 : 0] 		     m_axi_arlen;
   output wire [2 : 0] 		     m_axi_arsize;  
   output wire [1 : 0] 		     m_axi_arburst;
   output wire 			     m_axi_arlock;
   output wire [3 : 0] 		     m_axi_arcache;
   output wire [2 : 0] 		     m_axi_arprot;
   output wire [3 : 0] 		     m_axi_arqos;
   output wire 			     m_axi_aruser;
   output reg 			     m_axi_arvalid;
   input wire 			     m_axi_arready;

   // read data channel
   input wire [ID_WIDTH-1 : 0] 	     m_axi_rid;
   input wire [DATA_WIDTH-1 : 0]     m_axi_rdata;
   input wire [1 : 0] 		     m_axi_rresp;
   input wire 			     m_axi_rlast;
   input wire 			     m_axi_ruser;
   input wire 			     m_axi_rvalid;
   output reg 			     m_axi_rready;
   
   // dma read channel
   input wire [31:0] 		     dma_rdaddr;
   input wire [] 		     dma_rdlen;
   input wire 			     dma_rdinit;
   output wire [DATA_WIDTH-1 : 0]    dma_rddata;
   output wire 			     dma_rdvalid;
   
   // dma write channel
   input wire [31:0] 		     dma_wraddr;
   input wire [] 		     dma_wrlen;
   input wire 			     dma_wrinit;
   input wire [DATA_WIDTH-1 : 0]     dma_wrdata;
   output wire 			     dma_wrready;
   

   // Move to include file?
   function integer clogb2 (input integer bit_depth);              
      begin                                                           
	 for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
	   bit_depth = bit_depth >> 1;                                 
      end                                                           
   endfunction                                                     


   // State machine
   `define IDLE        1'b0
   `define INIT_WRITE  1'b1
   `define IDLE_READ   1'b1  
   reg  	                write_state;
   reg 		                read_state;
   
   
   
   //write counter
   reg [31 : 0] 		write_counter; //TODO: check vector width
   reg [BURST_LENGTH_LOG-1 : 0] write_burst_counter;
   

   //read counter
   reg [31 : 0] 		read_counter; //TODO: check vector width
   //reg [BURST_LENGTH_LOG-1 : 0] read_burst_counter;
   
   //size of C_M_AXI_BURST_LEN length burst in bytes
   wire [C_TRANSACTIONS_NUM+2 : 0] burst_size_bytes;

   reg 				   start_write_burst;
   reg 				   start_read_burst;
  
   reg 				   write_done; //TODO:change to output
   reg 				   read_done;   //TODO:change to output
   reg 				   write_busy;//TODO:change to output
   reg 				   read_busy;//TODO:change to output

   // Acknowledge signals
   wire 			   w_ack;
   wire 			   r_ack;
   wire 			   aw_ack;
   wire 			   ar_ack;
   wire 			   b_ack;
   
   // Initial read signals
   reg 				   init_read_d;
   reg 				   init_read_dd;
   wire 			   init_read_pulse;

   // Initial write signals
   reg 				   init_write_d;
   reg 				   init_write_dd;
   wire 			   init_wire_pulse;


   // write address channel
   assign m_axi_awid	= 'b0;
   assign m_axi_awsize	= clogb2((DATA_WIDTH/8)-1);
   assign m_axi_awburst	= 2'b01;
   assign m_axi_awlock	= 1'b0;
   assign m_axi_awcache	= 4'b0010;
   assign m_axi_awprot	= 3'h0;
   assign m_axi_awqos	= 4'h0;
   assign m_axi_awuser	= 'b1;
   
   
   // write data channel
   assign m_axi_wstrb	= {(DATA_WIDTH/8){1'b1}};
   assign m_axi_wuser	= 'b0;
   
   // read address channel
   assign m_axi_arid	= 'b0;
   assign m_axi_arsize	= clogb2((DATA_WIDTH/8)-1);
   assign m_axi_arburst	= 2'b01;
   assign m_axi_arlock	= 1'b0;
   assign m_axi_arcache	= 4'b0010;
   assign m_axi_arprot	= 3'h0;
   assign m_axi_arqos	= 4'h0;
   assign m_axi_aruser	= 'b1;

   //Burst size in bytes
   assign burst_size_bytes	= BURST_LENGTH * DATA_WIDTH/8; //Constant?


   assign init_read_pulse	= (!init_read_dd) && init_read_d;
   assign init_write_pulse	= (!init_write_dd) && init_write_d;
   
   // generate pulse for write and read init signals
   always @(posedge m_axi_aclk)										      
     begin                                                                        
	if ( ~m_axi_aresetn )                                                   
	  begin               
             // read
	     init_read_d <= 1'b0;                                                   
	     init_read_dd <= 1'b0;
	     //write
             init_write_d <= 1'b0;                                                   
	     init_write_dd <= 1'b0;                                    
	  end                                                                               
	else                                                                       
	  begin
	     //read
	     init_read_d <= dma_rdinit;
	     init_read_dd <= init_read_d;
	     //write
             init_write_d <= dma_wrinit;
	     init_write_dd <= init_write_d;                                            
	  end                                                                      
     end 


   
   //****************************
   // Write address channel
   //****************************

   assign aw_ack = m_axi_awready & m_axi_awvalid;

   // awvalid logic
   always @(posedge m_axi_aclk)                                   
     begin                                                                
	if (~m_axi_aresetn || init_write_pulse )                                           
	  begin                                                            
	     m_axi_awvalid <= 1'b0;                                           
	  end                                                              
	else if (~m_axi_awvalid && start_write_burst)                 
	  begin                                                            
	     m_axi_awvalid <= 1'b1;                                           
	  end                                                              
	else if (aw_ack)                             
	  begin                                                            
	     m_axi_awvalid <= 1'b0;                                           
	  end                                                              
	else                                                               
	  m_axi_awvalid <= m_axi_awvalid;                                      
     end


   //awlen logic
   always @(posedge m_axi_aclk)
     if (~m_axi_aresetn || init_write_pulse)
       m_axi_awlen <= 8'b0;
     else if (start_write_burst)
       if(dma_wrlen - write_counter < BURST_LENGTH) //TODO: do this better...
	 m_axi_awlen <= dma_wrlen - write_counter;
       else
	 m_axi_awlen <= BURST_LENGTH -1;
     else
       m_axi_awlen <= m_axi_awlen;
   
   
       
   
   // awaddr logic
   always @(posedge m_axi_aclk)                                         
     begin                                                                
	if (~m_axi_aresetn || init_write_pulse )                                            
	  begin                                                            
	     m_axi_awaddr <= dma_wraddr;                                             
	  end                                                              
	else if (aw_ack)                             
	  begin                                                            
	     m_axi_awaddr <= m_axi_awaddr + burst_size_bytes;                   
	  end                                                              
	else                                                               
	  m_axi_awaddr <= m_axi_awaddr;                                        
     end                                                                


   //****************************
   // Write data channel
   //****************************

   assign w_ack = m_axi_wready & m_axi_wvalid;                                   
   
   // wvalid logic                      
   always @(posedge m_axi_aclk)                                                      
     begin                                                                             
	if (~m_axi_aresetn || init_write_pulse )                                                        
	  begin                                                                         
	     m_axi_wvalid <= 1'b0;                                                         
	  end                                                                           
	else if (~m_axi_wvalid && start_write_burst)                               
	  begin                                                                         
	     m_axi_wvalid <= 1'b1;                                                         
	  end                                                                           
	else if (w_ack && m_axi_wlast)                                                    
	  m_axi_wvalid <= 1'b0;                                                           
	else                                                                            
	  m_axi_wvalid <= m_axi_wvalid;                                                     
     end                                                                               
   
   
   // wlast logic               
   always @(posedge m_axi_aclk)                                                      
     begin                                                                             
	if (~m_axi_aresetn || init_write_pulse )                                                        
	  begin                                                                         
	     m_axi_wlast <= 1'b0;                                                          
	  end                                                                           
	else if (((write_burst_counter == BURST_LENGTH-2 && BURST_LENGTH >= 2) && wnext) || 
		 (write_counter == dma_wr_len)) //TODO: make copy of dma_wrlen...
	  begin                                                                         
	     m_axi_wlast <= 1'b1;                                                          
	  end                                                                           
	else if (w_ack)                                                                 
	  m_axi_wlast <= 1'b0;                                                            
	else if (m_axi_wlast)                                   
	  m_axi_wlast <= 1'b0;                                                            
	else                                                                            
	  m_axi_wlast <= m_axi_wlast;                                                       
     end                                                                               
   
   
   // write index
   always @(posedge m_axi_aclk)                                                      
     begin                                                                             
	if (~m_axi_aresetn || init_write_pulse )    
	  begin                                                                         
	     write_counter <= 0;                                                           
	  end                                                                           
	else if (w_ack && (write_counter != dma_wrlen-1))//TODO: make copy of dma_wrlen...                          
	  begin                                                                         
	     write_counter <= write_counter + 1;                                             
	  end                                                                           
	else                                                                            
	  write_counter <= write_counter;                                                   
     end                                                                               

   assign write_burst_counter = write_counter[BURST_LENGTH_LOG-1:0];
   
   
   
   // wdata logic
   always @(posedge m_axi_aclk)                                                      
     begin                                                                             
	if (~m_axi_aresetn || init_write_pulse )                                                         
	  m_axi_wdata <= 'b1;                                                             
	else if (w_ack)                                                                 
	  m_axi_wdata <= dma_wrdata;                                                   
	else                                                                            
	  m_axi_wdata <= m_axi_wdata;                                                       
     end                                                                             


   //****************************
   // Write response channel
   //****************************

   assign b_ack = m_axi_bready & m_axi_bvalid;
   
   
   // bready logic
   always @(posedge m_axi_aclk)                                     
     begin                                                                 
	if ( ~m_axi_aresetn || init_write_pulse )                                            
	  begin                                                             
	     m_axi_bready <= 1'b0;                                             
	  end                                                               
	else if (m_axi_bvalid && ~m_axi_bready)                               
	  begin                                                             
	     m_axi_bready <= 1'b1;                                             
	  end                                                               
	else if (m_axi_bready)                                                
	  begin                                                             
	     m_axi_bready <= 1'b0;                                             
	  end                                                               
	else                                                                
	  m_axi_bready <= m_axi_bready;                                         
     end                                                                   
   
   
   //****************************
   // Read address channel
   //****************************

   ar_ack = m_axi_arready && m_axi_arvalid;
   
   
   // arvalid logic
   always @(posedge m_axi_aclk)                                 
     begin                                                              
	
	if ( ~m_axi_aresetn || init_read_pulse )                                         
	  begin                                                          
	     m_axi_arvalid <= 1'b0;                                         
	  end                                                            
	else if (~m_axi_arvalid && start_read_burst)                
	  begin                                                          
	     m_axi_arvalid <= 1'b1;                                         
	  end                                                            
	else if (ar_ack)                           
	  begin                                                          
	     m_axi_arvalid <= 1'b0;                                         
	  end                                                            
	else                                                             
	  m_axi_arvalid <= m_axi_arvalid;                                    
     end                                                                
   
   //arlen logic
   always @(posedge m_axi_aclk)
     if (~m_axi_aresetn || init_read_pulse)
       m_axi_arlen <= 8'b0;
     else if (start_read_burst)
       if(dma_rdlen - read_counter < BURST_LENGTH) //TODO: do this better...
	 m_axi_arlen <= dma_rdlen - read_counter;
       else
	 m_axi_arlen <= BURST_LENGTH -1;
     else
       m_axi_arlen <= m_axi_arlen;

   
   // araddr logic
   always @(posedge m_axi_aclk)                                       
     begin                                                              
	if ( ~m_axi_aresetn || init_read_pulse )                                          
	  begin                                                          
	     m_axi_araddr <= dma_rdaddr;                                           
	  end                                                            
	else if (ar_ack)                           
	  begin                                                          
	     m_axi_araddr <= m_axi_araddr + burst_size_bytes;                 
	  end                                                            
	else                                                             
	  m_axi_araddr <= m_axi_araddr;                                      
     end                                                                


   //****************************
   // Read data channel
   //****************************
   

   // forward movement occurs when the channel is valid and ready   
   assign r_ack = m_axi_rvalid && m_axi_rready;                            
   
   // read index
   always @(posedge m_axi_aclk)                                          
     begin                                                                 
	if ( ~m_axi_aresetn || init_read_pulse )                  
	  begin                                                             
	     read_counter <= 0;                                                
	  end                                                               
	else if (r_ack && (read_counter != dma_rdlen-1)) //TODO: make copy of dma_rdlen...              
	  begin                                                             
	     read_counter <= read_counter + 1;                                   
	  end                                                               
	else                                                                
	  read_counter <= read_counter;                                         
     end                                                                   
   

   // rready logic 
   always @(posedge m_axi_aclk)                                          
     begin                                                                 
	if (~m_axi_aresetn || init_read_pulse )                  
	  begin                                                             
	     m_axi_rready <= 1'b0;                                             
	  end                                                               
	else if (m_axi_rvalid)                       
	  begin                                      
	     if (m_axi_rlast && axi_rready)          
	       begin                                  
	          m_axi_rready <= 1'b0;                  
	       end                                    
	     else                                    
	       begin                                 
	          m_axi_rready <= 1'b1;                 
	       end                                   
	  end                                        
     end                                            
   

   //****************************
   // DMA logic
   //****************************
   
   // Write state machine   
   always @ ( posedge m_axi_aclk)                                                                            
     if ( ~m_axi_aresetn )                                                                             
       begin                                                                                                 
	  write_state      <= IDLE;                                                                
	  start_write_burst <= 1'b0;
       end                                                                                                   
     else                                                                                                    
       case (write_state)                                                                               
	 
	 IDLE:                                                                                     
	   if ( init_write_pulse )                                                      
	     write_state  <= INIT_WRITE;                                                              
	   else                                                                                            
	     write_state  <= IDLE;                                                            
	 
	 INIT_WRITE:                                                                                       
	   if (write_done)                                                                                
	     write_state <= IDLE;                                                          
	   else                                                                                            
	     begin                                                                                         
	        write_state  <= INIT_WRITE;                                                              
	        
	        if (~m_axi_awvalid && ~start_write_burst && ~write_busy)                       
	          start_write_burst <= 1'b1;                                                       
	        else                                                                                        
	          start_write_burst <= 1'b0;
	     end                                                                                           
	 default :                                                                                         
	   write_state  <= IDLE;                                                              
       endcase                                                                                             
   

   
   // Read state machine
   always @ ( posedge m_axi_aclk)                                                                            
     if ( ~m_axi_aresetn )                                                                             
       begin                                                                                                 
	  read_state      <= IDLE;                                                                
	  start_read_burst  <= 1'b0;                                                                   
       end                                                                                                   
     else                                                                                                    
       case (read_state)                                                                               
	 
	 IDLE:                                                                                     
	   if ( init_read_pulse )
	     read_state  <= INIT_WRITE;                                                              
	   else                                                                                            
	     read_state  <= IDLE;                                                            
	 
	 INIT_READ:                                                                                        
	   if (read_done)                                                                                 
	     read_state <= IDLE;                                                             
	   else                                                                                            
	     begin                                                                                         
	        read_state  <= INIT_READ;                                                               
	        
	        if (~m_axi_arvalid && ~start_read_burst && ~read_busy )                         
	          start_read_burst <= 1'b1;                                                        
	        else                                                                                         
	          start_read_burst <= 1'b0;
	     end                                                                                           
	 default :                                                                                         
	   read_state  <= IDLE;                                                              
       endcase                                                                                             


   
   // Write busy signal
   always @(posedge m_axi_aclk)                                                                              
     begin                                                                                                     
	if ( ~m_axi_aresetn || init_write_pulse )                                                                                 
	  write_busy <= 1'b0;                                                                           
	else if (start_write_burst)                                                                      
	  write_busy <= 1'b1;                                                                           
	else if (b_ack)                                                                    
	  write_busy <= 0;                                                                              
     end                                                                                                       
   
   always @(posedge m_axi_aclk)                                                                              
     begin                                                                                                     
	if (~m_axi_aresetn || init_write_pulse )                                                                                 
	  write_done <= 1'b0;                                                                                  
	
	else if (b_ack && (write_counter == dma_wrlen)) //TODO make copy of dma_welen in write initial phase, dma_wrlen-1?                    
	  write_done <= 1'b1;                                                                                  
	else                                                                                                    
	  write_done <= write_done;                                                                           
     end                                                                                                     
   
   // Read busy signal
   always @(posedge m_axi_aclk)                                                                              
     begin                                                                                                     
	if (~m_axi_aresetn || init_read_pulse )                                                                                 
	  read_busy <= 1'b0;                                                                            
	else if (start_read_burst)                                                                       
	  read_busy <= 1'b1;                                                                            
	else if (r_ack && m_axi_rlast)                                                     
	  read_busy <= 0;                                                                               
     end                                                                                                     
   
   // Read done signal
   always @(posedge m_axi_aclk)                                                                              
     begin                                                                                                     
	if (~m_axi_aresetn || init_txn_pulse )                                                                                 
	  read_done <= 1'b0;                                                                                   
	
	else if ( r_ack && (read_counter == dma_wr_len)) //TODO: read_counter-1? 
	  read_done <= 1'b1;                                                                                   
	else                                                                                                    
	  read_done <= read_done;                                                                             
     end                                                                                                     



endmodule




