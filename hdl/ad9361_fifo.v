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


module ad9361_fifo
(
 //inputs
 wr_data, wr_clk, wr_en,
 
 //outputs
 
 );


   
   FIFO18E1 #
     (
      .ALMOST_EMPTY_OFFSET(13'h0080), // Sets the almost empty threshold
      .ALMOST_FULL_OFFSET(13'h0080), // Sets almost full threshold
      .DATA_WIDTH(4), // Sets data width to 4-36
      .DO_REG(1), // Enable output register (1-0) Must be 1 if EN_SYN = FALSE
      .EN_SYN("FALSE"), // Specifies FIFO as dual-clock (FALSE) or Synchronous (TRUE)
      .FIFO_MODE("FIFO18"), // Sets mode to FIFO18 or FIFO18_36
      .FIRST_WORD_FALL_THROUGH("FALSE"), // Sets the FIFO FWFT to FALSE, TRUE
      .INIT(36'h000000000), // Initial values on output port
      .SIM_DEVICE("7SERIES"), // Must be set to "7SERIES" for simulation behavior
      .SRVAL(36'h000000000) // Set/Reset value for output port
      )
   FIFO18E1_inst
     (
      // Read Data: 32-bit (each) output: Read output data
      .DO(wr_data), // 32-bit output: Data output
      .DOP(), // 4-bit output: Parity data output
      // Status: 1-bit (each) output: Flags and other FIFO status outputs
      .ALMOSTEMPTY(almost_empty),
      .ALMOSTFULL(almost_full),
      .EMPTY(empty),
      .FULL(full), 
      .RDCOUNT(), // 12-bit output: Read count
      .RDERR(), // 1-bit output: Read error
      .WRCOUNT(), // 12-bit output: Write count
      .WRERR(), // 1-bit output: Write error
      // Read Control Signals: 1-bit (each) input: Read clock, enable and reset input signals
      .RDCLK(rd_clk), // 1-bit input: Read clock
      .RDEN(rd_en), // 1-bit input: Read enable
      .REGCE(rd_ce), // 1-bit input: Clock enable
      .RST(reset), // 1-bit input: Asynchronous Reset
      .RSTREG(RSTREG), // 1-bit input: Output register set/reset
      // Write Control Signals: 1-bit (each) input: Write clock and enable input signals
      .WRCLK(wr_clk), // 1-bit input: Write clock
      .WREN(wr_en), // 1-bit input: Write enable
      // Write Data: 32-bit (each) input: Write input data
      .DI(rd_data), // 32-bit input: Data input
      .DIP() // 4-bit input: Parity input
      );
   
endmodule
