module generate_clk_60Hz(
    input clk, rst,
    output reg clk_60Hz);

reg [31:0] counter_60Hz;

initial begin
    counter_60Hz = 32'h0000_0000;
    clk_60Hz = 1'b0;
end

always @(posedge clk or posedge rst) begin
    if(rst)
        counter_60Hz = 32'h0;
    else if(counter_60Hz == 32'h000C_B735) 
        counter_60Hz = 32'h0;
    else 
        counter_60Hz = counter_60Hz + 1;
end

always @(posedge clk or posedge rst) begin
    if(rst)
        clk_60Hz <= 0;
    else if(counter_60Hz == 32'h000C_B735)
        clk_60Hz <= ~clk_60Hz;
end
endmodule