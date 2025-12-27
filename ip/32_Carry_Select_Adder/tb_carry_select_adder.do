onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider DuT
add wave -noupdate -divider Interface
add wave -noupdate /tb_carry_select_adder/a
add wave -noupdate /tb_carry_select_adder/b
add wave -noupdate /tb_carry_select_adder/sum
add wave -noupdate -divider Internal
add wave -noupdate /tb_carry_select_adder/carry_select_adder_inst/stage_block_width_a
add wave -noupdate /tb_carry_select_adder/carry_select_adder_inst/stage_block_width_b
add wave -noupdate /tb_carry_select_adder/carry_select_adder_inst/stage_block_width_carry_out
add wave -noupdate /tb_carry_select_adder/carry_select_adder_inst/stage_block_width_sum
add wave -noupdate /tb_carry_select_adder/carry_select_adder_inst/stage_remainder_width_a
add wave -noupdate /tb_carry_select_adder/carry_select_adder_inst/stage_remainder_width_b
add wave -noupdate /tb_carry_select_adder/carry_select_adder_inst/stage_remainder_width_carry_out
add wave -noupdate /tb_carry_select_adder/carry_select_adder_inst/stage_remainder_width_sum
add wave -noupdate -divider {tb - Internal}
add wave -noupdate /tb_carry_select_adder/simulation_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1004746 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 247
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
WaveRestoreZoom {0 ps} {1056300 ps}
