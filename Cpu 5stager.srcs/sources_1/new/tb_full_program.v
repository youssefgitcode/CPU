`timescale 1ns/1ps

module tb_full_program;

reg clk;
reg rst_n;

wire [31:0] probe_pc;
wire [31:0] probe_alu_res;

riscv_core uut (
    .clk(clk),
    .rst_n(rst_n),
    .probe_pc(probe_pc),
    .probe_alu_res(probe_alu_res)
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    rst_n = 0;

    $display("\n===== FULL PROGRAM TEST =====");

    #20;
    rst_n = 1;

    #800;

    if (uut.registers_inst.registers[0] !== 32'd0) begin
        $display("FAIL: x0 changed");
        $display("x0 = %d", uut.registers_inst.registers[0]);
        $finish;
    end

    if (uut.registers_inst.registers[3] !== 32'd30) begin
        $display("FAIL: x3 expected 30");
        $display("x3 = %d", uut.registers_inst.registers[3]);
        $finish;
    end

    if (uut.registers_inst.registers[4] !== 32'd20) begin
        $display("FAIL: x4 expected 20");
        $display("x4 = %d", uut.registers_inst.registers[4]);
        $finish;
    end

    if (uut.registers_inst.registers[5] !== 32'd30) begin
        $display("FAIL: x5 expected 30");
        $display("x5 = %d", uut.registers_inst.registers[5]);
        $finish;
    end

    if (uut.registers_inst.registers[6] !== 32'd30) begin
        $display("FAIL: x6 expected 30");
        $display("x6 = %d", uut.registers_inst.registers[6]);
        $finish;
    end

    if (uut.registers_inst.registers[7] !== 32'd30) begin
        $display("FAIL: x7 expected 30");
        $display("x7 = %d", uut.registers_inst.registers[7]);
        $finish;
    end

    if (uut.registers_inst.registers[8] !== 32'd45) begin
        $display("FAIL: x8 expected 45");
        $display("x8 = %d", uut.registers_inst.registers[8]);
        $finish;
    end

    if (uut.registers_inst.registers[9] !== 32'd45) begin
        $display("FAIL: x9 expected 45");
        $display("x9 = %d", uut.registers_inst.registers[9]);
        $finish;
    end

    if (uut.scratchpad_ram.ram[0][31:0] !== 32'd30) begin
        $display("FAIL: RAM[0] expected 30");
        $display("RAM[0] = %d", uut.scratchpad_ram.ram[0][31:0]);
        $finish;
    end

    if (uut.scratchpad_ram.ram[2][31:0] !== 32'd45) begin
        $display("FAIL: RAM[8] expected 45");
        $display("RAM[8] = %d", uut.scratchpad_ram.ram[2][31:0]);
        $finish;
    end

    if (uut.scratchpad_ram.ram[3][31:0] !== 32'd45) begin
        $display("FAIL: RAM[12] expected 45");
        $display("RAM[12] = %d", uut.scratchpad_ram.ram[3][31:0]);
        $finish;
    end

    $display("PASS: full program");
    $finish;
end

endmodule
