`ifndef OTL_REGMAP_V_
 `define OTL_REGMAP_V_


//*************************
// ADC core registers
//*************************

// ADC core base address [15:12]
 `define ADC_CORE_ADDR 4'h1

// Registers
 `define ADC_ENABLE  5'd0



//*************************
// DAC core registers
//*************************

// DAC core base address [15:12]
 `define DAC_CORE_ADDR 4'h2



//*************************
// TRX core registers
//*************************

// TRX core base address [15:12]
 `define TRX_CORE_ADDR 4'h3
 `define TRX_CORE_SPI_ADDR 3'd7





`endif
