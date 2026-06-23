module EX_MEM_REG (
    input wire clk,
    input wire rst_n,
    input wire [31:0] alu_res_in,
    input wire [31:0] rd2_in,         
    input wire [4:0]  dr_in,
    input wire        write_mem_in,
    input wire        write_reg_in,
    input wire        write_mem_reg_in,
    output reg [31:0] alu_res_out,
    output reg [31:0] rd2_out,
    output reg [4:0]  dr_out,
    output reg        write_mem_out,
    output reg        write_reg_out,
    output reg        write_mem_reg_out
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            alu_res_out       <= 32'h00000000;
            rd2_out           <= 32'h00000000;
            dr_out            <= 5'b00000;
            write_mem_out     <= 1'b0;
            write_reg_out     <= 1'b0;
            write_mem_reg_out <= 1'b0;
        end
        else begin
            alu_res_out       <= alu_res_in;
            rd2_out           <= rd2_in;
            dr_out            <= dr_in;
            write_mem_out     <= write_mem_in;
            write_reg_out     <= write_reg_in;
            write_mem_reg_out <= write_mem_reg_in;
        end
    end

endmodule