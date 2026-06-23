`timescale 1ns/1ps

module tb_alu;

reg [31:0] a;
reg [31:0] b;
reg [3:0] alu_ctrl;

wire [31:0] result;
wire zero;

alu uut(
    .a(a),
    .b(b),
    .alu_ctrl(alu_ctrl),
    .result(result),
    .zero(zero)
);

initial begin

    $display("===== ALU TEST =====");

    // add
    a=20; b=5; alu_ctrl=4'b0000;
    #10;
    if(result!=25) begin
        $display("ADD FAILED");
        $finish;
    end

    // sub
    a=20; b=5; alu_ctrl=4'b1000;
    #10;
    if(result!=15) begin
        $display("SUB FAILED");
        $finish;
    end

    // xor
    a=12; b=5; alu_ctrl=4'b0100;
    #10;
    if(result!=(12^5)) begin
        $display("XOR FAILED");
        $finish;
    end

    // or
    a=12; b=5; alu_ctrl=4'b0110;
    #10;
    if(result!=(12|5)) begin
        $display("OR FAILED");
        $finish;
    end

    // and
    a=12; b=5; alu_ctrl=4'b0111;
    #10;
    if(result!=(12&5)) begin
        $display("AND FAILED");
        $finish;
    end

    // sll
    a=1; b=3; alu_ctrl=4'b0001;
    #10;
    if(result!=8) begin
        $display("SLL FAILED");
        $finish;
    end

    // srl
    a=32; b=2; alu_ctrl=4'b0101;
    #10;
    if(result!=8) begin
        $display("SRL FAILED");
        $finish;
    end

    // sra
    a=-32; b=2; alu_ctrl=4'b1101;
    #10;
    if(result!=-8) begin
        $display("SRA FAILED");
        $finish;
    end

    // slt
    a=-5; b=3; alu_ctrl=4'b0010;
    #10;
    if(result!=1) begin
        $display("SLT FAILED");
        $finish;
    end

    // pass b
    a=123; b=456; alu_ctrl=4'b1111;
    #10;
    if(result!=456) begin
        $display("PASS-B FAILED");
        $finish;
    end

    // zero flag
    a=10; b=10; alu_ctrl=4'b1000;
    #10;
    if(!zero) begin
        $display("ZERO FLAG FAILED");
        $finish;
    end

    // sltu
    a = 32'hFFFFFFFF;
    b = 32'd1;
    alu_ctrl = 4'b0011;
    #10;
    if(result != 0)
    begin
        $display("SLTU FAILED");
        $finish;
    end

    $display("ALL ALU TESTS PASSED");
    $finish;
end
  
endmodule
