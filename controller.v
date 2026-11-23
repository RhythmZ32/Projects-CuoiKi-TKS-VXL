module controller (
    input  wire [31:0] instr,
    input  wire [3:0]  flags,
    output wire        pc_src,
    output wire        mem_to_reg,
    output wire        mem_write,
    output wire        alu_src,
    output wire [1:0]  imm_src,
    output wire        reg_write,
    output wire [1:0]  reg_src,
    output wire [2:0]  alu_control
);
    wire [1:0] op       = instr[27:26];
    wire [5:0] funct    = instr[25:20];
    wire [3:0] cond     = instr[31:28];

    reg        reg_write_raw, mem_write_raw, branch;
    reg [1:0]  alu_op;
    reg [2:0]  alu_ctrl_reg;
    reg [1:0]  imm_src_reg, reg_src_reg;
    reg        alu_src_reg, mem_to_reg_reg;

    assign imm_src    = imm_src_reg;
    assign reg_src    = reg_src_reg;
    assign alu_src    = alu_src_reg;
    assign mem_to_reg = mem_to_reg_reg;

    // Main Decoder
    always @(*) begin
        case (op)
            2'b00: begin // Data Processing / MOV
                reg_src_reg   = (funct[4:1] == 4'b1101) ? 2'b10 : 2'b00;
                imm_src_reg   = 2'b00;
                alu_src_reg   = funct[5];
                mem_to_reg_reg= 1'b0;
                mem_write_raw = 1'b0;
                reg_write_raw = 1'b1;
                branch        = 1'b0;
                alu_op        = 2'b10;
            end
            2'b01: begin // LDR / STR
                reg_src_reg   = (funct[0] == 1'b0) ? 2'b10 : 2'b00;
                imm_src_reg   = 2'b01;
                alu_src_reg   = 1'b1;
                mem_to_reg_reg= funct[0];
                mem_write_raw = ~funct[0];
                reg_write_raw = funct[0];
                branch        = 1'b0;
                alu_op        = 2'b00;
            end
            2'b10: begin // Branch (B)
                reg_src_reg   = 2'b01;
                imm_src_reg   = 2'b10;
                alu_src_reg   = 1'b1;
                mem_to_reg_reg= 1'b0;
                mem_write_raw = 1'b0;
                reg_write_raw = 1'b0;
                branch        = 1'b1;
                alu_op        = 2'b01;
            end
            default: begin
                reg_src_reg   = 2'b00;
                imm_src_reg   = 2'b00;
                alu_src_reg   = 1'b0;
                mem_to_reg_reg= 1'b0;
                mem_write_raw = 1'b0;
                reg_write_raw = 1'b0;
                branch        = 1'b0;
                alu_op        = 2'b00;
            end
        endcase
    end

    // ALU Decoder trong module controller
    always @(*) begin
        if (alu_op == 2'b00)      alu_ctrl_reg = 3'b000; // Mặc định ADD cho LDR/STR
        else if (alu_op == 2'b01) alu_ctrl_reg = 3'b001; // Mặc định SUB cho Branch
        else begin
            case (funct[4:1])
                4'b0100: alu_ctrl_reg = 3'b000; // ADD
                4'b0010: alu_ctrl_reg = 3'b001; // SUB
                4'b0000: alu_ctrl_reg = 3'b010; // AND
                4'b1100: alu_ctrl_reg = 3'b011; // ORR
                4'b1101: alu_ctrl_reg = 3'b100; // MOV
                4'b0001: alu_ctrl_reg = 3'b101; // EOR / XOR
                default: alu_ctrl_reg = 3'b000;
            endcase
        end
    end
    assign alu_control = alu_ctrl_reg;

    // Cond Logic
    reg cond_ex;
    wire n = flags[3], z = flags[2], c = flags[1], v = flags[0];

    always @(*) begin
        case (cond)
            4'b0000: cond_ex = z;      // EQ
            4'b0001: cond_ex = ~z;     // NE
            4'b1110: cond_ex = 1'b1;   // AL (Always)
            default: cond_ex = 1'b1;
        endcase
    end

    assign pc_src    = branch & cond_ex;
    assign reg_write = reg_write_raw & cond_ex;
    assign mem_write = mem_write_raw & cond_ex;
endmodule