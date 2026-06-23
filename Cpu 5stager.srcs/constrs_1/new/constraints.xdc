create_clock -period 15.940 -name clk -waveform {0.000 7.970} [get_ports {clk}]

set_false_path -from [get_ports {rst_n}]

set_output_delay -clock [get_clocks {clk}] -max 3.000 [get_ports {probe_pc[*]}]
set_output_delay -clock [get_clocks {clk}] -min 0.500 [get_ports {probe_pc[*]}]

set_output_delay -clock [get_clocks {clk}] -max 3.000 [get_ports {probe_alu_res[*]}]
set_output_delay -clock [get_clocks {clk}] -min 0.500 [get_ports {probe_alu_res[*]}]
