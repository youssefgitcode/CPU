module reg_file (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [4:0]  wr_addr,
    input  wire [31:0] wr_data,
    input  wire        wr_en,
    input  wire [4:0]  rs1_addr,
    output wire [31:0] rs1_data,
    input  wire [4:0]  rs2_addr,
    output wire [31:0] rs2_data
);

    reg [31:0] registers [31:0];

    assign rs1_data = (rs1_addr == 5'b0) ? 32'b0 : 
                      ((wr_en && (wr_addr == rs1_addr)) ? wr_data : registers[rs1_addr]);
                      
    assign rs2_data = (rs2_addr == 5'b0) ? 32'b0 : 
                      ((wr_en && (wr_addr == rs2_addr)) ? wr_data : registers[rs2_addr]);

    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1) registers[i] <= 32'b0;
        end else if (wr_en && (wr_addr != 5'b0)) begin
            registers[wr_addr] <= wr_data;
        end
    end
endmodule
