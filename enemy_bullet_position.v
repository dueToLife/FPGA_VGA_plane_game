module enemy_bullet_position(
    input clk, rst, vs_neg,
    input [10:0] enemy_x, enemy_y,
    input play,
    input [10:0] my_plane_x, my_plane_y,
    input [10:0] my_bullet_x, my_bullet_y,
    input have_bullet_now,
    output reg [3:0] hited,
    output reg [10:0] enemy_bullet_x, enemy_bullet_y,
    output reg have_enemy_bullet_now);

//这一部分宏定义或许可以移到模块里，先放在主模块以备查看
//相关宏定义声明，数据来自所使用的素材大小
parameter MY_PLANE_WIDTH = 11'd128, MY_PLANE_HEIGHT = 11'd128;
parameter ENEMY_PLANE_WIDTH = 11'd128, ENEMY_PLANE_HEIGHT = 11'd128;
parameter MY_BULLET_WIDTH = 11'd32, MY_BULLET_HEIGHT = 11'd64;
parameter ENEMY_BULLET_WIDTH = 11'd18, ENEMY_BULLET_HEIGHT = 11'd32;

parameter MY_PLANE_HALF_WIDTH = 11'd64, MY_PLANE_HALF_HEIGHT = 11'd64;
parameter ENEMY_PLANE_HALF_WIDTH = 11'd64, ENEMY_PLANE_HALF_HEIGHT = 11'd64;
parameter ENEMY_BULLET_HALF_WIDTH = 11'd9, ENEMY_BULLET_HALF_HEIGHT = 11'd16;
parameter MY_BULLET_HALF_WIDTH = 11'd16, MY_BULLET_HALF_HEIGHT = 11'd32;


//采用1024*768@60Hz的屏幕，以下是相关参数
parameter HOR_SYNC = 11'd136, HOR_BACK_PORCH = 11'd160, HOR_ACTIVE_VEDIO = 11'd1024, HOR_FRONT_PORCH = 11'd24;//136+160+1024+24=1345
parameter VER_SYNC = 11'd6, VER_BACK_PORCH= 11'd29, VER_ACTIVE_VEDIO = 11'd768, VER_FRONT_PORCH = 11'd3; //6+29+768+3=806

initial begin
    enemy_bullet_x <= ENEMY_PLANE_HALF_WIDTH;
    enemy_bullet_y <= ENEMY_BULLET_HALF_HEIGHT + ENEMY_PLANE_HEIGHT;
    have_enemy_bullet_now <= 1'b1;
    hited <= 4'b0000;
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        enemy_bullet_x <= ENEMY_PLANE_HALF_WIDTH;
        enemy_bullet_y <= ENEMY_BULLET_HALF_HEIGHT + ENEMY_PLANE_HEIGHT;
        hited<=4'b0000;
    end
    else begin
        if(enemy_bullet_y + ENEMY_BULLET_HALF_HEIGHT > VER_ACTIVE_VEDIO - 1'b1) begin
            enemy_bullet_x <= enemy_x;
            enemy_bullet_y <= enemy_y + ENEMY_PLANE_HALF_HEIGHT + ENEMY_BULLET_HALF_HEIGHT; 
            have_enemy_bullet_now <= 1'b1;     
        end 
    
        else if(vs_neg && hited < 4'd3) begin
            enemy_bullet_y <= enemy_bullet_y + 4'b0110;
    //        have_enemy_bullet_now <= have_enemy_bullet_now;
    //       hited <= hited;
        end
        
        if(((enemy_bullet_y + ENEMY_BULLET_HALF_HEIGHT + MY_PLANE_HALF_HEIGHT) >= my_plane_y) &&
           ((enemy_bullet_x + ENEMY_BULLET_HALF_WIDTH + MY_PLANE_HALF_WIDTH) >= my_plane_x) &&
           (enemy_bullet_x <= (my_plane_x + MY_PLANE_HALF_WIDTH + ENEMY_BULLET_HALF_WIDTH)) &&
           (enemy_bullet_y <= my_plane_y + ENEMY_BULLET_HALF_HEIGHT + MY_PLANE_HALF_HEIGHT) && have_enemy_bullet_now && play)
        begin
            have_enemy_bullet_now <= 1'b0;
            hited <= hited + 1'b1;
        end
    end
end

endmodule