set_property PACKAGE_PIN AU39 [get_ports {s[7]}]
set_property PACKAGE_PIN AP42 [get_ports {s[6]}]
set_property PACKAGE_PIN AP41 [get_ports {s[5]}]
set_property PACKAGE_PIN AR35 [get_ports {s[4]}]
set_property PACKAGE_PIN AT37 [get_ports {s[3]}]
set_property PACKAGE_PIN AR37 [get_ports {s[2]}]
set_property PACKAGE_PIN AN39 [get_ports {s[1]}]
set_property PACKAGE_PIN AM39 [get_ports {s[0]}]
set_property PACKAGE_PIN BB31 [get_ports {a[7]}]
set_property PACKAGE_PIN BA30 [get_ports {a[6]}]
set_property PACKAGE_PIN AY30 [get_ports {a[5]}]
set_property PACKAGE_PIN AW30 [get_ports {a[4]}]
set_property PACKAGE_PIN BA32 [get_ports {a[3]}]
set_property PACKAGE_PIN BA31 [get_ports {a[2]}]
set_property PACKAGE_PIN AY33 [get_ports {a[1]}]
set_property PACKAGE_PIN AV30 [get_ports {a[0]}]

create_pblock pblock_ReConfig
add_cells_to_pblock [get_pblocks pblock_ReConfig] [get_cells -quiet [list ReConfig]]
resize_pblock [get_pblocks pblock_ReConfig] -add {SLICE_X48Y50:SLICE_X59Y99}
resize_pblock [get_pblocks pblock_ReConfig] -add {DSP48_X3Y20:DSP48_X3Y39}
resize_pblock [get_pblocks pblock_ReConfig] -add {RAMB18_X4Y20:RAMB18_X4Y39}
resize_pblock [get_pblocks pblock_ReConfig] -add {RAMB36_X4Y10:RAMB36_X4Y19}




set_property IOSTANDARD LVCMOS18 [get_ports {a[7]}]
set_property IOSTANDARD LVCMOS18 [get_ports {a[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {a[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {a[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {a[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {a[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {a[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {a[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {s[7]}]
set_property IOSTANDARD LVCMOS18 [get_ports {s[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {s[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {s[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {s[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {s[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {s[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {s[0]}]
