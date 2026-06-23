module mem_arbiter (
    // fetch
    input  [31:0] imem_addr,        
    input         imem_req,         
    output reg [31:0] imem_rdata, 
    
    // write/read
    input  [31:0] dmem_addr,        
    input  [31:0] dmem_wdata,       
    input         dmem_req,         
    input         dmem_we,          
    output reg [31:0] dmem_rdata,   
    
    output reg [31:0] bus_addr,     
    output reg [31:0] bus_wdata,    
    output reg        bus_we,       
    input      [31:0] bus_rdata,    
    
    // hazard control
    output reg        structural_stall
);

    always @(*) begin
        bus_addr         = imem_addr;
        bus_wdata        = 32'b0;
        bus_we           = 1'b0;
        imem_rdata       = bus_rdata;
        dmem_rdata       = 32'b0;
        structural_stall = 1'b0;

        if (dmem_req) begin
            bus_addr   = dmem_addr;
            bus_wdata  = dmem_wdata;
            bus_we     = dmem_we;
            dmem_rdata = bus_rdata;
            
            if (imem_req) begin
                structural_stall = 1'b1;  
                imem_rdata       = 32'b0; 
            end
        end
    end

endmodule