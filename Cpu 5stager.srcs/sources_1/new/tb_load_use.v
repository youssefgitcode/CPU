`timescale 1ns/1ps

module tb_load_use;

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

integer stall_count;

initial begin
    clk = 0;
    rst_n = 0;
    stall_count = 0;

    $display("\n===== LOAD-USE TEST =====");

    #20;
    rst_n = 1;

    #500;

    $display("x7 = %d",uut.registers_inst.registers[7]);
    $display("x8 = %d",uut.registers_inst.registers[8]);

    if(uut.registers_inst.registers[7] !== 32'd30)
    begin
        $display("FAIL: LW failed (x7 != 30)");
        $finish;
    end

    if(uut.registers_inst.registers[8] !== 32'd45)
    begin
        $display("FAIL: Load-use hazard (x8 != 45)");
        $finish;
    end

    if(stall_count == 0)
    begin
        $display("FAIL: no load-use stall detected");
        $finish;
    end

    $display("PASS: load-use hazard");
    $display("Number of stall cycles = %0d",stall_count);

    $finish;

end

always @(posedge clk)
begin
    if(uut.hz_pc_stall)
        stall_count = stall_count + 1;
end

endmodule