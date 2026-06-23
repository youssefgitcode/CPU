`timescale 1ns / 1ps

module hazard_unit (
    input  wire [4:0] id_ex_rs1,          
    input  wire [4:0] id_ex_rs2,          
    input  wire       id_ex_mem_to_reg,   
    input  wire [4:0] id_ex_rd,           
    
    input  wire [4:0] if_id_rs1,      
    input  wire [4:0] if_id_rs2,          
    
    input  wire [4:0] ex_mem_rd,         
    input  wire       ex_mem_reg_write,   

    input  wire [4:0] mem_wb_rd,          
    input  wire       mem_wb_reg_write,  
    
    input  wire       id_jump,
    input  wire       branch_taken,
    
    output reg [1:0]  forward_a,
    output reg [1:0]  forward_b,
    
    output reg        pc_stall,      
    output reg        if_id_stall,   
    output reg        if_id_flush,   
    output reg        id_ex_flush    
);
    always @(*) begin
        forward_a = 2'b00;
        forward_b = 2'b00;
        
        if (ex_mem_reg_write && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rs1)) begin
            forward_a = 2'b10;
        end
        else if (mem_wb_reg_write && (mem_wb_rd != 5'b0) && (mem_wb_rd == id_ex_rs1)) begin
            forward_a = 2'b01;
        end
        
        if (ex_mem_reg_write && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rs2)) begin
            forward_b = 2'b10;
        end
        else if (mem_wb_reg_write && (mem_wb_rd != 5'b0) && (mem_wb_rd == id_ex_rs2)) begin
            forward_b = 2'b01;
        end
    end

    always @(*) begin
        pc_stall    = 1'b0;
        if_id_stall = 1'b0;
        if_id_flush = 1'b0;
        id_ex_flush = 1'b0;
        
        if (id_ex_mem_to_reg && (id_ex_rd != 5'b0) && ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2))) begin
            pc_stall    = 1'b1; 
            if_id_stall = 1'b1; 
            id_ex_flush = 1'b1; 
        end
        
        else if (id_jump || branch_taken) begin
            if_id_flush = 1'b1;
        end
    end

endmodule
