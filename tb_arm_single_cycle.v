`timescale 1ns / 1ps

module tb_arm_single_cycle;

    reg         clk;
    reg         reset;
    wire [31:0] pc;
    wire [31:0] instr;
    wire [31:0] alu_out;
    wire [31:0] write_data;
    wire [31:0] read_data;
    wire        mem_write;

    integer i;

    // Khởi tạo Top Module Vi xử lý ARM
    arm_single_cycle uut (
        .clk(clk),
        .reset(reset),
        .pc(pc),
        .instr(instr),
        .alu_out(alu_out),
        .write_data(write_data),
        .read_data(read_data),
        .mem_write(mem_write)
    );

    // Tạo xung nhịp 100 MHz (Chu kỳ 10ns)
    always #5 clk = ~clk;

    initial begin
        // 1. Tín hiệu khởi tạo
        clk = 0;
        reset = 1;

        // 2. Xóa sạch rác IMEM bằng NOP (MOV R0, R0) và xóa DMEM về 0
        for (i = 0; i < 64; i = i + 1) begin
            uut.instruction_memory.RAM[i] = 32'hE1A00000;
            uut.data_memory.RAM[i]        = 32'h00000000;
        end

        // 3. Nạp kịch bản lệnh kiểm thử các phép toán
        // PC = 0  (0x00): MOV R1, #10       => R1 = 10 (0b1010)
        uut.instruction_memory.RAM[0] = 32'hE3A0100A;

        // PC = 4  (0x04): MOV R2, #5        => R2 = 5  (0b0101)
        uut.instruction_memory.RAM[1] = 32'hE3A02005;

        // PC = 8  (0x08): SUB R3, R1, R2    => R3 = 10 - 5 = 5
        uut.instruction_memory.RAM[2] = 32'hE0413002;

        // PC = 12 (0x0C): AND R4, R1, R2    => R4 = 10 AND 5 = 0b1010 & 0b0101 = 0
        uut.instruction_memory.RAM[3] = 32'hE0014002;

        // PC = 16 (0x10): ORR R5, R1, R2    => R5 = 10 OR 5 = 0b1010 | 0b0101 = 15 (0xF)
        uut.instruction_memory.RAM[4] = 32'hE1815002;

        // PC = 20 (0x14): EOR R6, R1, R2    => R6 = 10 XOR 5 = 0b1010 ^ 0b0101 = 15 (0xF)
        uut.instruction_memory.RAM[5] = 32'hE0216002;

        // PC = 24 (0x18): B .               => Lệnh nhảy dừng lặp an toàn tại chỗ
        uut.instruction_memory.RAM[6] = 32'hEAFFFFFE;

        // 4. Tháo reset để CPU bắt đầu chạy
        #12;
        reset = 0;

        // Chạy mô phỏng trong 120ns
        #120;
        
        // 5. In bảng kết quả ra cửa sổ Transcript để kiểm tra nhanh
        $display("=================================================");
        $display("--- KET QUA KIEM THU 4 PHEAP TOAN ALU ARM ---");
        $display("R1 (Gia tri 1) = %d (Hex: 0x%h)", uut.registers.rf[1], uut.registers.rf[1]);
        $display("R2 (Gia tri 2) = %d (Hex: 0x%h)", uut.registers.rf[2], uut.registers.rf[2]);
        $display("-------------------------------------------------");
        $display("R3 (SUB: 10 - 5)   = %d (Ky vong: 5)",  uut.registers.rf[3]);
        $display("R4 (AND: 10 & 5)   = %d (Ky vong: 0)",  uut.registers.rf[4]);
        $display("R5 (ORR: 10 | 5)   = %d (Ky vong: 15)", uut.registers.rf[5]);
        $display("R6 (EOR: 10 ^ 5)   = %d (Ky vong: 15)", uut.registers.rf[6]);
        $display("=================================================");

        $finish;
    end

endmodule