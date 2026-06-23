`timescale 1ns/1ps

module tb_load_to_store;

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

    $display("\n===== LOAD-TO-STORE TEST =====");

    #20;
    rst_n = 1;

    #600;

    if (uut.registers_inst.registers[9] !== 32'd45) begin
        $display("FAIL: setup load into x9 failed");
        $display("x9 = %d", uut.registers_inst.registers[9]);
        $finish;
    end

    if (uut.scratchpad_ram.ram[3][31:0] !== 32'd45) begin
        $display("FAIL: load-to-store dependency failed");
        $display("RAM[12] = %d", uut.scratchpad_ram.ram[3][31:0]);
        $finish;
    end

    $display("PASS: load-to-store dependency");
    $finish;
end

endmodule
