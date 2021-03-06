#/**************************************************/
#/* Compile Script for Synopsys                    */
#/*                                                */
#/* dc_shell-t -f compile_dc.tcl                   */
#/*                                                */
#/* OSU FreePDK 45nm                               */
#/**************************************************/

#/* All verilog files, separated by spaces         */
set my_verilog_files [list arbiterPN.v demux1to2.v demux1to5.v demuxWrapper1to2.v demuxWrapper1to5.v global.v highestBit.v mux2to1.v mux5to1.v muxWrapper2to1.v muxWrapper5to1.v outSelTrans.v permutationNetwork.v permuterBlock.v portAlloc.v portAllocLast.v portAllocTop.v portAllocWrapper.v routeComp.v topBLESS.v xbar5Ports.v xbarCtrl.v dff.v]

#/* Top-level Module                               */
#set my_toplevel topBLESS
#set my_toplevel portAllocWrapper 
#set my_toplevel permutationNetwork 
#set my_toplevel xbar5Ports 
#set my_toplevel routeComp 
set my_toplevel dff 

#/* The name of the clock pin. If no clock-pin     */
#/* exists, pick anything                          */
set my_clock_pin clk

#/* Target frequency in MHz for optimization       */
set my_clk_freq_MHz 500

set my_period 1.3   

#/* Delay of input signals (Clock-to-Q, Package etc.)  */
set my_input_delay_ns 0

#/* Reserved time for output signals (Holdtime etc.)   */
set my_output_delay_ns 0


#/**************************************************/
#/* No modifications needed below                  */
#/**************************************************/
set OSU_FREEPDK [format "%s%s"  [getenv "PDK_DIR"] "/osu_soc/lib/files"]
set search_path [concat  $search_path $OSU_FREEPDK]
#set alib_library_analysis_path $OSU_FREEPDK

set link_library [set target_library [concat  [list gscl45nm.db] [list dw_foundation.sldb]]]
set target_library "gscl45nm.db"
define_design_lib WORK -path /tmp/xxx1698/WORK
set verilogout_show_unconnected_pins "true"
set_ultra_optimization true
set_ultra_optimization -force
#set_switching_activity -toggle_rate 0.1
#create_operating_conditions -lib  /local/a2fay3/cad_sw/pdk/FreePDK45/osu_soc/lib/files/gscl45nm.db -voltage 0.85
#set_voltage 1.1 -object_list vdd
#compile_ultra -gate_clock

analyze -f verilog $my_verilog_files

elaborate $my_toplevel

current_design $my_toplevel

link
uniquify

create_operating_conditions -name NEW -library gscl45nm -process 1 -temperature 25 -voltage 0.85
set_operating_conditions NEW


#set my_period [expr 1000 / $my_clk_freq_MHz]
#set_voltage 0.9 -object_list __VDD 

#set_switching_activity -toggle_rate 0.1 -select {regs_on_clock {clk}} 
compile_ultra -gate_clock
#report_saif -missing
#propagate_switching_activity -verbose

set find_clock [ find port [list $my_clock_pin] ]
if {  $find_clock != [list] } {
   set clk_name $my_clock_pin
   create_clock -period $my_period $clk_name
} else {
   set clk_name vclk
   create_clock -period $my_period -name $clk_name
}

set_switching_activity -toggle_rate 0.1 -select {regs_on_clock {clk}} -select input 
set_driving_cell  -lib_cell INVX1  [all_inputs]
set_input_delay $my_input_delay_ns -clock $clk_name [remove_from_collection [all_inputs] $my_clock_pin]
set_output_delay $my_output_delay_ns -clock $clk_name [all_outputs]

compile -ungroup_all -map_effort medium

compile -incremental_mapping -map_effort medium

check_design
report_constraint -all_violators

set filename [format "%s%s"  $my_toplevel ".vh"]
write -f verilog -output /tmp/xxx1698/$filename

set filename [format "%s%s"  $my_toplevel ".sdc"]
write_sdc /tmp/xxx1698/$filename

set filename [format "%s%s"  $my_toplevel ".db"]
write -f db -hier -output /tmp/xxx1698/$filename -xg_force_db

redirect timing.rep { report_timing }
redirect cell.rep { report_cell }
redirect power.rep { report_power -cell }

quit
