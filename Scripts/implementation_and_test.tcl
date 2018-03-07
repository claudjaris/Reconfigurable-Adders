# Retrieve Project Parameters
# change top name, testbench name and FPGA-Board accordingly
set TOP top    ; #top
set TB top_tb  ; #testbench
set PART xc7k70tfbg676-3  ; #FPGA-Board

# Exploration Parameters
set tt 6.4 ;    # Time to Test
set ts 20.0 ;   # Succesful Time
set tm 3.3 ;    # Miminum possible Time
set LUTs 0 ;    # LUT amount
set p 0.0 ;     # power in watt
set slack 8.0 ; # current slack
set tmp_slack 25 ;   # last loops slack
set WNS 100.0 ;   # Worst Negative Slack
# Assertion: tm <= tt <= ts

create_project -part $PART Vivado_Project

# ############################################ #
# read vhdl files, you have to change those!!! #
# ############################################ #
read_vhdl -library xil_defaultlib {
  Pkg_Functions.vhd
  RCA_basic.vhd
  RCA_LUT.vhd
  RCA_cut1LUT.vhd
  RCA_cut1LUT_switch.vhd
  RCA_cut2LUT.vhd
  RCA_cut2LUT_switch.vhd
  QuAd_LUT.vhd
  top.vhd
  top_tb.vhd
}

# set project properties for the top file and testbench
set_property USED_IN_SYNTHESIS 0 [get_files $TB.vhd]
set_property top $TOP [current_fileset]
set_property top_file $TOP.vhd [current_fileset]

# -----------------------------------------------------------------------------
# Run Synthesis
synth_design -top $TOP -part $PART

# -----------------------------------------------------------------------------
# while loop, updating Clock
# stop when the difference of positive slack and time to test is less than 3%
while {$WNS > $ts*0.03 || $WNS < 0} {

  # create new clock each run
  create_clock -name clk -period $tt [get_port clk]
  set_max_delay $tt -from [all_inputs] -to [all_outputs]
  
  # -----------------------------------------------------------------------------
  # Place & Route
  
  opt_design -directive Explore
  place_design -directive Explore
  phys_opt_design -directive Explore
  route_design -directive Explore 
  
  # -----------------------------------------------------------------------------
  # Report timing
  
  report_drc
  report_timing -setup -hold -max_paths 3 -nworst 3 -input_pins -sort_by group -file  $TOP.twr
  report_timing_summary -delay_type min_max -path_type full_clock_expanded -report_unconstrained -check_timing_verbose -max_paths 3 -nworst 3 -significant_digits 3 -input_pins -file $TOP.twr
  
  # -----------------------------------------------------------------------------
  # find maximum Data Path Delay and Slack
  set f [open $TOP.twr r]
  set file_data [read $f]
  close $f
  if {[regexp { +Data Path Delay: +(\d+\.\d+)} $file_data -> value]} {
    set tr $value
  } 
  
  # Unregistered version
  if {[regexp { +slack +([-]?\d+\.\d+) +} $file_data -> slack]} {
    puts ------------------------------------------
    puts $slack
    puts $tt
    puts ------------------------------------------
  }
  
  # -----------------------------------------------------------------------------
  # check if Timing was met
  if { $tt < $tr } {
    puts  {Timing was NOT met!}
    set tm $tt
    if { $tr < $ts } {
      set ts $tr
    }
  } else {
    set ts $tt
  }
  
  # -----------------------------------------------------------------------------
  # set new clock timing
  set ttn [expr { ($ts + $tm)/2}]
  
  set tt $ttn
  if { $slack == $WNS } {
    set tt [expr { $tt - $slack }]
  }
  # prevent an infinte loop by comparing last slack with current one
  if { $tmp_slack == $WNS } {
    set tt [expr { $tt - $tmp_slack }]
  }
  set tmp_slack $WNS
  set WNS $slack
}
# end of while loop

# set testbench top
set_property top $TB [get_filesets sim_1]

# set saif and testbench settings, your top in the testbench must be instantiated as DUT
set_property -name {xsim.simulate.runtime} -value {-all} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.saif_scope} -value {DUT} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.saif} -value {power.saif} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.saif_all_signals} -value {true} -objects [get_filesets sim_1]

# set power report unit
set_units -power uW

# write netlist
write_vhdl -mode funcsim  -force $TOP\_netlist.vhd

# prepare testbench input files
for {set i 1} {$i < 4} {incr i} {
  set f [open $TB.vhd r+]
  set file_data [read $f]
  set newf [open $TB.$i w]
  regsub -all "tb_inputA[0-9]" $file_data tb_inputA$i chgA
  regsub -all "tb_inputB[0-9]" $chgA tb_inputB$i chgB
  puts $newf $chgB
  close $f
  close $newf
  file rename -force $TB.$i $TB.vhd
  
  # start simulation
  launch_simulation -simset sim_1 -mode post-implementation -type functional

  close_sim
  
  # report utilization
  report_utilization -hierarchical
  
  # report power with saif file
  read_saif Vivado_Project.sim/sim_1/impl/func/power.saif
  report_power -file power.pwr -hier all

  set v [open power.pwr r]
  set file_data [read $v]
  close $v
  if {[regexp -all {\| +gen[A-Za-z0-9_\.]+ +\| +(\d+\.\d+)} $file_data -> power]} {
  set powerR$i $power
  puts $power
  }
}
close_project  

# extract LUT and Carry Chain count together with the power consumption of the module
# and write it all back including succesful timing in a file named RESULT
set v [open power.pwr r]
set file_data [read $v]
close $v
if {[regexp -all {\| +LUT as Logic +\| +\d+\.\d+ +\| +(\d+)} $file_data -> LUTsize]} {
  set LUTs $LUTsize
} else {
  set LUTs 0
}
if {[regexp -all {\| +CARRY4 +\| +\d+\.\d+ +\| +(\d+)} $file_data -> CARRYsize]} {
  set CCs $CARRYsize
} else {
  set CCs 0
}
set p [expr { ($powerR1 + $powerR2 + $powerR3)/3}]

set outfile [open RESULT w]
puts $outfile "$ts  $LUTs  $CCs  $p"
close $outfile
