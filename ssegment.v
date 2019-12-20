module ssegment(
    input clk, rst,
    input [3:0] hited,
    input [3:0] hit,
    output reg [7:0] SSEG_AN, SSEG_CA);

    parameter FIRST = 8'b1111_1110, THIRD = 8'b1111_1011;
    parameter LIFE = 4'd3;

    reg [31:0] count2;
    reg a;
    reg [3:0] score, life;
    wire [7:0] w1, w3;

initial begin
    score = 4'b0;
    life = LIFE;
    count2 = 4'b0;
    a = 1'b0;
end

always @(posedge clk)//·ÖÆµ
begin 
    count2 = count2 + 1;
    if(count2 == 1) a = ~ a;
    else if(count2 == 32'h0001ffff) count2 = 0;
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        score <= 4'b0;
        life <= LIFE;
    end
    else begin
        score <= hit;
        life <= LIFE - hited;
    end
end

always @(posedge clk) begin
    if(a) begin
        SSEG_AN <= FIRST;
        SSEG_CA <= w1;
    end else begin
        SSEG_AN <= THIRD;
        SSEG_CA <= w3;
    end
end

ROM_ssegment R0(score, w1);
ROM_ssegment R1(life, w3);

endmodule
        
