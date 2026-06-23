module IF_ID_REG(
    input wire clk,
    input wire rst_n,
    input wire clear,
    input wire [31:0] pc_in,
    input wire [31:0] instruction_in,
    input wire wr_en,
    output reg [31:0] instruction_out,
    output reg [31:0] pc_out
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_out <= 32'h00000000;
            instruction_out <= 32'h00000000;
        end else if (clear) begin
            pc_out <= 32'h00000000;
            instruction_out <= 32'h00000000;
        end else if (wr_en) begin
            instruction_out <= instruction_in;
            pc_out <= pc_in;
        end
    end 
endmodule
