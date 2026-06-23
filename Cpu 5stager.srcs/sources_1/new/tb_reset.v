`timescale 1ns/1ps

module tb_reset;

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

always #10 clk = ~clk;

initial begin
    clk = 0;
    rst_n = 0;

    $display("\n===== RESET TEST =====");

    #40;
    rst_n = 1;

    #100;

    // x0 should always be zero
    if (uut.registers_inst.registers[0] !== 32'd0)
    begin
        $display("[FAIL] x0 changed!");
        $finish;
    end

    if (probe_pc === 32'hxxxxxxxx)
    begin
        $display("[FAIL] PC unknown.");
        $finish;
    end

    $display("[PASS] Reset test passed.");
    $finish;
end

endmodule