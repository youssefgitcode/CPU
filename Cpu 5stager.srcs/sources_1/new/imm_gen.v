module imm_gen (
    input  wire [31:0] instr,
    output reg  [31:0] imm_ext
);
    wire [6:0] opcode = instr[6:0];

    always @(*) begin
        case (opcode)
            7'h13, 7'h03, 7'h67: 
                imm_ext = {{20{instr[31]}}, instr[31:20]};
                
            7'h23: 
                imm_ext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
                
            7'h63: 
                imm_ext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
                
            7'h37, 7'h17: 
                imm_ext = {instr[31:12], 12'b0};
                
            7'h6f: 
                imm_ext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
                
            default: 
                imm_ext = 32'b0;
        endcase
    end
endmodule