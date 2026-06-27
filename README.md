# 5-stage RISC-V CPU

Verilog implementation of a simple 5-stage pipelined RISC-V CPU built in Vivado.

## Project

- top module: `riscv_core`
- device: `xc7a12ticsg325-1L`
- constraint target: `15.940 ns` clock period
- source folder: `Cpu 5stager.srcs/sources_1/new`
- constraints: `Cpu 5stager.srcs/constrs_1/new/constraints.xdc`

## Features

- 5 pipeline stages: fetch, decode, execute, memory, writeback
- forwarding for EX/MEM and MEM/WB hazards
- load-use stall handling
- branch and jump flush handling
- hardwired `x0`
- instruction memory, scratchpad RAM, bus decoder, and memory arbiter

## Testbenches

- `tb_reset.v`
- `tb_alu.v`
- `tb_forwarding.v`
- `tb_load_use.v`
- `tb_branch.v`
- `tb_load_to_store.v`
- `tb_back_to_back_dependencies.v`
- `tb_x0.v`
- `tb_full_program.v`
- `tb_riscv_core.v` legacy smoke test

## Architecture Notes

- [Fetch stage](docs/architecture/01_fetch_stage.pdf)
- [Decode stage](docs/architecture/02_decode_stage.pdf)

## Notes

The committed repo should keep source, constraints, memory initialization, and the Vivado project file. Generated Vivado folders such as `.runs`, `.sim`, `.cache`, and `xsim.dir` are ignored.
