module my_game(
    input clk, rst,
    input button_left, button_shoot, button_right, button_up, button_down,
    input ps2_clk,ps2_data,
    output [7:0] SSEG_CA, SSEG_AN,
    output [7:0] led,
    output hs, vs,
    output [11:0] rgb);
//这一部分宏定义或许可以移到模块里，先放在主模块以备查看
//相关宏定义声明，数据来自所使用的素材大小
parameter MY_PLANE_WIDTH = 11'd128, MY_PLANE_HEIGHT = 11'd128;
parameter ENEMY_PLANE_WIDTH = 11'd128, ENEMY_PLANE_HEIGHT = 11'd128;
parameter MY_BULLET_WIDTH = 11'd32, MY_BULLET_HEIGHT = 11'd64;
parameter ENEMY_BULLET_WIDTH = 11'd18, ENEMY_BULLET_HEIGHT = 11'd33;
//采用1024*768@60Hz的屏幕，以下是相关参数
parameter HOR_SYNC = 11'd136, HOR_BACK_PORCH = 11'd160, HOR_ACTIVE_VEDIO = 11'd1024, HOR_FRONT_PORCH = 11'd24;//136+160+1024+24=1345
parameter VER_SYNC = 11'd6, VER_BACK_PORCH= 11'd29, VER_ACTIVE_VEDIO = 11'd768, VER_FRONT_PORCH = 11'd3; //6+29+768+3=806
//图像像素点个数，读ROM时使用
parameter IMAGE_PIX_NUMER = 16384;



//留给后面的变量申明
wire clk_60Hz, active_video, clk_65MHz, clk_100Hz, locked;
wire vs_neg;
wire up, down, left, right,shoot;
wire have_bullet_now, have_enemy_bullet_now;
wire [10:0] screen_x, screen_y;
wire [10:0] enemy_x, enemy_y;
wire [10:0] enemy_bullet_x, enemy_bullet_y;
wire [10:0] my_plane_x, my_plane_y;
wire [10:0] my_bullet_x, my_bullet_y;
wire [3:0] hited, hit;
wire play;
wire A_left_key_press,A_right_key_press,A_up_key_press, A_down_key_press;
wire B_left_key_press,B_right_key_press,B_up_key_press,B_down_key_press;
wire A_fire, B_fire;


//模块调用部分
generate_clk_60Hz M0(
    .clk        (clk),
    .rst        (shoot),
    .clk_60Hz   (clk_60Hz));

VGA_driver M1(
    .clk        (clk_65MHz),
    .rst        (shoot),
    .hs         (hs),
    .vs         (vs),
    .vs_neg     (vs_neg),
    .screen_x   (screen_x),
    .screen_y   (screen_y),
    .active_video   (active_video));

VGA_rgb M2(
    .clk        (clk_65MHz),
    .rst        (shoot),
    .hited      (hited),
    .up         (up),
    .play       (play),
    .active_video   (active_video),
    .screen_x   (screen_x),
    .screen_y   (screen_y),
    .enemy_x    (enemy_x),
    .enemy_y    (enemy_y),
    .enemy_bullet_x (enemy_bullet_x),
    .enemy_bullet_y (enemy_bullet_y),
    .my_plane_x (my_plane_x),
    .my_plane_y (my_plane_y),
    .my_bullet_x    (my_bullet_x),
    .my_bullet_y    (my_bullet_y),
    .have_bullet_now    (have_bullet_now),
    .have_enemy_bullet_now  (have_enemy_bullet_now),
    .rgb        (rgb));

enemy_position M3(
    .vs_neg   (vs_neg),
    .clk   (clk_65MHz),
    .rst        (shoot),
    .enemy_x    (enemy_x),
    .enemy_y    (enemy_y));

generate_clk_65MHz M4(
    .clk_in1    (clk),
    .clk_65MHz  (clk_65MHz),
    .reset      (rst),
    .locked     (locked));

enemy_bullet_position M5(
    .vs_neg   (vs_neg),
    .clk        (clk_65MHz),
    .rst        (shoot),
    .my_plane_x (my_plane_x),
    .my_plane_y (my_plane_y),
    .hited    (hited),
    .play       (play),
    .have_enemy_bullet_now  (have_enemy_bullet_now),
    .enemy_x    (enemy_x),
    .enemy_y    (enemy_y),
    .have_bullet_now (have_bullet_now),
    .enemy_bullet_x (enemy_bullet_x),
    .enemy_bullet_y (enemy_bullet_y));

generate_clk_100Hz M6(
    .clk        (clk),
    .rst        (shoot),
    .clk_100Hz   (clk_100Hz));
/*
VGA M7(
    .clk        (clk_65MHz),
    .rst        (rst),
    .hs         (hs),
    .vs         (vs),
    .active_video   (active_video),
    .enemy_x    (enemy_x),
    .enemy_y    (enemy_y),
    .enemy_bullet_x (enemy_bullet_x),
    .enemy_bullet_y (enemy_bullet_y),
    .vs_neg     (vs_neg),
    .rgb        (rgb));
*/

button_control M8(
    .clk    (clk),
    .rst    (rst),
    .button_down    (button_down),
    .button_left    (button_left),
    .button_right   (button_right),
    .button_up    (button_up),
    .button_shoot   (button_shoot),
    .down   (down),
    .left   (left),
    .up     (up),
    .right  (right),
    .shoot  (shoot),
    .led    (led));

my_plane_control M9(
    .clk    (clk),
    .rst    (shoot),
    .up     (A_up_key_press),
    .down   (A_down_key_press),
    .right  (A_right_key_press),
    .left   (A_left_key_press),
    .vs_neg (vs_neg),
    .my_plane_x     (my_plane_x),
    .my_plane_y     (my_plane_y));

my_bullet_control M10(
    .clk    (clk_65MHz), //change
    .rst    (shoot),
    .shoot  (A_fire),
    .vs_neg (vs_neg),
    .enemy_x    (enemy_x),
    .enemy_y    (enemy_y),
    .hit        (hit),
    .my_plane_x (my_plane_x),
    .my_plane_y (my_plane_y),
    .my_bullet_x    (my_bullet_x),
    .my_bullet_y    (my_bullet_y),
    .have_bullet_now    (have_bullet_now));

ssegment M11(
    .clk    (clk),
    .rst    (shoot),
    .SSEG_CA    (SSEG_CA),
    .SSEG_AN    (SSEG_AN),
    .hit    (hit),
    .hited  (hited));
    
KeyBoard_TOP M12(
    .clk    (clk),
    .rst    (shoot),
    .ps2_clk    (ps2_clk),
    .ps2_data   (ps2_data),
    .A_left_key_press   (A_left_key_press),
	.A_right_key_press     (A_right_key_press),
	.A_up_key_press        (A_up_key_press),
	.A_down_key_press      (A_down_key_press),
	.B_left_key_press      (B_left_key_press),
	.B_right_key_press     (B_right_key_press),
	.B_up_key_press        (B_up_key_press),
	.B_down_key_press      (B_down_key_press),
	.A_fire        (A_fire),
	.B_fire        (B_fire));
    
endmodule
