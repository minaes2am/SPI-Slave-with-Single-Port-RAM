vlib work
vlog  SPI.v RAM.v SPI_WRAPPER.v Test_Bench.v 
vsim -voptargs=+acc work.test 
add wave -position insertpoint  \
sim:/test/DUT/RAM/mem
add wave *
run -all
#quit -sim