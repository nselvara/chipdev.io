onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider DuT
add wave -noupdate -divider Interface
add wave -noupdate /tb_configurable_lfsr/clk
add wave -noupdate /tb_configurable_lfsr/rst_n
add wave -noupdate /tb_configurable_lfsr/din
add wave -noupdate /tb_configurable_lfsr/tap
add wave -noupdate /tb_configurable_lfsr/dout
add wave -noupdate -divider Internal
add wave -noupdate /tb_configurable_lfsr/configurable_lfsr_inst/lfsr/shift_reg
add wave -noupdate /tb_configurable_lfsr/configurable_lfsr_inst/lfsr/tap_reg
add wave -noupdate /tb_configurable_lfsr/configurable_lfsr_inst/lfsr/feedback
add wave -noupdate -divider {tb - Internal}
add wave -noupdate -expand -group expected /tb_configurable_lfsr/expected/shift_reg
add wave -noupdate -expand -group expected /tb_configurable_lfsr/expected/tap_reg
add wave -noupdate -expand -group expected /tb_configurable_lfsr/expected/feedback
add wave -noupdate /tb_configurable_lfsr/expected_dout
add wave -noupdate /tb_configurable_lfsr/simulation_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {15403508 ps} 0}
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
WaveRestoreZoom {0 ps} {16244550 ps}
