module my_plane_control(
    input clk, rst,
    input up, down, right, left,
    input vs_neg,
    output reg [10:0] my_plane_x, my_plane_y);

parameter MY_PLANE_HALF_WIDTH = 11'd64, MY_PLANE_HALF_HEIGHT = 11'd64;
parameter MY_PLANE_WIDTH = 11'd128, MY_PLANE_HEIGHT = 11'd128;
parameter HOR_SYNC = 11'd136, HOR_BACK_PORCH = 11'd160, HOR_ACTIVE_VEDIO = 11'd1024, HOR_FRONT_PORCH = 11'd24;//136+160+1024+24=1345
parameter VER_SYNC = 11'd6, VER_BACK_PORCH= 11'd29, VER_ACTIVE_VEDIO = 11'd768, VER_FRONT_PORCH = 11'd3; //6+29+768+3=806
parameter ONE_MOVE = 11'd1;
reg [10:0] my_plane_next_x, my_plane_next_y; //下一个状态，等vs_neg时用来更新my_plane_x,y, 以免刷新和移动冲突
reg [23:0] counter_up, counter_down, counter_right, counter_left;
wire counter_up_edge, counter_down_edge, counter_right_edge, counter_left_edge;

initial begin
    my_plane_x = 11'd400;
    my_plane_y = 11'd512;
    my_plane_next_x = 11'd400;
    my_plane_next_y = 11'd512;
    counter_up = 31'b0;
    counter_down = 31'b0;
    counter_right = 31'b0;
    counter_left = 31'b0;
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        counter_up <= 32'b0;
        counter_down <= 32'b0;
        counter_right <= 32'b0;
        counter_left <= 32'b0;
     end
    else begin
        if(up) counter_up <= counter_up + 1;
        else counter_up <= 32'b0;
        if(down) counter_down <= counter_down + 1;
        else counter_down <= 32'b0;
        if(right) counter_right <= counter_right + 1;
        else counter_right <= 32'b0;
        if(left) counter_left <= counter_left + 1;
        else counter_left <= 32'b0;
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
          my_plane_next_x <= 11'd400;
          my_plane_next_y <= 11'd512;
    end
    else begin
        if(counter_up_edge && (my_plane_next_y > ONE_MOVE + MY_PLANE_HALF_HEIGHT + MY_PLANE_HEIGHT))
            my_plane_next_y <= my_plane_next_y - ONE_MOVE;
        if(counter_down_edge && (my_plane_next_y + ONE_MOVE + MY_PLANE_HALF_HEIGHT < VER_ACTIVE_VEDIO))
            my_plane_next_y <= my_plane_next_y + ONE_MOVE;
        if(counter_right_edge && (my_plane_next_x + ONE_MOVE + MY_PLANE_HALF_WIDTH < HOR_ACTIVE_VEDIO))
            my_plane_next_x <= my_plane_next_x + ONE_MOVE;
        if(counter_left_edge && (my_plane_next_x > ONE_MOVE + MY_PLANE_HALF_WIDTH))
            my_plane_next_x <= my_plane_next_x - ONE_MOVE;
    end
end

always @(posedge clk or posedge rst)begin
    if(rst)begin
            my_plane_x <= 11'd400;
            my_plane_y <= 11'd512;
    end
    else if(vs_neg) 
    begin
        my_plane_x <= my_plane_next_x;
        my_plane_y <= my_plane_next_y;
    end
end

signal_edge S0(clk, counter_up[18], counter_up_edge);
signal_edge S1(clk, counter_down[18], counter_down_edge);
signal_edge S2(clk, counter_left[18], counter_left_edge);
signal_edge S3(clk, counter_right[18], counter_right_edge);
endmodule

