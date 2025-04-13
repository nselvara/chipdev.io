onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {DuT - In}
add wave -noupdate /tb_serialiser/clk
add wave -noupdate /tb_serialiser/rst_n
add wave -noupdate /tb_serialiser/din
add wave -noupdate /tb_serialiser/din_en
add wave -noupdate /tb_serialiser/dout
add wave -noupdate -divider {DuT - Internal}
add wave -noupdate /tb_serialiser/serialiser_inst/bit_index
add wave -noupdate /tb_serialiser/serialiser_inst/din_reg
add wave -noupdate -divider {tb - Internal}
add wave -noupdate /tb_serialiser/simulation_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1930 ns} 0}
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
WaveRestoreZoom {0 ns} {3120 ns}
