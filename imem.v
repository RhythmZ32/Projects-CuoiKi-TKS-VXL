module imem (
    input  wire [31:0] addr,
    output wire [31:0] instr
);
    reg [31:0] RAM [63:0]; // Bộ nhớ 64 từ 32-bit

    // Đọc lệnh (Word-aligned: bỏ 2 bit cuối)
    assign instr = RAM[addr[31:2]];
endmodule