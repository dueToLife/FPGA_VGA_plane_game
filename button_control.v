module jitter_clr(
    input clk,
    input button,
    output button_clean);
    reg [23:0] cnt;
    always@(posedge clk)
    begin
        if(button == 1'b0)
            cnt <= 24'h000000;
        else if(cnt < 24'h800000)
            cnt <= cnt + 1'b1;
    end
    assign button_clean = cnt[23];
endmodule

module signal_edge(
    input clk,
    input button,
    output button_redge);
    reg button_r1, button_r2;

always@(posedge clk)
    button_r1 <= button;

always@(posedge clk)
    button_r2 <= button_r1;

assign button_redge = button_r1 & (~button_r2);
endmodule


module button_control(
    input clk, rst,
    input button_up, button_down, button_right, button_left, button_shoot,
    output up, down, right, left, shoot,
    output reg [7:0] led);

wire button_up_clean;
wire button_down_clean;
wire button_right_clean;
wire button_left_clean;
wire button_shoot_clean;

initial led = 8'b1111_1111;

jitter_clr J0(clk, button_up, button_up_clean);
jitter_clr J1(clk, button_down, button_down_clean);    
jitter_clr J2(clk, button_right, button_right_clean);
jitter_clr J3(clk, button_left, button_left_clean);
jitter_clr J4(clk, button_shoot, button_shoot_clean);

signal_edge S0(clk, button_up_clean, up);
signal_edge S1(clk, button_down_clean, down);
signal_edge S2(clk, button_right_clean, right);
signal_edge S3(clk, button_left_clean, left);
signal_edge S4(clk, button_shoot_clean, shoot);
    
always @(posedge clk) begin
    if(rst)
        led <= 8'b1111_1111;
    else begin
        if(up)
            led[4] <= ~led[4];
        if(down)
            led[3] <= ~led[3];
        if(left)
            led[2] <= ~led[2];
        if(right) 
            led[1] <= ~led[1];
        if(shoot)
            led[0] <= ~led[0];
    end
end
endmodule  