onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider DuT
add wave -noupdate -divider Interface
add wave -noupdate /tb_mealy_finite_state_machine/clk
add wave -noupdate /tb_mealy_finite_state_machine/rst_n
add wave -noupdate /tb_mealy_finite_state_machine/din
add wave -noupdate /tb_mealy_finite_state_machine/cen
add wave -noupdate /tb_mealy_finite_state_machine/doutx
add wave -noupdate /tb_mealy_finite_state_machine/douty
add wave -noupdate -divider Internal
add wave -noupdate /tb_mealy_finite_state_machine/DuT/present_state
add wave -noupdate /tb_mealy_finite_state_machine/DuT/next_state
add wave -noupdate /tb_mealy_finite_state_machine/DuT/din_reg
add wave -noupdate /tb_mealy_finite_state_machine/DuT/cen_reg
add wave -noupdate -divider {tb - Internal}
add wave -noupdate /tb_mealy_finite_state_machine/simulation_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1975000 ps} 0}
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
WaveRestoreZoom {0 ps} {10889550 ps}
