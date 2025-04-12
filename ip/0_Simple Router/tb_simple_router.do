onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {DuT - In}
add wave -noupdate -radix unsigned /tb_simple_router/din
add wave -noupdate /tb_simple_router/din_en
add wave -noupdate -radix unsigned /tb_simple_router/addr
add wave -noupdate -radix unsigned /tb_simple_router/dout0
add wave -noupdate -radix unsigned /tb_simple_router/dout1
add wave -noupdate -radix unsigned /tb_simple_router/dout2
add wave -noupdate -radix unsigned /tb_simple_router/dout3
add wave -noupdate -divider {tb - Internal}
add wave -noupdate /tb_simple_router/simulation_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1395 ns} 0}
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
WaveRestoreZoom {0 ns} {2109 ns}
