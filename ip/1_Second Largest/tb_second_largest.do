onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_second_largest/clk
add wave -noupdate /tb_second_largest/rst_n
add wave -noupdate -divider {DuT - In}
add wave -noupdate /tb_second_largest/din
add wave -noupdate /tb_second_largest/dout
add wave -noupdate /tb_second_largest/DuT/filter/largest_value
add wave -noupdate /tb_second_largest/DuT/filter/second_largest_value
add wave -noupdate -divider {tb - Internal}
add wave -noupdate /tb_second_largest/simulation_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10054 ns} 0}
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
WaveRestoreZoom {0 ns} {10779 ns}
