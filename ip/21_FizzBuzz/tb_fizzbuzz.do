onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider DuTs
add wave -noupdate -divider {DuTs' - Interfaces}
add wave -noupdate /tb_fizzbuzz/clk
add wave -noupdate /tb_fizzbuzz/rst_n
add wave -noupdate -divider {DuT - Example 1}
add wave -noupdate -divider Interface
add wave -noupdate -group {Example 1 - Interface} -radix unsigned /tb_fizzbuzz/FIZZ_CYCLES_EXAMPLE_1
add wave -noupdate -group {Example 1 - Interface} -radix unsigned /tb_fizzbuzz/BUZZ_CYCLES_EXAMPLE_1
add wave -noupdate -group {Example 1 - Interface} -radix unsigned /tb_fizzbuzz/MAX_CYCLES_EXAMPLE_1
add wave -noupdate -group {Example 1 - Interface} /tb_fizzbuzz/fizz_example_1
add wave -noupdate -group {Example 1 - Interface} /tb_fizzbuzz/buzz_example_1
add wave -noupdate -group {Example 1 - Interface} /tb_fizzbuzz/fizzbuzz_example_1
add wave -noupdate -divider Internal
add wave -noupdate -group {Example 1 - Internal} -radix unsigned /tb_fizzbuzz/DuT_example_1/cycle_count
add wave -noupdate -group {Example 1 - Internal} -radix unsigned /tb_fizzbuzz/DuT_example_1/fizz_counter
add wave -noupdate -group {Example 1 - Internal} -radix unsigned /tb_fizzbuzz/DuT_example_1/buzz_counter
add wave -noupdate -divider {DuT - Random}
add wave -noupdate -divider Interface
add wave -noupdate -expand -group {Random - Interface} -radix unsigned /tb_fizzbuzz/FIZZ_CYCLES
add wave -noupdate -expand -group {Random - Interface} -radix unsigned /tb_fizzbuzz/BUZZ_CYCLES
add wave -noupdate -expand -group {Random - Interface} -radix unsigned /tb_fizzbuzz/MAX_CYCLES
add wave -noupdate -expand -group {Random - Interface} /tb_fizzbuzz/fizz
add wave -noupdate -expand -group {Random - Interface} /tb_fizzbuzz/buzz
add wave -noupdate -expand -group {Random - Interface} /tb_fizzbuzz/fizzbuzz
add wave -noupdate -divider Internal
add wave -noupdate -expand -group {Random - Internal} -radix unsigned /tb_fizzbuzz/DuT/cycle_count
add wave -noupdate -expand -group {Random - Internal} -radix unsigned /tb_fizzbuzz/DuT/fizz_counter
add wave -noupdate -expand -group {Random - Internal} -radix unsigned /tb_fizzbuzz/DuT/buzz_counter
add wave -noupdate -divider {tb - Internal}
add wave -noupdate -radix unsigned /tb_fizzbuzz/checker/expected_counter
add wave -noupdate -radix unsigned /tb_fizzbuzz/checker/expected_fizz_v
add wave -noupdate -radix unsigned /tb_fizzbuzz/checker/expected_buzz_v
add wave -noupdate -radix unsigned /tb_fizzbuzz/checker/expected_fizzbuzz_v
add wave -noupdate /tb_fizzbuzz/simulation_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3931 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 187
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
WaveRestoreZoom {0 ns} {10606 ns}
