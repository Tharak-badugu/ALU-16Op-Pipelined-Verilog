# ALU-16Op-Pipelined-verilog

A synthesizable, pipelined Arithmetic Logic Unit (ALU) core written in Verilog, supporting 16 arithmetic, logic, shift, and rotate operations with full flag generation (zero, carry, overflow, negative). Designed to be parameterizable in bit-width and verified with a self-checking testbench.

## Overview

This project implements an 8-bit (parameterizable) ALU core split into two modules:

- **`alu_engine`** — the combinational core that decodes a 4-bit opcode and computes the result along with status flags.
- **`alu_top`** — a synchronous wrapper that registers the inputs and outputs of the ALU core, turning it into a 2-stage pipelined block suitable for integration into a larger datapath (e.g. a simple CPU).

The design is verified using a dedicated testbench (`ALU_tb.v`) that exercises all 16 operations, including edge cases like signed overflow, carry generation, and rotate/shift boundary conditions, plus an asynchronous mid-operation reset check.

## Architecture

```
                ┌─────────────────────────┐
   io_a ───────►│                         │
   io_b ───────►│   alu_top (pipelined)   │
io_opcode ──────►│                         │──────► o_result
   clk ─────────►│  ┌───────────────────┐  │──────► o_zero
  rst_n ─────────►│  │    alu_engine     │  │──────► o_carry
                │  │  (combinational)  │  │──────► o_overflow
                │  └───────────────────┘  │──────► o_negative
                └─────────────────────────┘
```

- Inputs are latched on the rising edge of `clk` (input pipeline stage)
- The combinational `alu_engine` computes the result the same cycle
- Outputs are latched again before leaving `alu_top` (output pipeline stage)
- `rst_n` is an active-low, asynchronous reset that clears all pipeline registers

## Supported Operations

| Opcode | Mnemonic | Operation                        |
|:------:|:--------:|-----------------------------------|
| 0000   | ADD      | `result = a + b`                 |
| 0001   | SUB      | `result = a - b`                 |
| 0010   | AND      | `result = a & b`                 |
| 0011   | OR       | `result = a \| b`                 |
| 0100   | XOR      | `result = a ^ b`                 |
| 0101   | NOR      | `result = ~(a \| b)`              |
| 0110   | NAND     | `result = ~(a & b)`               |
| 0111   | XNOR     | `result = ~(a ^ b)`               |
| 1000   | NOTA     | `result = ~a`                     |
| 1001   | SLL      | Logical shift left by `b`         |
| 1010   | SRL      | Logical shift right by `b`        |
| 1011   | SRA      | Arithmetic shift right by `b`     |
| 1100   | ROL      | Rotate left by `b`                |
| 1101   | ROR      | Rotate right by `b`               |
| 1110   | INCA     | `result = a + 1`                  |
| 1111   | DECA     | `result = a - 1`                  |

Shift/rotate amounts use the lower `log2(WIDTH)` bits of `b`.

## Flags

| Flag         | Description                                              |
|--------------|-----------------------------------------------------------|
| `zero`       | Set when `result == 0`                                    |
| `carry`      | Set on unsigned carry-out for ADD/SUB/INCA/DECA            |
| `overflow`   | Set on signed two's-complement overflow for ADD/SUB/INCA/DECA |
| `negative`   | Set to the MSB of `result` (sign bit)                      |

## Repository Structure

```
├── ALU_engine.v   # Combinational ALU core (16 ops + flags)
├── ALU_top.v      # Pipelined top-level wrapper (input/output registers)
├── ALU_tb.v       # Self-checking testbench (26 directed test cases)
├── ALU_wave.png   # Simulation waveform screenshot
└── README.md
```

## Simulation

The design targets any standard Verilog simulator (Vivado XSIM, ModelSim/QuestaSim, or open-source Icarus Verilog).

**Using Icarus Verilog:**
```bash
iverilog -o alu_sim ALU_engine.v ALU_top.v ALU_tb.v
vvp alu_sim
```

**Using Vivado:** add all three `.v` files to a simulation project, set `alu_tb` as the top module, and run behavioral simulation.

### Test Coverage

The testbench (`ALU_tb.v`) drives 26 directed scenarios, including:
- Basic arithmetic (add, subtract) with normal and rollover values
- Signed overflow detection on ADD, SUB, INCA, and DECA
- All bitwise logic operations (AND, OR, XOR, NOR, NAND, XNOR, NOT)
- Shift/rotate correctness at boundary shift amounts (0 and width−1)
- Arithmetic right-shift sign extension for negative and positive operands
- An asynchronous reset asserted mid-operation, verifying immediate pipeline clear

A sample waveform capture is included as `ALU_wave.png`.

## Possible Extensions

- Parameterize opcode width and add multiply/divide operations
- Add a formal (SVA) assertion suite for flag correctness
- Wrap in an AXI-Stream or simple register-mapped interface for SoC integration
- Add FPGA synthesis constraints and resource/timing utilization report

## Author

Badugu Tharaka Ramudu — B.Tech ECE, VLSI/RTL Design
