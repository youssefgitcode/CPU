module ID_EX_REG (
    input wire        clk,
    input wire        rst_n,
    input wire        clear, 
    input wire [31:0] pc_in,
    input wire [31:0] rd1,
    input wire [31:0] rd2,
    input wire [31:0] imm_gen,
    input wire [4:0]  dr,
    input wire [3:0]  alu_1,       
    input wire        alu_2,      
    input wire        branch,
    input wire        jump_in, 
    input wire        write_mem,
    input wire        write_reg,
    input wire        write_mem_reg,
    input wire [4:0]  rs1_in,
    input wire [4:0]  rs2_in,
    
    output reg [31:0] pc_out,
    output reg [31:0] rd1_out,
    output reg [31:0] rd2_out,
    output reg [31:0] imm_gen_out,
    output reg [4:0]  dr_out,
    output reg [3:0]  alu_1_out,
    output reg        alu_2_out,
    output reg        branch_out,
    output reg        jump_out, 
    output reg        write_mem_out,
    output reg        write_reg_out,
    output reg        write_mem_reg_out,
    output reg [4:0]  rs1_out,
    output reg [4:0]  rs2_out
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_out            <= 32'h00000000;
            rd1_out           <= 32'h00000000;
            rd2_out           <= 32'h00000000;
            imm_gen_out       <= 32'h00000000;
            dr_out            <= 5'b00000;
            alu_1_out         <= 4'b0000;
            alu_2_out         <= 1'b0;
            branch_out        <= 1'b0;
            jump_out          <= 1'b0; 
            write_mem_out     <= 1'b0;
            write_reg_out     <= 1'b0;
            write_mem_reg_out <= 1'b0;
            rs1_out           <= 5'b00000;
            rs2_out           <= 5'b00000;
        end else if (clear) begin 
            pc_out            <= 32'h00000000;
            rd1_out           <= 32'h00000000;
            rd2_out           <= 32'h00000000;
            imm_gen_out       <= 32'h00000000;
            dr_out            <= 5'b00000;
            alu_1_out         <= 4'b0000;
            alu_2_out         <= 1'b0;
            branch_out        <= 1'b0;
            jump_out          <= 1'b0;
            write_mem_out     <= 1'b0;
            write_reg_out     <= 1'b0;
            write_mem_reg_out <= 1'b0;
            rs1_out           <= 5'b00000;
            rs2_out           <= 5'b00000;
        end else begin
            pc_out            <= pc_in;
            rd1_out           <= rd1;
            rd2_out           <= rd2;
            imm_gen_out       <= imm_gen;
            dr_out            <= dr;
            alu_1_out         <= alu_1;
            alu_2_out         <= alu_2;
            branch_out        <= branch;
            jump_out          <= jump_in; 
            write_mem_out     <= write_mem;
            write_reg_out     <= write_reg;
            write_mem_reg_out <= write_mem_reg;
            rs1_out           <= rs1_in;
            rs2_out           <= rs2_in;
        end
    end
endmodule