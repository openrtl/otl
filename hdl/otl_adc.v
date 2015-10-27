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


module otl_adc
  (
   sys_clk, reset,
   rx_data_p, rx_data_n, rx_frame_p,
   rx_frame_n, rx_clk_p, rx_clk_n, cfg_wraddr, 
   cfg_wrdata, cfg_wrvalid, cfg_rdready, cfg_rdaddr,
   dma_wraddr, dma_wrdata, dma_wrvalid,
   
   // outputs
   cfg_rddata, cfg_rdvalid, cfg_wrready, dma_wrready
     );

   parameter ADDRW = 32;
   parameter DATAW = 32;
   
   
   // System signals
   input sys_clk;
   input reset;

   // ADC input signals
   input [5:0] rx_data_p;
   input [5:0] rx_data_n;
   input       rx_frame_p;
   input       rx_frame_n;
   input       rx_clk_p;
   input       rx_clk_n;
    
   // Config interface
   input [ADDRW-1 : 0]       cfg_rdaddr;
   output reg [DATAW-1 :0 ]  cfg_rddata;
   output 		     cfg_rdvalid;
   input 		     cfg_rdready;
   input [ADDRW-1 : 0] 	     cfg_wraddr;
   input [DATAW-1 : 0] 	     cfg_wrdata;
   input 		     cfg_wrvalid;
   output 		     cfg_wrready;
   
   // DMA interface
   input [ADDRW-1 : 0] 	     dma_wraddr;
   input [DATAW-1 : 0] 	     dma_wrdata;
   input 		     dma_wrvalid;
   output 		     dma_wrready;

   
   wire [DATAW-1:0]     cfg_mem[1<<CFG_ADDRW-1:0];
   wire 		adc_enable;


   assign adc_enable = cfg_mem[`ADC_CORE_ENABLE];
   

     // Move into adc_core?
   otl_cfg_mem otl_cfg_mem_i
     (
      .wraddr(cfg_wraddr), 
      .wrdata(cfg_wrdata), 
      .wrvalid(cfg_wrvalid), 
      .rdready(cfg_rdready),
      .rdaddr(cfg_rdaddr), 
      .clk(sys_clk), 
      .reset(reset), 
      .rddata(cfg_rddata),
      .rdvalid(cfg_rdvalid), 
      .wrready(cfg_wrready), 
      .mem_expose(cfg_mem)); // TODO add mem wire ADDRW = depth

 
   otl_adc_core otl_adc_core_i
     (
      .enable(adc_enable), // just enable for now..
      .clk(sys_clk),
      .reset(reset),
      .dma_wraddr(dma_wraddr),
      .dma_wrdata(dma_wrdata),
      .dma_wrvalid(dma_wrvalid),
      .dma_wrready(dma_wrready),
      .fifo_rddata(fifo_rddata),
      .fifo_full(fifo_full),
      .fifo_rden(fifo_rden));

   
   otl_fifo otl_fifo_i
     (
      .rd_data	      (fifo_rddata),
      //.almost_empty (almost_empty),
      .amlost_full    (fifo_full),
      //.empty	      (empty),
      //.full		(full),
      .wr_data				(fifo_wrdata),
      .wr_clk				(rx_clk),
      .wr_en				(fifo_wren),
      .rd_clock				(sys_clk),
      .rd_en				(fifo_rden),
      .reset				(reset));
      
   otl_pack otl_pack_i
     (/*AUTOINST*/
      // Outputs
      .data_o				(fifo_wrdata),
      .frame_o				(fifo_wren),
      // Inputs
      .data_i				(rx_data),
      .frame_i				(rx_frame & adc_enable),
      .clk				(rx_clk));

   otl_adc_rx otl_adc_rx_i
     (/*AUTOINST*/
      // Outputs
      .rx_data				(rx_data),
      .rx_frame				(rx_frame),
      .rx_clk                           (rx_clk),
      // Inputs
      .rx_data_p			(rx_data_p),
      .rx_data_n			(rx_data_n),
      .rx_frame_p			(rx_frame_p),
      .rx_frame_n			(rx_frame_n),
      .rx_clk_p				(rx_clk_p),
      .rx_clk_n				(rx_clk_n));
   
   
   

endmodule
