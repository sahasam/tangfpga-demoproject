# ============================================================
# build.tcl — Automated Gowin Build Script
# ============================================================
# 1. Creates a project
# 2. Adds top.v
# 3. Creates and generates an IP
# 4. Runs synthesis and place & route
# ============================================================

# --- USER PARAMETERS ----------------------------------------
set prj_name "counter"
set top_name "top"
set device "GW2AR-LV18QN88C8/I7"
set device_version "C"

# Get project root directory (assuming script is in build/ subdirectory)
set script_dir [file dirname [file normalize [info script]]]
set project_root [file dirname $script_dir]
set prj_dir "$project_root/gowin_project"

# --- CREATE PROJECT -----------------------------------------
create_project -name $prj_name -dir $prj_dir -pn $device -device_version $device_version -force

# --- ADD DESIGN SOURCE --------------------------------------
add_file $project_root/src/top.v
add_file $project_root/build/constraints.cst
set_option -top_module $top_name

# --- SYNTHESIS OPTIONS --------------------------------------
set_option -verilog_std sysv2017
set_option -global_freq 100
set_option -print_all_synthesis_warning 1

# --- PLACE & ROUTE OPTIONS ----------------------------------
set_option -timing_driven 1
set_option -gen_sdf 1
set_option -gen_verilog_sim_netlist 1
set_option -gen_text_timing_rpt 1
set_option -gen_io_cst 1
set_option -show_all_warn 1

# --- RUN FLOWS ----------------------------------------------
run all
# Alternatively:
#run syn
#run pnr

# --- SAVE SCRIPT SNAPSHOT -----------------------------------
saveto -all_options $project_root/build_snapshot.tcl

# --- CLOSE PROJECT ------------------------------------------
run close