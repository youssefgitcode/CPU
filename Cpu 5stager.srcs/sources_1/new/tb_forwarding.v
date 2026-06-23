`timescale 1ns/1ps

module tb_forwarding;

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
    clk=0;
    rst_n=0;

    $display("===== FORWARDING TEST =====");

    #20;
    rst_n=1;

    #500;

    if(uut.registers_inst.registers[3] !== 32'd30)
    begin
        $display("FAIL EX->EX forwarding");
        $finish;
    end
    else
        $display("PASS EX->EX forwarding");

    if(uut.registers_inst.registers[4] !== 32'd20)
    begin
        $display("FAIL MEM->EX forwarding");
        $finish;
    end
    else
        $display("PASS MEM->EX forwarding");

    if(uut.registers_inst.registers[1] !== 32'd15)
    begin
        $display("FAIL x1 overwrite");
        $finish;
    end

    if(uut.registers_inst.registers[5] !== 32'd30)
    begin
        $display("FAIL Forwarding Priority");
        $finish;
    end
    else
        $display("PASS Forwarding Priority");

    if(uut.registers_inst.registers[6] !== 32'd30)
    begin
        $display("FAIL WB bypass");
        $finish;
    end
    else
        $display("PASS WB bypass");

    $display("================================");
    $display("ALL FORWARDING TESTS PASSED");
    $display("================================");

    $finish;

end

endmodule