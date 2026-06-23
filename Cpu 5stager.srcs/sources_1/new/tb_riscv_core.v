`timescale 1ns / 1ps

module riscv_core_tb;

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
        
        #30;
        rst_n = 1;
        
        $display("\n===== LEGACY CORE TEST =====");

        while (probe_pc !== 32'h00000048) begin
            #20;
            if ($time > 2000) begin
                $display("FAIL: core test timeout");
                $finish;
            end
        end

        #60;

        $display("\n===== CORE SMOKE TEST =====");
        
        if (uut.registers_inst.registers[3] === 32'd30) 
            $display("PASS: EX-to-EX forwarding");
        else 
            $display("FAIL: EX-to-EX forwarding, x3 = %d", uut.registers_inst.registers[3]);

        if (uut.registers_inst.registers[4] === 32'd20) 
            $display("PASS: MEM-to-EX forwarding");
        else 
            $display("FAIL: MEM-to-EX forwarding, x4 = %d", uut.registers_inst.registers[4]);

        if (uut.registers_inst.registers[5] === 32'd30) 
            $display("PASS: forwarding priority");
        else 
            $display("FAIL: forwarding priority, x5 = %d", uut.registers_inst.registers[5]);

        if (uut.registers_inst.registers[6] === 32'd30) 
            $display("PASS: register file bypass");
        else 
            $display("FAIL: register file bypass, x6 = %d", uut.registers_inst.registers[6]);

        if (uut.registers_inst.registers[8] === 32'd45) 
            $display("PASS: load-use hazard");
        else 
            $display("FAIL: load-use hazard, x8 = %d", uut.registers_inst.registers[8]);

        if (uut.registers_inst.registers[8] !== 32'd99) 
            $display("PASS: branch flush");
        else 
            $display("FAIL: branch flush leaked speculative instruction");

        $display("===========================\n");
        $finish;
    end

endmodule
