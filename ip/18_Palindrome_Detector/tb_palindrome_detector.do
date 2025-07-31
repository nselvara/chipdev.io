onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {DuT - Interface}
add wave -noupdate -radix binary /tb_palindrome_detector/din
add wave -noupdate /tb_palindrome_detector/dout
add wave -noupdate -divider {DuT - Internal}
add wave -noupdate -radix binary /tb_palindrome_detector/DuT/din_reversed
add wave -noupdate -divider {DuT Example - Interface}
add wave -noupdate -radix binary /tb_palindrome_detector/din_example_1
add wave -noupdate /tb_palindrome_detector/dout_example_1
add wave -noupdate -divider {DuT Example - Internal}
add wave -noupdate -radix binary /tb_palindrome_detector/DuT_example_1/din_reversed
add wave -noupdate -divider {tb - Internal}
add wave -noupdate /tb_palindrome_detector/simulation_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1788 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 158
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
WaveRestoreZoom {0 ns} {2313 ns}
