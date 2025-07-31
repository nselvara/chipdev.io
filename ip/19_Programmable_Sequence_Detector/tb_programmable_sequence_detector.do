onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {DuT - Interface}
add wave -noupdate /tb_programmable_sequence_detector/clk
add wave -noupdate /tb_programmable_sequence_detector/rst_n
add wave -noupdate -radix binary /tb_programmable_sequence_detector/init
add wave -noupdate /tb_programmable_sequence_detector/din
add wave -noupdate /tb_programmable_sequence_detector/seen
add wave -noupdate -divider {DuT - Internal}
add wave -noupdate -radix binary /tb_programmable_sequence_detector/programmable_sequence_detector_inst/init_reg
add wave -noupdate -radix binary /tb_programmable_sequence_detector/programmable_sequence_detector_inst/shift_reg
add wave -noupdate -radix unsigned /tb_programmable_sequence_detector/programmable_sequence_detector_inst/din_count
add wave -noupdate -divider {tb - Internal}
add wave -noupdate -radix binary /tb_programmable_sequence_detector/checker/init_reg
add wave -noupdate -radix binary /tb_programmable_sequence_detector/checker/shift_reg
add wave -noupdate /tb_programmable_sequence_detector/checker/expected_seen
add wave -noupdate /tb_programmable_sequence_detector/simulation_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10275 ns} 0}
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
WaveRestoreZoom {0 ns} {10932 ns}
