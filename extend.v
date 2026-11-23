module extend (
    input  wire [23:0] instr_imm,
    input  wire [1:0]  imm_src,
    output reg  [31:0] ext_imm
);
    always @(*) begin
        case (imm_src)
            2'b00: ext_imm = {24'b0, instr_imm[7:0]};                   // Data processing (8-bit unsigned)
            2'b01: ext_imm = {20'b0, instr_imm[11:0]};                  // LDR / STR offset (12-bit unsigned)
            2'b10: ext_imm = {{6{instr_imm[23]}}, instr_imm[23:0], 2'b00}; // Branch offset (24-bit sign-extended + shift left 2)
            default: ext_imm = 32'b0;
        endcase
    end
endmodule