onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider DuT
add wave -noupdate -divider Interface
add wave -noupdate /tb_two_read_one_write_register_file/clk
add wave -noupdate /tb_two_read_one_write_register_file/rst_n
add wave -noupdate /tb_two_read_one_write_register_file/din
add wave -noupdate /tb_two_read_one_write_register_file/wad1
add wave -noupdate /tb_two_read_one_write_register_file/rad1
add wave -noupdate /tb_two_read_one_write_register_file/rad2
add wave -noupdate /tb_two_read_one_write_register_file/wen1
add wave -noupdate /tb_two_read_one_write_register_file/ren1
add wave -noupdate /tb_two_read_one_write_register_file/ren2
add wave -noupdate /tb_two_read_one_write_register_file/dout1
add wave -noupdate /tb_two_read_one_write_register_file/dout2
add wave -noupdate /tb_two_read_one_write_register_file/collision
add wave -noupdate -divider Internal
add wave -noupdate /tb_two_read_one_write_register_file/two_read_one_write_register_file_inst/memory
add wave -noupdate /tb_two_read_one_write_register_file/two_read_one_write_register_file_inst/register_file/collision_v
add wave -noupdate -divider {tb - Internal}
add wave -noupdate -expand -group expected /tb_two_read_one_write_register_file/checker/expected_memory
add wave -noupdate -expand -group expected /tb_two_read_one_write_register_file/checker/expected_dout1
add wave -noupdate -expand -group expected /tb_two_read_one_write_register_file/checker/expected_dout2
add wave -noupdate -expand -group expected /tb_two_read_one_write_register_file/checker/expected_collision
add wave -noupdate /tb_two_read_one_write_register_file/simulation_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10129506 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 159
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
WaveRestoreZoom {0 ps} {11131050 ps}
