TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(PWD)/src/top.v
TOPLEVEL = top
MODULE = tests.test_top

SIM ?= icarus

include $(shell cocotb-config --makefiles)/Makefile.sim

# Gowin EDA paths
GOWIN_SHELL ?= $(CURDIR)/gw_sh_wrapper.sh
OPENFPGALOADER ?= /opt/oss-cad-suite/bin/openFPGALoader
BITSTREAM_PATH = gowin_project/counter/impl/pnr/counter.fs

.PHONY: test clean build program

# Run cocotb simulation (produces waves.vcd via RTL dump block)
test: sim

# Build FPGA bitstream using Gowin EDA
build: build/build.tcl build/constraints.cst src/top.v
	$(GOWIN_SHELL) $(CURDIR)/build/build.tcl

# Program FPGA using openFPGALoader
program: $(BITSTREAM_PATH)
	$(OPENFPGALOADER) -b gowin $(BITSTREAM_PATH)

# Remove cocotb build outputs, waveform, and Gowin build artifacts
clean::
	$(MAKE) -f $(shell cocotb-config --makefiles)/Makefile.sim clean || true
	rm -rf sim_build waves.vcd __pycache__ .pytest_cache
	rm -rf impl *.fs *.log *.json
	rm -rf gowin_project build_snapshot.tcl

