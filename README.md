# FPGA Test Project

A simple FPGA counter project with cocotb testbench, using Gowin EDA for synthesis and openFPGALoader for programming.

## Requirements

This project requires several tools to be installed and configured. **Note that the paths specified in this project are specific to the author's machine configuration and will likely need to be adjusted for your setup.** This is a reference implementation, not a drop-in template.

### 1. TCL Interpreter

The build process uses TCL scripts for Gowin EDA. The TCL interpreter is typically bundled with Gowin EDA (as `gw_sh`), so no separate TCL installation is required. The `gw_sh_wrapper.sh` script handles the TCL execution through Gowin's shell.

### 2. Gowin EDA

[Gowin EDA](https://www.gowinsemi.com/en/support/download_eda/) is required for FPGA synthesis, place & route, and bitstream generation.

**Installation:**
- Download from the Gowin website (registration required)
- Install the macOS version (`.dmg` file)
- The project expects Gowin IDE to be installed at: `/Applications/GowinIDE.app`
  - **You will need to update `gw_sh_wrapper.sh` if your installation is in a different location**

The `gw_sh_wrapper.sh` script sets up the necessary environment variables (`GOWIN_EDA_HOME`, `DYLD_FRAMEWORK_PATH`, etc.) and executes the build TCL script.

### 3. openFPGALoader

[openFPGALoader](https://github.com/trabucayre/openFPGALoader) is used to program the FPGA with the generated bitstream.

**Installation:**
- Available via `oss-cad-suite` or can be built from source
- The project expects it at: `/opt/oss-cad-suite/bin/openFPGALoader`
  - **You will need to update the `OPENFPGALOADER` variable in the Makefile if your installation is in a different location**

### 4. Cocotb (Python Testing Framework)

Cocotb is required for running the testbench simulations. **You need to have cocotb installed in your Python environment before running the Makefile.**

**Recommended Setup (Virtual Environment):**
```bash
# Create a virtual environment
python3 -m venv env

# Activate the virtual environment
source env/bin/activate  # On macOS/Linux
# OR
env\Scripts\activate  # On Windows

# Install cocotb
pip install cocotb
```

**Important:** Make sure the virtual environment is **active** before running any Makefile targets. The Makefile uses `cocotb-config` to locate cocotb's makefiles.

### 5. Verilog Simulator (Icarus Verilog)

The project uses Icarus Verilog (`iverilog`) as the default simulator. Install via:
```bash
# macOS
brew install icarus-verilog

# Ubuntu/Debian
sudo apt-get install iverilog

# Or install as part of oss-cad-suite
```

## Project Structure

```
.
├── src/
│   └── top.v              # Main Verilog module
├── build/
│   ├── build.tcl          # Gowin EDA build script
│   └── constraints.cst    # Pin constraints
├── tests/
│   └── test_top.py        # Cocotb testbench
├── Makefile               # Build automation
└── gw_sh_wrapper.sh       # Gowin EDA shell wrapper
```

## Usage

### Setup

1. **Install all required tools** (see Requirements above)
2. **Update paths** in `Makefile` and `gw_sh_wrapper.sh` to match your installation
3. **Create and activate a virtual environment** with cocotb installed:
   ```bash
   python3 -m venv env
   source env/bin/activate
   pip install cocotb
   ```

### Building the Bitstream

```bash
# Make sure your venv is active!
make build
```

This will:
- Run Gowin EDA synthesis, place & route
- Generate the bitstream at `gowin_project/counter/impl/pnr/counter.fs`

### Programming the FPGA

```bash
make program
```

This will use openFPGALoader to program the FPGA with the generated bitstream.

### Running Tests

```bash
# Make sure your venv is active!
make test
```

This runs the cocotb testbench, which:
- Compiles the Verilog
- Runs Python tests
- Generates waveforms (`waves.vcd`)

### Cleaning Build Artifacts

```bash
make clean
```

Removes all generated files (cocotb build outputs, Gowin project files, waveforms, etc.)

## Customization

### Updating Tool Paths

1. **Gowin EDA**: Edit `gw_sh_wrapper.sh` and update the `APP` variable to point to your Gowin IDE installation
2. **openFPGALoader**: Edit `Makefile` and update the `OPENFPGALOADER` variable
3. **Device Selection**: Edit `build/build.tcl` and update the `device` variable for your target FPGA

### Pin Constraints

Edit `build/constraints.cst` to match your board's pin assignments.

## Troubleshooting

- **`gw_sh command not found`**: Check that `gw_sh_wrapper.sh` has the correct path to Gowin IDE
- **`cocotb-config: command not found`**: Make sure your virtual environment is activated and cocotb is installed
- **`openFPGALoader: command not found`**: Update the path in Makefile or add it to your PATH
- **Permission errors**: Make sure `gw_sh_wrapper.sh` is executable: `chmod +x gw_sh_wrapper.sh`

## Notes

- This is a reference implementation based on the author's specific machine configuration
- Paths are hardcoded and will need adjustment for different systems
- The project targets Gowin GW2AR-18 FPGA, adjust device selection in `build.tcl` for other parts
- Testbench assumes active-high reset signal

