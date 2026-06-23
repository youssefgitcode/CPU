module control_unit (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire       funct7b5,
    output reg        reg_write,
    output reg        alu_src,
    output reg        mem_write,   
    output reg        mem_to_reg, 
    output reg        branch,      
    output reg        jump,
    output reg  [3:0] alu_ctrl
);

    
    always @(*) begin
        reg_write  = 0; alu_src = 0; mem_write = 0; 
        mem_to_reg = 0; branch  = 0; jump = 0;
        // states
        case (opcode)
            7'h33: begin reg_write = 1; alu_src = 0; end // r-type
            7'h13: begin reg_write = 1; alu_src = 1; end // i-type math
            7'h03: begin reg_write = 1; alu_src = 1; mem_to_reg = 1; end // lw
            7'h23: begin reg_write = 0; alu_src = 1; mem_write = 1;  end // sw
            7'h63: begin reg_write = 0; alu_src = 0; branch = 1;     end // branch
            7'h37: begin reg_write = 1; alu_src = 1; end // lui
            7'h6f: begin reg_write = 1; jump = 1;    end
            default: ; 
        endcase
    end

    // alu ctrl code decoder
    always @(*) begin
        case (opcode)
            7'h33: alu_ctrl = {funct7b5, funct3}; 
            7'h13: begin                                 
                if (funct3 == 3'b101)            
                    alu_ctrl = {funct7b5, funct3};
                else if (funct3 == 3'b000)       
                    alu_ctrl = 4'b0000;            
                else                                             
                    alu_ctrl = {1'b0, funct3};     
            end
            7'h03, 7'h23: alu_ctrl = 4'b0000;    
            7'h63:        alu_ctrl = 4'b1000;    
            7'h37:        alu_ctrl = 4'b1111;    
            default:      alu_ctrl = 4'b0000;
        endcase
    end
endmodule
