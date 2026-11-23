module regfile (
    input  wire        clk,
    input  wire        reset, // Thêm reset để xóa rác thanh ghi
    input  wire        we3,
    input  wire [3:0]  ra1,
    input  wire [3:0]  ra2,
    input  wire [3:0]  wa3,
    input  wire [31:0] wd3,
    input  wire [31:0] r15,
    output wire [31:0] rd1,
    output wire [31:0] rd2
);
    reg [31:0] rf [14:0];
    integer i;

    assign rd1 = (ra1 == 4'b1111) ? r15 : rf[ra1];
    assign rd2 = (ra2 == 4'b1111) ? r15 : rf[ra2];

    // Khởi tạo các thanh ghi về 0 khi Reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 15; i = i + 1)
                rf[i] <= 32'b0;
        end else if (we3 && (wa3 != 4'b1111)) begin
            rf[wa3] <= wd3;
        end
    end
endmodule