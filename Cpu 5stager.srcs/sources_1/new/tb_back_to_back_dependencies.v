`timescale 1ns/1ps

module tb_back_to_back_dependencies;

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

    $display("\n===== BACK-TO-BACK DEPENDENCIES TEST =====");

    #20;
    rst_n = 1;

    #500;

    if (uut.registers_inst.registers[3] !== 32'd30) begin
        $display("FAIL: EX-to-EX dependency failed for x3");
        $display("x3 = %d", uut.registers_inst.registers[3]);
        $finish;
    end

    if (uut.registers_inst.registers[4] !== 32'd20) begin
        $display("FAIL: back-to-back dependency failed for x4");
        $display("x4 = %d", uut.registers_inst.registers[4]);
        $finish;
    end

    if (uut.registers_inst.registers[5] !== 32'd30) begin
        $display("FAIL: newest write forwarding priority failed for x5");
        $display("x5 = %d", uut.registers_inst.registers[5]);
        $finish;
    end

    if (uut.registers_inst.registers[6] !== 32'd30) begin
        $display("FAIL: dependency across nops failed for x6");
        $display("x6 = %d", uut.registers_inst.registers[6]);
        $finish;
    end

    $display("PASS: back-to-back dependencies");
    $finish;
end

endmodule
