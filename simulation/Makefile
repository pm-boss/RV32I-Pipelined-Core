# --- Variables ---
INC_DIR  = ../modules
BFLAGS   = -i $(INC_DIR) -f filelist.txt
TOP_MOD  = tb_pipeline
SNAPSHOT = riscv_sim
MEM_GEN  = ../mem_generator

# Vivado Tools
XVLOG = xvlog
XELAB = xelab
XSIM  = xsim

# Source files (used for dependency tracking)
V_SRCS = $(wildcard $(INC_DIR)/*.v) $(wildcard *.v)

.PHONY: help clean sort addition negative xor fibonacci run_sim

help:
	@echo "Usage: make <program_name> (e.g. make addition)"

# 1. Program Targets: These force memory generation, then trigger the simulation
sort addition negative xor fibonacci:
	@echo "=== Compiling C Code to Hex ==="
	$(MAKE) clean -C $(MEM_GEN)
	$(MAKE) $@ -C $(MEM_GEN)
	@echo "=== Starting Simulation Flow ==="
	$(MAKE) run_sim

# 2. Hardware Compilation: Only runs if Verilog sources or filelist change
# Vivado creates 'xsimk' inside the snapshot directory after successful elaboration
xsim.dir/$(SNAPSHOT)/xsimk: $(V_SRCS) filelist.txt
	@echo "=== Parsing Verilog ==="
	$(XVLOG) $(BFLAGS) 
	@echo "=== Elaborating Design ==="
	$(XELAB) -top $(TOP_MOD) -snapshot $(SNAPSHOT) -debug typical 

# 3. Execution: Depends on the elaboration snapshot
run_sim: xsim.dir/$(SNAPSHOT)/xsimk
	@echo "=== Running Simulation ==="
	$(XSIM) $(SNAPSHOT) -R 

# Clean up Vivado artifacts
clean:
	@echo "=== Cleaning Vivado Artifacts ==="
	@rm -rf xsim.dir/ .Xil/ 
	@rm -f xvlog.log xvlog.pb xelab.log xelab.pb xsim.log xsim.jou xsim.pb 
	@rm -f pipeline.vcd