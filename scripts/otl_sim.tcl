set hdl_path  hdl
set dv_path dv

xvlog -work work dv/spi_tb.v hdl/otl_spi.v
xelab work.spi_tb -debug all
xsim -g work.spi_tb
