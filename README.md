# RV32I 3-Stage Pipelined Processor

A structural Verilog implementation of a 3-stage pipelined RISC-V CPU core supporting the RV32I base integer instruction set.

This project implements a custom pipelined architecture tailored for efficient execution, featuring data forwarding, branch hazard mitigation, and synchronous block memory.

## Architecture Overview

The processor pipeline is divided into three distinct stages to balance the critical path and maximize throughput:

1. **Instruction Fetch & Decode (IF/ID)**
   - Fetches instructions from a 4KB byte-addressable instruction memory.
   - Decodes incoming RV32I opcodes to generate pipeline control signals.
   - Performs immediate generation and sign-extension for `I-type`, `S-type`, `B-type`, `U-type`, and `J-type` instructions.
   - Contains the Exception Detection logic for illegal instructions and misaligned fetches.

2. **Execute (EX)**
   - Features a versatile ALU supporting arithmetic, bitwise, and logical shift operations.
   - Computes branch comparison logic (both signed and unsigned) to evaluate conditions natively.
   - Calculates Target Addresses for branches/jumps and Memory Addresses for load/stores.
   - Includes pipelined registers storing control signals for the WB stage.

3. **Write-Back & Memory (WB)**
   - Interfaces with a 4KB synchronous Data Memory module supporting byte-level write strobes (`SB`, `SH`, `SW`).
   - Handles memory read operations with appropriate sign/zero extensions (`LB`, `LHU`, etc.).
   - Resolves Write-Back to the Register File.

## Project Structure

* **`src/`**: Core Verilog implementation of the RV32I pipeline stages and memory modules.
* * **`include/`**: Contains header files (`opcode.vh`) defining RISC-V instructions and control signals.
* **`testbench/`**: Verilog testbenches for automated simulation and verification of the processor pipeline.
* **`simulation/`**: The Vivado `Makefile` and environment setup for hardware simulation.
* **`mem_generator/`**: C-to-Hex toolchain including the cross-compiler Makefile and test programs (Fibonacci, Sort, etc.).
* **`top_fpga.v`**: The top-level module for FPGA synthesis, mapping processor I/O to physical hardware.
* **`constraint.xdc`**: Xilinx Design Constraints for pin mapping and timing requirements.

## Key Features

- **Hazard Handling:** Implements a localized two-cycle branch stall logic to prevent executing invalid instructions following a taken branch.
- **Data Forwarding (Bypassing):** Contains forwarding paths allowing the Execute stage to bypass the Register File and read directly from the Write-Back stage, avoiding read-after-write (RAW) data hazards.
- **Supported Instructions:** \* Arithmetic/Logical: `ADD`, `SLL`, `SLT`, `SLTU`, `XOR`, `SR`, `OR`, `AND`
  - Memory: `LW`, `LH`, `LB`, `LHU`, `LBU`, `SW`, `SH`, `SB`
  - Control Flow: `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`, `JAL`, `JALR`
  - Constants: `LUI`

## Running the Simulation

The project includes a robust testbench (`tb_pipeline.v`) that verifies execution and halts dynamically upon encountering a `ret` instruction.
