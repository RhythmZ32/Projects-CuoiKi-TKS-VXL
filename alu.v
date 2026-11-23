module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [2:0]  alu_control,
    output reg  [31:0] result,
    output wire [3:0]  flags // {N: Negative, Z: Zero, C: Carry, V: Overflow}
);
    wire        n, z, c, v;
    wire [32:0] sum;

    // Phép cộng / trừ 33-bit để tính cờ Carry chính xác
    assign sum = (alu_control[0] == 1'b1) ? (a - b) : (a + b);

    always @(*) begin
        case (alu_control)
            3'b000: result = a + b;   // ADD
            3'b001: result = a - b;   // SUB
            3'b010: result = a & b;   // AND
            3'b011: result = a | b;   // ORR
            3'b100: result = b;       // MOV
            3'b101: result = a ^ b;   // XOR / EOR (Phép XOR)
            default: result = 32'b0;
        endcase
    end

    // Cờ trạng thái N (Âm) và Z (Bằng 0)
    assign n = result[31];
    assign z = (result == 32'b0) ? 1'b1 : 1'b0;

    // Cờ Carry (C) và Overflow (V)
    assign c = (alu_control[1:0] == 2'b00) ? sum[32] : 
               (alu_control[1:0] == 2'b01) ? ~sum[32] : 1'b0;
    assign v = (alu_control[1:0] == 2'b00) ? (~(a[31] ^ b[31]) & (a[31] ^ result[31])) :
               (alu_control[1:0] == 2'b01) ? ((a[31] ^ b[31]) & (a[31] ^ result[31])) : 1'b0;

    assign flags = {n, z, c, v};
endmodule