onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {DuT - Interface}
add wave -noupdate /tb_flip_flop_array/clk
add wave -noupdate /tb_flip_flop_array/rst_n
add wave -noupdate -radix unsigned /tb_flip_flop_array/din
add wave -noupdate -radix unsigned /tb_flip_flop_array/addr
add wave -noupdate /tb_flip_flop_array/wr
add wave -noupdate /tb_flip_flop_array/rd
add wave -noupdate -radix unsigned /tb_flip_flop_array/dout
add wave -noupdate /tb_flip_flop_array/error
add wave -noupdate -divider {DuT - Internal}
add wave -noupdate -radix unsigned /tb_flip_flop_array/flip_flop_array_inst/line__36/ff_array
add wave -noupdate -divider {tb - Internal}
add wave -noupdate -radix unsigned /tb_flip_flop_array/checker/expected_dout
add wave -noupdate /tb_flip_flop_array/checker/expected_error
add wave -noupdate /tb_flip_flop_array/simulation_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3551 ns} 0}
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
WaveRestoreZoom {0 ns} {10795 ns}
