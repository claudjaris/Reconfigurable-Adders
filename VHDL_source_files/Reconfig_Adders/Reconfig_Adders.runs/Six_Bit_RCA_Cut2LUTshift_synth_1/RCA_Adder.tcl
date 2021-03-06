# 
# Synthesis run script generated by Vivado
# 

set_param simulator.modelsimInstallPath C:/Modeltech_pe_edu_10.4a/win32pe_edu
set_param project.vivado.isBlockSynthRun true
create_project -in_memory -part xc7vx485tffg1761-2

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir C:/Users/s3081701/Dropbox/Diplomarbeit/XilinxProjects/Reconfig_Adders/Reconfig_Adders.cache/wt [current_project]
set_property parent.project_path C:/Users/s3081701/Dropbox/Diplomarbeit/XilinxProjects/Reconfig_Adders/Reconfig_Adders.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language VHDL [current_project]
set_property ip_output_repo c:/Users/s3081701/Dropbox/Diplomarbeit/XilinxProjects/Reconfig_Adders/Reconfig_Adders.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_vhdl -library xil_defaultlib {
  C:/Users/s3081701/Dropbox/Diplomarbeit/XilinxProjects/Reconfig_Adders/Reconfig_Adders.srcs/Six_Bit_RCA_Cut2LUTshift/imports/Reconfig_Adders/Pkg_Functions.vhd
  C:/Users/s3081701/Dropbox/Diplomarbeit/XilinxProjects/Reconfig_Adders/Reconfig_Adders.srcs/Six_Bit_RCA_Cut2LUTshift/imports/Reconfig_Adders/6bit_RCA_cut2LUTshift.vhd
}
# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}

synth_design -top RCA_Adder -part xc7vx485tffg1761-2 -mode out_of_context

rename_ref -prefix_all RCA_Adder_

write_checkpoint -force -noxdef RCA_Adder.dcp

catch { report_utilization -file RCA_Adder_utilization_synth.rpt -pb RCA_Adder_utilization_synth.pb }
