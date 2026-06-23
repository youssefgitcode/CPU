module bus_decoder (
    input  [31:0] bus_addr,      
    input  [31:0] bus_wdata,      
    input        bus_we,         
    output reg [31:0] bus_rdata,
    
    output reg        ram_we,
    output     [31:0] ram_addr,
    output     [31:0] ram_wdata,
    input      [31:0] ram_rdata,
    
   
    output     [31:0] rom_addr,
    input      [31:0] rom_rdata,
    

    output reg        npu_we,
    output     [31:0] npu_addr,
    output     [31:0] npu_wdata,
    input      [31:0] npu_rdata
);

   assign ram_addr  = (bus_addr[31:28] == 4'h2) ? bus_addr : 32'b0;
    assign rom_addr  = (bus_addr[31:28] == 4'h0) ? bus_addr : 32'b0;
    assign npu_addr  = (bus_addr[31:28] == 4'h4) ? bus_addr : 32'b0;
    
    assign ram_wdata = bus_wdata;
    assign npu_wdata = bus_wdata;

 // decodation
    always @(*) begin
        ram_we    = 1'b0;
        npu_we    = 1'b0;
        bus_rdata = 32'b0;
        
        // rom 
        if (bus_addr[31:28] == 4'h0) begin
            ram_we    = 1'b0;            
            bus_rdata = rom_rdata;       
        end
        // ram
        else if (bus_addr[31:28] == 4'h2) begin
            ram_we    = bus_we;          
            bus_rdata = ram_rdata;       
        end
        // accelerator 
        else if (bus_addr[31:28] == 4'h4) begin
            npu_we    = bus_we;          
            bus_rdata = npu_rdata;       
        end
    end

endmodule
