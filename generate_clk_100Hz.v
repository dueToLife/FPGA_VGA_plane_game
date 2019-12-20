module generate_clk_100Hz(
    input clk, rst,
    output reg clk_100Hz);

reg [31:0] counter_100Hz;
initial begin
    counter_100Hz = 32'h0;
    clk_100Hz = 1'b0;
end

always @(posedge clk or posedge rst) begin
    if(rst)
        counter_100Hz = 32'h0;
    else if(counter_100Hz == 32'h0007_A120) 
        counter_100Hz = 32'h0;
    else 
        counter_100Hz = counter_100Hz + 1;
end

always @(posedge clk or posedge rst) begin
    if(rst)
        clk_100Hz <= 0;
    else if(counter_100Hz == 32'h0007_A120)
        clk_100Hz <= ~clk_100Hz;
end
endmodule