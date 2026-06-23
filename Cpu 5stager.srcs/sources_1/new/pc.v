module pc (
  input wire clk,
  input wire rst_n,
  input wire [31:0] pc_next,
  input wire wr_en,
  output wire [31:0] pc_out
);
 reg [31:0] pc_reg; 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_reg <= 32'h00000000;
        end else if (wr_en) begin
            pc_reg <= pc_next;
        end
    end
    assign pc_out = pc_reg;

endmodule