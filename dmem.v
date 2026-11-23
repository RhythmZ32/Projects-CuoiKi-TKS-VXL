module dmem (
    input  wire        clk,
    input  wire        we,
    input  wire [31:0] addr,
    input  wire [31:0] wd,
    output wire [31:0] rd
);
    reg [31:0] RAM [63:0];

    assign rd = RAM[addr[31:2]]; // Đọc bất đồng bộ

    always @(posedge clk) begin
        if (we)
            RAM[addr[31:2]] <= wd; // Ghi đồng bộ
    end
endmodule