onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {DuT - Interface}
add wave -noupdate /tb_divisible_by_3/clk
add wave -noupdate /tb_divisible_by_3/rst_n
add wave -noupdate /tb_divisible_by_3/din
add wave -noupdate /tb_divisible_by_3/dout
add wave -noupdate -divider {DuT - Internal}
add wave -noupdate /tb_divisible_by_3/divisible_by_3_inst/state
add wave -noupdate -divider {tb - Internal}
add wave -noupdate /tb_divisible_by_3/checker/expected_dout
add wave -noupdate /tb_divisible_by_3/simulation_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {122069 ns} 0}
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
WaveRestoreZoom {0 ns} {128227 ns}
