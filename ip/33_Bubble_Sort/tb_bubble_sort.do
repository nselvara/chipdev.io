onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider DuT
add wave -noupdate -divider Interface
add wave -noupdate /tb_bubble_sort/clk
add wave -noupdate /tb_bubble_sort/rst_n
add wave -noupdate /tb_bubble_sort/sortit
add wave -noupdate /tb_bubble_sort/din
add wave -noupdate /tb_bubble_sort/dout
add wave -noupdate -divider Internal
add wave -noupdate -radix unsigned /tb_bubble_sort/DuT/bubble_sorter/memory
add wave -noupdate -radix unsigned /tb_bubble_sort/DuT/bubble_sorter/temp
add wave -noupdate -radix unsigned /tb_bubble_sort/DuT/bubble_sorter/counter
add wave -noupdate -radix hexadecimal -childformat {{/tb_bubble_sort/DuT/bubble_sorter/sorted_vector(24) -radix unsigned} {/tb_bubble_sort/DuT/bubble_sorter/sorted_vector(23) -radix unsigned} {/tb_bubble_sort/DuT/bubble_sorter/sorted_vector(22) -radix unsigned} {/tb_bubble_sort/DuT/bubble_sorter/sorted_vector(21) -radix unsigned} {/tb_bubble_sort/DuT/bubble_sorter/sorted_vector(20) -radix unsigned} {/tb_bubble_sort/DuT/bubble_sorter/sorted_vector(19) -radix unsigned} {/tb_bubble_sort/DuT/bubble_sorter/sorted_vector(18) -radix unsigned} {/tb_bubble_sort/DuT/bubble_sorter/sorted_vector(17) -radix unsigned} {/tb_bubble_sort/DuT/bubble_sorter/sorted_vector(16) -radix unsigned} {/tb_bubble_sort/DuT/bubble_sorter/sorted_vector(15) -radix unsigned} {/tb_bubble_sort/DuT/bubble_sorter/sorted_vector(14) -radix unsigned} {/tb_bubble_sort/DuT/bubble_sorter/sorted_vector(13) -radix unsigned} {/tb_bubble_sort/DuT/bubble_sorter/sorted_vector(12) -radix unsigned} {/tb_bubble_sort/DuT/bubble_sorter/sorted_vector(11) -radix unsigned} {/tb_bubble_sort/DuT/bubble_sorter/sorted_vector(10) -radix unsigned} {/tb_bubble_sort/DuT/bubble_sorter/sorted_vector(9) -radix unsigned} {/tb_bubble_sort/DuT/bubble_sorter/sorted_vector(8) -radix unsigned} {/tb_bubble_sort/DuT/bubble_sorter/sorted_vector(7) -radix unsigned} {/tb_bubble_sort/DuT/bubble_sorter/sorted_vector(6) -radix unsigned} {/tb_bubble_sort/DuT/bubble_sorter/sorted_vector(5) -radix unsigned} {/tb_bubble_sort/DuT/bubble_sorter/sorted_vector(4) -radix unsigned} {/tb_bubble_sort/DuT/bubble_sorter/sorted_vector(3) -radix unsigned} {/tb_bubble_sort/DuT/bubble_sorter/sorted_vector(2) -radix unsigned} {/tb_bubble_sort/DuT/bubble_sorter/sorted_vector(1) -radix unsigned} {/tb_bubble_sort/DuT/bubble_sorter/sorted_vector(0) -radix unsigned}} -subitemconfig {/tb_bubble_sort/DuT/bubble_sorter/sorted_vector(24) {-height 15 -radix unsigned} /tb_bubble_sort/DuT/bubble_sorter/sorted_vector(23) {-height 15 -radix unsigned} /tb_bubble_sort/DuT/bubble_sorter/sorted_vector(22) {-height 15 -radix unsigned} /tb_bubble_sort/DuT/bubble_sorter/sorted_vector(21) {-height 15 -radix unsigned} /tb_bubble_sort/DuT/bubble_sorter/sorted_vector(20) {-height 15 -radix unsigned} /tb_bubble_sort/DuT/bubble_sorter/sorted_vector(19) {-height 15 -radix unsigned} /tb_bubble_sort/DuT/bubble_sorter/sorted_vector(18) {-height 15 -radix unsigned} /tb_bubble_sort/DuT/bubble_sorter/sorted_vector(17) {-height 15 -radix unsigned} /tb_bubble_sort/DuT/bubble_sorter/sorted_vector(16) {-height 15 -radix unsigned} /tb_bubble_sort/DuT/bubble_sorter/sorted_vector(15) {-height 15 -radix unsigned} /tb_bubble_sort/DuT/bubble_sorter/sorted_vector(14) {-height 15 -radix unsigned} /tb_bubble_sort/DuT/bubble_sorter/sorted_vector(13) {-height 15 -radix unsigned} /tb_bubble_sort/DuT/bubble_sorter/sorted_vector(12) {-height 15 -radix unsigned} /tb_bubble_sort/DuT/bubble_sorter/sorted_vector(11) {-height 15 -radix unsigned} /tb_bubble_sort/DuT/bubble_sorter/sorted_vector(10) {-height 15 -radix unsigned} /tb_bubble_sort/DuT/bubble_sorter/sorted_vector(9) {-height 15 -radix unsigned} /tb_bubble_sort/DuT/bubble_sorter/sorted_vector(8) {-height 15 -radix unsigned} /tb_bubble_sort/DuT/bubble_sorter/sorted_vector(7) {-height 15 -radix unsigned} /tb_bubble_sort/DuT/bubble_sorter/sorted_vector(6) {-height 15 -radix unsigned} /tb_bubble_sort/DuT/bubble_sorter/sorted_vector(5) {-height 15 -radix unsigned} /tb_bubble_sort/DuT/bubble_sorter/sorted_vector(4) {-height 15 -radix unsigned} /tb_bubble_sort/DuT/bubble_sorter/sorted_vector(3) {-height 15 -radix unsigned} /tb_bubble_sort/DuT/bubble_sorter/sorted_vector(2) {-height 15 -radix unsigned} /tb_bubble_sort/DuT/bubble_sorter/sorted_vector(1) {-height 15 -radix unsigned} /tb_bubble_sort/DuT/bubble_sorter/sorted_vector(0) {-height 15 -radix unsigned}} /tb_bubble_sort/DuT/bubble_sorter/sorted_vector
add wave -noupdate -divider {tb - Internal}
add wave -noupdate /tb_bubble_sort/simulation_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10411234 ps} 0}
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
WaveRestoreZoom {0 ps} {10963050 ps}
