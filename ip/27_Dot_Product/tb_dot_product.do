onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {DuT - Interface}
add wave -noupdate /tb_dot_product/clk
add wave -noupdate /tb_dot_product/rst_n
add wave -noupdate -radix unsigned /tb_dot_product/din
add wave -noupdate -radix unsigned /tb_dot_product/dout
add wave -noupdate /tb_dot_product/run_out
add wave -noupdate -divider {DuT - Internal}
add wave -noupdate -radix unsigned /tb_dot_product/dot_product_inst/calculator/vectors
add wave -noupdate -radix unsigned /tb_dot_product/dot_product_inst/calculator/count
add wave -noupdate -divider {tb - Internal}
add wave -noupdate -radix unsigned /tb_dot_product/checker/expected_dout
add wave -noupdate /tb_dot_product/simulation_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {364 ns} 0}
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
WaveRestoreZoom {0 ns} {1020 ns}
