onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {DuT - Interface}
add wave -noupdate /tb_full_adder/a
add wave -noupdate /tb_full_adder/b
add wave -noupdate /tb_full_adder/cin
add wave -noupdate -divider operators
add wave -noupdate -divider Interface
add wave -noupdate /tb_full_adder/sum_operators
add wave -noupdate /tb_full_adder/cout_operators
add wave -noupdate -divider Internal
add wave -noupdate -radix binary /tb_full_adder/DuT_operators_implementation/tmp_sum
add wave -noupdate -divider gate
add wave -noupdate -divider Interface
add wave -noupdate /tb_full_adder/sum_gate
add wave -noupdate /tb_full_adder/cout_gate
add wave -noupdate -divider {tb - Internal}
add wave -noupdate /tb_full_adder/simulation_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1003 ns} 0}
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
WaveRestoreZoom {0 ns} {1067 ns}
