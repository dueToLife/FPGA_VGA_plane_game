module my_bullet_control(
    input clk, clk_60Hz, rst,
    input shoot,
    input vs_neg,
    input [10:0] my_plane_x, my_plane_y,
    input [10:0] enemy_x, enemy_y,
    input [10:0] enemy_bullet_x, enemy_bullet_y,
    output reg [10:0] my_bullet_x, my_bullet_y,
    output reg [3:0] hit,
    output reg have_bullet_now);

reg have_bullet_now_next;
reg [10:0] my_bullet_next_x, my_bullet_next_y;

parameter MY_PLANE_WIDTH = 11'd128, MY_PLANE_HEIGHT = 11'd128;
parameter ENEMY_PLANE_WIDTH = 11'd128, ENEMY_PLANE_HEIGHT = 11'd128;
parameter MY_BULLET_WIDTH = 11'd32, MY_BULLET_HEIGHT = 11'd64;
parameter ENEMY_BULLET_WIDTH = 11'd18, ENEMY_BULLET_HEIGHT = 11'd32;

parameter MY_PLANE_HALF_WIDTH = 11'd64, MY_PLANE_HALF_HEIGHT = 11'd64;
parameter ENEMY_PLANE_HALF_WIDTH = 11'd64, ENEMY_PLANE_HALF_HEIGHT = 11'd64;
parameter ENEMY_BULLET_HALF_WIDTH = 11'd9, ENEMY_BULLET_HALF_HEIGHT = 11'd16;
parameter MY_BULLET_HALF_WIDTH = 11'd16, MY_BULLET_HALF_HEIGHT = 11'd32;

initial hit = 4'b0;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        my_bullet_next_x <= my_plane_x;
        my_bullet_next_y <= my_plane_y - MY_BULLET_HALF_HEIGHT - MY_PLANE_HALF_HEIGHT;
        have_bullet_now_next = 1'b0;
        hit = 4'b0;
    end
    else begin
        if(shoot && !have_bullet_now_next) begin
            my_bullet_next_x <= my_plane_x;
            my_bullet_next_y <= my_plane_y - MY_BULLET_HALF_HEIGHT - MY_PLANE_HALF_HEIGHT;
            have_bullet_now_next <= 1'b1;
        end
        else if(vs_neg) begin
            if(my_bullet_next_y  >  4'd3 + MY_BULLET_HALF_HEIGHT)//没有越界
                my_bullet_next_y <= my_bullet_next_y - 4'b0110;
            else begin//越界
                have_bullet_now_next <= 1'b0;
                my_bullet_next_x <= my_plane_x;
                my_bullet_next_y <= my_plane_y - MY_BULLET_HALF_HEIGHT - MY_PLANE_HALF_HEIGHT;
            end
            //击中敌机
            if((my_bullet_next_y <= enemy_y + ENEMY_PLANE_HALF_HEIGHT + MY_BULLET_HALF_HEIGHT) &&
                (my_bullet_next_x + MY_BULLET_HALF_WIDTH + ENEMY_PLANE_HALF_WIDTH >= enemy_x) &&
                (my_bullet_next_x <= enemy_x + MY_BULLET_HALF_WIDTH + ENEMY_PLANE_HALF_WIDTH) && have_bullet_now_next)
            begin
                have_bullet_now_next <= 1'b0;
                hit <= hit + 4'b1;
            end
            if(
                (my_bullet_next_x + ENEMY_BULLET_HALF_WIDTH + MY_BULLET_HALF_WIDTH >= enemy_bullet_x) &&
                (my_bullet_next_x <= enemy_bullet_x + ENEMY_BULLET_HALF_WIDTH + MY_BULLET_HALF_WIDTH) && have_bullet_now_next)
            begin
                have_bullet_now_next <= 1'b0;
            end
        end
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) have_bullet_now <= 1'b0;
    else if(vs_neg) begin
        have_bullet_now <= have_bullet_now_next;
        if(my_bullet_y - MY_BULLET_HALF_HEIGHT < 0) have_bullet_now <= 1'b0;
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        my_bullet_x <= my_plane_x;
        my_bullet_y <= my_plane_y - MY_BULLET_HALF_HEIGHT - MY_PLANE_HALF_HEIGHT;
    end 
    else if(vs_neg) begin
        my_bullet_x <= my_bullet_next_x;
        my_bullet_y <= my_bullet_next_y;
    end
end

endmodule



