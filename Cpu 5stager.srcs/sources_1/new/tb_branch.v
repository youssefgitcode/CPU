`timescale 1ns/1ps

module tb_branch;

reg clk;
reg rst_n;

wire [31:0] probe_pc;
wire [31:0] probe_alu_res;

riscv_core uut(
    .clk(clk),
    .rst_n(rst_n),
    .probe_pc(probe_pc),
    .probe_alu_res(probe_alu_res)
);

always #5 clk = ~clk;

initial begin

    clk = 0;
    rst_n = 0;

    $display("\n===== BRANCH TEST =====");

    #20;
    rst_n = 1;

    #500;

    if(uut.registers_inst.registers[8] !== 32'd45)
    begin
        $display("FAIL: branch flush failed");
        $display("x8 = %d",uut.registers_inst.registers[8]);
        $finish;
    end
    else
        $display("PASS: branch flush");

    if(uut.registers_inst.registers[9] !== 32'd45)
    begin
        $display("FAIL: branch target instructions didn't execute");
        $display("x9 = %d",uut.registers_inst.registers[9]);
        $finish;
    end
    else
        $display("PASS: branch target executed");

    if(probe_pc != 32'h48)
    begin
        $display("WARNING: PC not at JAL loop");
    end

    $display("==========================");
    $display("ALL BRANCH TESTS PASSED");
    $display("==========================");

    $finish;

end

endmodule
