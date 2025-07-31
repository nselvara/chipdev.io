onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {DuT  - Interface}
add wave -noupdate /tb_multi_bit_fifo/clk
add wave -noupdate /tb_multi_bit_fifo/rst_n
add wave -noupdate -radix unsigned /tb_multi_bit_fifo/din
add wave -noupdate /tb_multi_bit_fifo/wr
add wave -noupdate -radix unsigned /tb_multi_bit_fifo/dout
add wave -noupdate /tb_multi_bit_fifo/full
add wave -noupdate /tb_multi_bit_fifo/empty
add wave -noupdate -divider {DuT - Internal}
add wave -noupdate -radix unsigned -childformat {{/tb_multi_bit_fifo/multi_bit_fifo_inst/fifo/memory(-1) -radix unsigned} {/tb_multi_bit_fifo/multi_bit_fifo_inst/fifo/memory(0) -radix unsigned} {/tb_multi_bit_fifo/multi_bit_fifo_inst/fifo/memory(1) -radix unsigned}} -expand -subitemconfig {/tb_multi_bit_fifo/multi_bit_fifo_inst/fifo/memory(-1) {-height 15 -radix unsigned} /tb_multi_bit_fifo/multi_bit_fifo_inst/fifo/memory(0) {-height 15 -radix unsigned} /tb_multi_bit_fifo/multi_bit_fifo_inst/fifo/memory(1) {-height 15 -radix unsigned}} /tb_multi_bit_fifo/multi_bit_fifo_inst/fifo/memory
add wave -noupdate -radix unsigned /tb_multi_bit_fifo/multi_bit_fifo_inst/fifo/write_count
add wave -noupdate -divider {tb - Internal}
add wave -noupdate -radix unsigned /tb_multi_bit_fifo/checker/random_data
add wave -noupdate -radix unsigned /tb_multi_bit_fifo/checker/expected_value
add wave -noupdate /tb_multi_bit_fifo/simulation_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1690 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {2815 ns}
