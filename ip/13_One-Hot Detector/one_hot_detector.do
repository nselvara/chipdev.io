onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {DuT - Interface}
add wave -noupdate -radix binary /tb_one_hot_detector/din
add wave -noupdate /tb_one_hot_detector/one_hot
add wave -noupdate -divider {tb - Internal}
add wave -noupdate /tb_one_hot_detector/checker/expected_onehot
add wave -noupdate /tb_one_hot_detector/simulation_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {11 ns} 0}
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
WaveRestoreZoom {0 ns} {1062 ns}
