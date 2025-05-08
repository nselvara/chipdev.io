onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {DuT - Interface}
add wave -noupdate /tb_stopwatch_timer/clk
add wave -noupdate /tb_stopwatch_timer/reset
add wave -noupdate /tb_stopwatch_timer/start_in
add wave -noupdate /tb_stopwatch_timer/stop_in
add wave -noupdate -radix unsigned /tb_stopwatch_timer/count_out
add wave -noupdate -divider {DuT - Internal}
add wave -noupdate /tb_stopwatch_timer/stopwatch_timer_inst/stopwatch/start_reg
add wave -noupdate -divider {tb - Internal}
add wave -noupdate /tb_stopwatch_timer/start_reg
add wave -noupdate -radix unsigned /tb_stopwatch_timer/checker/expected_count
add wave -noupdate /tb_stopwatch_timer/simulation_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {71932 ns} 0}
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
WaveRestoreZoom {0 ns} {81156 ns}
