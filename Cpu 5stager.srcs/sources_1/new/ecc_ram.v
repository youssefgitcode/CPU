module ecc_ram (
    input              clk,
    input              we,       
    input       [31:0] addr,     
    input       [31:0] wdata,    
    output reg  [31:0] rdata     
);

    reg [38:0] ram [0:1023];

    wire [9:0] row_index = addr[11:2];

    wire [6:0]  p_bits;
    wire [38:0] full_wdata;
    
    reg [38:0] raw_rdata; 
    wire [6:0]  syndrome;

    assign p_bits[0] = wdata[0]^wdata[1]^wdata[3]^wdata[4]^wdata[6]^wdata[8]^wdata[10]^wdata[11]^wdata[13]^wdata[15]^wdata[17]^wdata[19]^wdata[21]^wdata[23]^wdata[25]^wdata[26]^wdata[28]^wdata[30];
    assign p_bits[1] = wdata[0]^wdata[2]^wdata[3]^wdata[5]^wdata[6]^wdata[9]^wdata[10]^wdata[12]^wdata[13]^wdata[16]^wdata[17]^wdata[20]^wdata[21]^wdata[24]^wdata[25]^wdata[27]^wdata[28]^wdata[31];
    assign p_bits[2] = wdata[1]^wdata[2]^wdata[3]^wdata[7]^wdata[8]^wdata[9]^wdata[10]^wdata[14]^wdata[15]^wdata[16]^wdata[17]^wdata[22]^wdata[23]^wdata[24]^wdata[25]^wdata[29]^wdata[30]^wdata[31];
    assign p_bits[3] = wdata[4]^wdata[5]^wdata[6]^wdata[7]^wdata[8]^wdata[9]^wdata[10]^wdata[18]^wdata[19]^wdata[20]^wdata[21]^wdata[22]^wdata[23]^wdata[24]^wdata[25];
    assign p_bits[4] = wdata[11]^wdata[12]^wdata[13]^wdata[14]^wdata[15]^wdata[16]^wdata[17]^wdata[18]^wdata[19]^wdata[20]^wdata[21]^wdata[22]^wdata[23]^wdata[24]^wdata[25];
    assign p_bits[5] = wdata[26]^wdata[27]^wdata[28]^wdata[29]^wdata[30]^wdata[31];
    assign p_bits[6] = ^wdata; 

    assign full_wdata = {p_bits, wdata};

    always @(posedge clk) begin
        if (we) begin
            ram[row_index] <= full_wdata;
        end
    end

    always @(*) begin
        raw_rdata = ram[row_index];
    end

    assign syndrome[0] = raw_rdata[32] ^ (raw_rdata[0]^raw_rdata[1]^raw_rdata[3]^raw_rdata[4]^raw_rdata[6]^raw_rdata[8]^raw_rdata[10]^raw_rdata[11]^raw_rdata[13]^raw_rdata[15]^raw_rdata[17]^raw_rdata[19]^raw_rdata[21]^raw_rdata[23]^raw_rdata[25]^raw_rdata[26]^raw_rdata[28]^raw_rdata[30]);
    assign syndrome[1] = raw_rdata[33] ^ (raw_rdata[0]^raw_rdata[2]^raw_rdata[3]^raw_rdata[5]^raw_rdata[6]^raw_rdata[9]^raw_rdata[10]^raw_rdata[12]^raw_rdata[13]^raw_rdata[16]^raw_rdata[17]^raw_rdata[20]^raw_rdata[21]^raw_rdata[24]^raw_rdata[25]^raw_rdata[27]^raw_rdata[28]^raw_rdata[31]);
    assign syndrome[2] = raw_rdata[34] ^ (raw_rdata[1]^raw_rdata[2]^raw_rdata[3]^raw_rdata[7]^raw_rdata[8]^raw_rdata[9]^raw_rdata[10]^raw_rdata[14]^raw_rdata[15]^raw_rdata[16]^raw_rdata[17]^raw_rdata[22]^raw_rdata[23]^raw_rdata[24]^raw_rdata[25]^raw_rdata[29]^raw_rdata[30]^raw_rdata[31]);
    assign syndrome[3] = raw_rdata[35] ^ (raw_rdata[4]^raw_rdata[5]^raw_rdata[6]^raw_rdata[7]^raw_rdata[8]^raw_rdata[9]^raw_rdata[10]^raw_rdata[18]^raw_rdata[19]^raw_rdata[20]^raw_rdata[21]^raw_rdata[22]^raw_rdata[23]^raw_rdata[24]^raw_rdata[25]);
    assign syndrome[4] = raw_rdata[36] ^ (raw_rdata[11]^raw_rdata[12]^raw_rdata[13]^raw_rdata[14]^raw_rdata[15]^raw_rdata[16]^raw_rdata[17]^raw_rdata[18]^raw_rdata[19]^raw_rdata[20]^raw_rdata[21]^raw_rdata[22]^raw_rdata[23]^raw_rdata[24]^raw_rdata[25]);
    assign syndrome[5] = raw_rdata[37] ^ (raw_rdata[26]^raw_rdata[27]^raw_rdata[28]^raw_rdata[29]^raw_rdata[30]^raw_rdata[31]);
    assign syndrome[6] = raw_rdata[38] ^ (^raw_rdata[31:0]);

    always @(*) begin
        rdata = raw_rdata[31:0];
        if (syndrome != 7'b0) begin
            if (syndrome >= 1 && syndrome <= 32) begin
                rdata[syndrome - 1] = ~rdata[syndrome - 1]; 
            end
        end
    end

endmodule
