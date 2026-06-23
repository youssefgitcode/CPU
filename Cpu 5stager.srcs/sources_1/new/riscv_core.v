module riscv_core (
    input  wire        clk,
    input  wire        rst_n,
    output wire [31:0] probe_pc,
    output wire [31:0] probe_alu_res
);

    // fetching stage
    wire [31:0] if_pc_current;
    wire [31:0] if_pc_next;
    wire [31:0] if_pc_plus_4;
    wire [31:0] if_instr;

    // pc counter + branch logic
    wire        ex_pc_src;
    wire [31:0] ex_pc_branch;

    // hazard and stall controls
    wire        hz_pc_stall;
    wire        hz_if_id_stall;
    wire        hz_if_id_flush;
    wire        hz_id_ex_flush;
    wire        arb_structural_stall;

    // stalls and clears
    wire        pc_freeze      = hz_pc_stall | arb_structural_stall;
    wire        if_id_freeze   = hz_if_id_stall | arb_structural_stall;
    wire        if_id_clear    = hz_if_id_flush;
    wire        id_ex_clear    = hz_id_ex_flush | ex_pc_src; 

    assign if_pc_plus_4 = if_pc_current + 4;
    assign if_pc_next   = (ex_pc_src) ? ex_pc_branch : if_pc_plus_4;

    pc pc_inst (
        .clk(clk),
        .rst_n(rst_n),
        .pc_next(if_pc_next),
        .pc_out(if_pc_current),
        .wr_en(!pc_freeze)
    );

    wire [31:0] arb_imem_rdata;
    assign if_instr = arb_imem_rdata;

    // if/id pipeline register
    wire [31:0] id_pc;
    wire [31:0] id_instr;

    IF_ID_REG pipe_if_id (
        .clk(clk),
        .rst_n(rst_n),
        .clear(if_id_clear),
        .pc_in(if_pc_current),
        .instruction_in(if_instr),
        .pc_out(id_pc),
        .instruction_out(id_instr),
        .wr_en(!if_id_freeze)
    );

    // decoding instructions
    wire [4:0]  id_rs1_addr = id_instr[19:15];
    wire [4:0]  id_rs2_addr = id_instr[24:20];
    wire [4:0]  id_rd_addr  = id_instr[11:7];
    wire [31:0] id_imm_ext;

    // control wires
    wire [3:0] id_alu_ctrl_wire;
    wire       id_wr_en_wire;
    wire       id_alu_src_wire;
    wire       id_mem_write_wire;   
    wire       id_mem_to_reg_wire;
    wire       id_branch_wire;      
    wire       id_jump_wire;

    // register outputs
    wire [31:0] id_src1;
    wire [31:0] id_src2;

    imm_gen imm_unit (
        .instr(id_instr),
        .imm_ext(id_imm_ext)
    );

    control_unit decoder_inst (
        .opcode(id_instr[6:0]),
        .funct3(id_instr[14:12]),
        .funct7b5(id_instr[30]),
        .reg_write(id_wr_en_wire),
        .alu_src(id_alu_src_wire),
        .mem_write(id_mem_write_wire),
        .mem_to_reg(id_mem_to_reg_wire),
        .branch(id_branch_wire),
        .jump(id_jump_wire), 
        .alu_ctrl(id_alu_ctrl_wire)
    );

    // inputs for writeback
    wire [4:0]  wb_dr;
    wire [31:0] wb_data;
    wire        wb_write_reg;

    reg_file registers_inst (
        .clk(clk),
        .rst_n(rst_n),
        .rs1_addr(id_rs1_addr),
        .rs2_addr(id_rs2_addr),
        .wr_addr(wb_dr),            
        .wr_data(wb_data),          
        .wr_en(wb_write_reg),       
        .rs1_data(id_src1),
        .rs2_data(id_src2)
    );

    // id/ex pipeline register
    wire [31:0] ex_pc;
    wire [31:0] ex_rd1;
    wire [31:0] ex_rd2;
    wire [31:0] ex_imm_gen;
    wire [4:0]  ex_dr;
    wire [3:0]  ex_alu_1;
    wire        ex_alu_2;
    wire        ex_branch;
    wire        ex_jump;
    wire        ex_write_mem;
    wire        ex_write_reg;
    wire        ex_write_mem_reg;
    
    // forwarding source registers
    wire [4:0]  ex_rs1;
    wire [4:0]  ex_rs2;

    ID_EX_REG pipe_id_ex (
        .clk(clk),
        .rst_n(rst_n),
        .clear(id_ex_clear), 
        .pc_in(id_pc),
        .rd1(id_src1),
        .rd2(id_src2),
        .imm_gen(id_imm_ext),
        .dr(id_rd_addr),
        .alu_1(id_alu_ctrl_wire),
        .alu_2(id_alu_src_wire),
        .branch(id_branch_wire),
        .jump_in(id_jump_wire), 
        .write_mem(id_mem_write_wire),
        .write_reg(id_wr_en_wire),
        .write_mem_reg(id_mem_to_reg_wire),
        .rs1_in(id_rs1_addr),         
        .rs2_in(id_rs2_addr),
        .pc_out(ex_pc),
        .rd1_out(ex_rd1),
        .rd2_out(ex_rd2),
        .imm_gen_out(ex_imm_gen),
        .dr_out(ex_dr),
        .alu_1_out(ex_alu_1),
        .alu_2_out(ex_alu_2),
        .branch_out(ex_branch),
        .jump_out(ex_jump), 
        .write_mem_out(ex_write_mem),
        .write_reg_out(ex_write_reg),
        .write_mem_reg_out(ex_write_mem_reg),
        .rs1_out(ex_rs1),             
        .rs2_out(ex_rs2)
    );

    // executing instructions 
    wire [31:0] ex_alu_in_b;
    wire [31:0] ex_alu_res;
    wire        ex_z_flag;

    // forwarding wires 
    wire [1:0]  forward_a;
    wire [1:0]  forward_b;
    reg  [31:0] forwarded_rd1_mux_out;
    reg  [31:0] forwarded_rd2_mux_out;

    wire [31:0] mem_alu_res;
    wire [4:0]  mem_dr;
    wire        mem_write_reg;
    wire        mem_write_mem_reg;

    always @(*) begin
        case (forward_a)
            2'b10:   forwarded_rd1_mux_out = mem_alu_res;
            2'b01:   forwarded_rd1_mux_out = wb_data;     
            default: forwarded_rd1_mux_out = ex_rd1;
        endcase
    end

    always @(*) begin
        case (forward_b)
            2'b10:   forwarded_rd2_mux_out = mem_alu_res;
            2'b01:   forwarded_rd2_mux_out = wb_data;     
            default: forwarded_rd2_mux_out = ex_rd2;
        endcase
    end

    // branch target 
    assign ex_pc_branch = ex_pc + ex_imm_gen;
    assign ex_pc_src    = (ex_branch & ex_z_flag) | ex_jump;

    // alu mux selector here
    assign ex_alu_in_b = (ex_alu_2) ? ex_imm_gen : forwarded_rd2_mux_out;

    alu alu_inst (
        .a(forwarded_rd1_mux_out),    
        .b(ex_alu_in_b),
        .alu_ctrl(ex_alu_1),
        .result(ex_alu_res),
        .zero(ex_z_flag)
    );

    // ex/mem pipeline register
    wire [31:0] mem_rd2;
    wire        mem_write_mem;

    EX_MEM_REG pipe_ex_mem (
        .clk(clk),
        .rst_n(rst_n),
        .alu_res_in(ex_alu_res),
        .rd2_in(forwarded_rd2_mux_out), 
        .dr_in(ex_dr),
        .write_mem_in(ex_write_mem),
        .write_reg_in(ex_write_reg),
        .write_mem_reg_in(ex_write_mem_reg),
        .alu_res_out(mem_alu_res),
        .rd2_out(mem_rd2),
        .dr_out(mem_dr),
        .write_mem_out(mem_write_mem),
        .write_reg_out(mem_write_reg),
        .write_mem_reg_out(mem_write_mem_reg)
    );

    wire [31:0] mem_dmem_read_data;  

    wire [31:0] bus_addr;
    wire [31:0] bus_wdata;
    wire        bus_we;
    wire [31:0] bus_rdata;

    wire        ram_we;
    wire [31:0] ram_addr;
    wire [31:0] ram_wdata;
    wire [31:0] ram_rdata;

    wire [31:0] rom_addr;
    wire [31:0] rom_rdata;

    wire        dmem_req_active = mem_write_mem | mem_write_mem_reg;

    // memory arbiter
    mem_arbiter system_arbiter (
        .imem_addr(if_pc_current),
        .imem_req(1'b1),               
        .imem_rdata(arb_imem_rdata),
        .dmem_addr(mem_alu_res),
        .dmem_wdata(mem_rd2),
        .dmem_req(dmem_req_active),
        .dmem_we(mem_write_mem),
        .dmem_rdata(mem_dmem_read_data),
        .bus_addr(bus_addr),
        .bus_wdata(bus_wdata),
        .bus_we(bus_we),
        .bus_rdata(bus_rdata),
        .structural_stall(arb_structural_stall)
    );

    // bus decoder 
    bus_decoder system_decoder (
        .bus_addr(bus_addr),
        .bus_wdata(bus_wdata),
        .bus_we(bus_we),
        .bus_rdata(bus_rdata),
        .ram_we(ram_we),
        .ram_addr(ram_addr),
        .ram_wdata(ram_wdata),
        .ram_rdata(ram_rdata),
        .rom_addr(rom_addr),
        .rom_rdata(rom_rdata),
        .npu_we(),                    
        .npu_addr(),
        .npu_wdata(),
        .npu_rdata(32'b0)
    );

    ecc_ram scratchpad_ram (
        .clk(clk),
        .we(ram_we),
        .addr(ram_addr),
        .wdata(ram_wdata),
        .rdata(ram_rdata)
    );

    rom boot_rom (
        .clk(clk),                    
        .addr(rom_addr),
        .rdata(rom_rdata)
    );

    // mem/wb pipeline register 
    wire [31:0] wb_mem_data;
    wire [31:0] wb_alu_res;
    wire        wb_write_mem_reg;

    MEM_WB_REG pipe_mem_wb (
        .clk(clk),
        .rst_n(rst_n),
        .mem_data_in(mem_dmem_read_data),
        .alu_res_in(mem_alu_res),
        .dr_in(mem_dr),
        .write_reg_in(mem_write_reg),
        .write_mem_reg_in(mem_write_mem_reg),
        .mem_data_out(wb_mem_data),
        .alu_res_out(wb_alu_res),
        .dr_out(wb_dr),
        .write_reg_out(wb_write_reg),
        .write_mem_reg_out(wb_write_mem_reg)
    );

    // hazard unit 
    hazard_unit processor_hazard_co_pilot (
        .id_ex_rs1(ex_rs1),
        .id_ex_rs2(ex_rs2),
        .id_ex_mem_to_reg(ex_write_mem_reg),
        .id_ex_rd(ex_dr),
        .if_id_rs1(id_rs1_addr),
        .if_id_rs2(id_rs2_addr),
        .ex_mem_rd(mem_dr),
        .ex_mem_reg_write(mem_write_reg),
        .mem_wb_rd(wb_dr),
        .mem_wb_reg_write(wb_write_reg),
        .id_jump(id_jump_wire),               
        .branch_taken(ex_branch & ex_z_flag), 
        .if_id_flush(hz_if_id_flush),         
        .forward_a(forward_a),
        .forward_b(forward_b),
        .pc_stall(hz_pc_stall),
        .if_id_stall(hz_if_id_stall),
        .id_ex_flush(hz_id_ex_flush)
    );

    // writeback mux
    assign wb_data = (wb_write_mem_reg) ? wb_mem_data : wb_alu_res;

    reg [31:0] probe_pc_reg;
    reg [31:0] probe_alu_res_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            probe_pc_reg      <= 32'b0;
            probe_alu_res_reg <= 32'b0;
        end else begin
            probe_pc_reg      <= if_pc_current;
            probe_alu_res_reg <= ex_alu_res;
        end
    end

    assign probe_pc      = probe_pc_reg;
    assign probe_alu_res = probe_alu_res_reg;

endmodule
