module rom (
    input  wire        clk,      
    input  wire [31:0] addr,   
    output wire [31:0] rdata     
);
    reg [31:0] ram [0:63];

    initial begin
        $readmemh("C:/vivado projects/Cpu 5stager/Cpu 5stager.srcs/sources_1/new/program.mem", ram);
    end
 
    assign rdata = ram[addr[7:2]]; 

endmodule
