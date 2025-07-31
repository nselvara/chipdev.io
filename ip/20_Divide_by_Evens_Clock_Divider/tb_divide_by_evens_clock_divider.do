onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {DuT - Interface}
add wave -noupdate /tb_divide_by_evens_clock_divider/clk
add wave -noupdate /tb_divide_by_evens_clock_divider/rst_n
add wave -noupdate /tb_divide_by_evens_clock_divider/clk_div_2
add wave -noupdate /tb_divide_by_evens_clock_divider/clk_div_4
add wave -noupdate /tb_divide_by_evens_clock_divider/clk_div_6
add wave -noupdate -divider {DuT - Internal}
add wave -noupdate -radix unsigned /tb_divide_by_evens_clock_divider/divide_by_evens_clock_divider_inst/clk_divider/clk_4_counter
add wave -noupdate -radix unsigned /tb_divide_by_evens_clock_divider/divide_by_evens_clock_divider_inst/clk_divider/clk_6_counter
add wave -noupdate -divider {tb - Internal}
add wave -noupdate -divider test_example_1
add wave -noupdate -group expected_clk_div_test_example /tb_divide_by_evens_clock_divider/checker/expected_clk_div_2_v
add wave -noupdate -group expected_clk_div_test_example /tb_divide_by_evens_clock_divider/checker/expected_clk_div_4_v
add wave -noupdate -group expected_clk_div_test_example /tb_divide_by_evens_clock_divider/checker/expected_clk_div_6_v
add wave -noupdate -divider test_random
add wave -noupdate -expand -group expected_clk_div_test_random /tb_divide_by_evens_clock_divider/expected_clk_div_2
add wave -noupdate -expand -group expected_clk_div_test_random /tb_divide_by_evens_clock_divider/expected_clk_div_4
add wave -noupdate -expand -group expected_clk_div_test_random /tb_divide_by_evens_clock_divider/expected_clk_div_6
add wave -noupdate -divider flags
add wave -noupdate /tb_divide_by_evens_clock_divider/simulation_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {19176 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 202
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
WaveRestoreZoom {0 ns} {25680 ns}
