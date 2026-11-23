module arm_single_cycle (
    input  wire        clk,
    input  wire        reset,
    output wire [31:0] pc,
    output wire [31:0] instr,
    output wire [31:0] alu_out,
    output wire [31:0] write_data,
    output wire [31:0] read_data,
    output wire        mem_write
);
    wire [31:0] pc_next, pc_plus4, pc_plus8, pc_branch;
    wire [31:0] rd1, rd2, ext_imm, src_b, result_mux;
    wire [3:0]  ra1, ra2, flags;
    wire [2:0]  alu_control;
    wire [1:0]  imm_src, reg_src;
    wire        pc_src, mem_to_reg, alu_src, reg_write;

    // 1. PC Logic
    pc_reg pc_register (
        .clk(clk), .reset(reset), .pc_in(pc_next), .pc_out(pc)
    );

    adder pc_add4 (
        .a(pc), .b(32'd4), .y(pc_plus4)
    );

    adder pc_add8 (
        .a(pc_plus4), .b(32'd4), .y(pc_plus8)
    );

    adder pc_add_branch (
        .a(pc_plus8), .b(ext_imm), .y(pc_branch)
    );

    assign pc_next = pc_src ? pc_branch : pc_plus4;

    // 2. Instruction Memory
    imem instruction_memory (
        .addr(pc), .instr(instr)
    );

    // 3. Controller
    controller ctrl (
        .instr(instr), .flags(flags),
        .pc_src(pc_src), .mem_to_reg(mem_to_reg), .mem_write(mem_write),
        .alu_src(alu_src), .imm_src(imm_src), .reg_write(reg_write),
        .reg_src(reg_src), .alu_control(alu_control)
    );

    // MUX chọn địa chỉ đọc cho Register File
    assign ra1 = reg_src[0] ? 4'b1111 : instr[19:16];
    assign ra2 = reg_src[1] ? instr[15:12] : instr[3:0];

    // 4. Register File
    regfile registers (
        .clk(clk),.reset(reset), .we3(reg_write), .ra1(ra1), .ra2(ra2),
        .wa3(instr[15:12]), .wd3(result_mux), .r15(pc_plus8),
        .rd1(rd1), .rd2(rd2)
    );

    // 5. Extend Unit
    extend ext_unit (
        .instr_imm(instr[23:0]), .imm_src(imm_src), .ext_imm(ext_imm)
    );

    // 6. ALU Logic
    assign src_b = alu_src ? ext_imm : rd2;
    assign write_data = rd2;

    alu alu_unit (
        .a(rd1), .b(src_b), .alu_control(alu_control),
        .result(alu_out), .flags(flags)
    );

    // 7. Data Memory
    dmem data_memory (
        .clk(clk), .we(mem_write), .addr(alu_out),
        .wd(write_data), .rd(read_data)
    );

    // MUX chọn dữ liệu ghi trả về tập thanh ghi
    assign result_mux = mem_to_reg ? read_data : alu_out;

endmodule