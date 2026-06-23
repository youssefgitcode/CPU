`timescale 1ns/1ps

module tb_x0;

reg clk;
reg rst_n;
reg [4:0] rs1_addr;
reg [4:0] rs2_addr;
reg [4:0] wr_addr;
reg [31:0] wr_data;
reg wr_en;

wire [31:0] rs1_data;
wire [31:0] rs2_data;

reg_file uut (
    .clk(clk),
    .rst_n(rst_n),
    .rs1_addr(rs1_addr),
    .rs2_addr(rs2_addr),
    .wr_addr(wr_addr),
    .wr_data(wr_data),
    .wr_en(wr_en),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data)
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    rst_n = 0;
    rs1_addr = 5'd0;
    rs2_addr = 5'd0;
    wr_addr = 5'd0;
    wr_data = 32'd0;
    wr_en = 1'b0;

    $display("\n===== X0 TEST =====");

    #20;
    rst_n = 1;

    wr_addr = 5'd0;
    wr_data = 32'hdead_beef;
    wr_en = 1'b1;
    #10;
    wr_en = 1'b0;

    #1;
    if (rs1_data !== 32'd0 || rs2_data !== 32'd0) begin
        $display("FAIL: x0 read returned nonzero");
        $display("rs1_data = %h", rs1_data);
        $display("rs2_data = %h", rs2_data);
        $finish;
    end

    if (uut.registers[0] !== 32'd0) begin
        $display("FAIL: x0 storage changed");
        $display("x0 = %h", uut.registers[0]);
        $finish;
    end

    $display("PASS: x0 stays hardwired to zero");
    $finish;
end

endmodule
