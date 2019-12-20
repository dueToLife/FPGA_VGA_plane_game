module VGA_rgb(
    input clk, rst,
    input active_video,
    input [3:0] hited,
    input [10:0] screen_x, screen_y,
    input [10:0] my_plane_x, my_plane_y,
    input [10:0] my_bullet_x, my_bullet_y,
    input up,
    input have_bullet_now,
    input [10:0] enemy_x, enemy_y,
    input [10:0] enemy_bullet_x, enemy_bullet_y,
    input have_enemy_bullet_now,
    output reg play,
    output reg [11:0] rgb);
//相关宏定义声明，数据来自所使用的素材大小
parameter MY_PLANE_WIDTH = 11'd128, MY_PLANE_HEIGHT = 11'd128;
parameter ENEMY_PLANE_WIDTH = 11'd128, ENEMY_PLANE_HEIGHT = 11'd128;
parameter MY_BULLET_WIDTH = 11'd32, MY_BULLET_HEIGHT = 11'd64;
parameter ENEMY_BULLET_WIDTH = 11'd18, ENEMY_BULLET_HEIGHT = 11'd33;
parameter ENEMY_PLANE_HALF_WIDTH = 11'd64, ENEMY_PLANE_HALF_HEIGHT = 11'd64;
parameter ENEMY_BULLET_HALF_WIDTH = 11'd9, ENEMY_BULLET_HALF_HEIGHT = 11'd16;
parameter MY_PLANE_HALF_WIDTH = 11'd64, MY_PLANE_HALF_HEIGHT = 11'd64;
parameter MY_BULLET_HALF_WIDTH = 11'd16, MY_BULLET_HALF_HEIGHT = 11'd32;
//采用1024*768@60Hz的屏幕，以下是相关参数
parameter HOR_SYNC = 11'd136, HOR_BACK_PORCH = 11'd160, HOR_ACTIVE_VEDIO = 11'd1024, HOR_FRONT_PORCH = 11'd24;//136+160+1024+24=1345
parameter VER_SYNC = 11'd6, VER_BACK_PORCH= 11'd29, VER_ACTIVE_VEDIO = 11'd768, VER_FRONT_PORCH = 11'd3; //6+29+768+3=806
//图像像素点个数，读ROM时使用
parameter IMAGE_PIX_NUMBER = 16384;
parameter ENEMY_BULLET_IMAGE_PIX_NUMBER = 576;
parameter MY_BULLET_IMAGE_PIX_NUMBER = 2048;
parameter GG_IMAGE_PIX_NUMBER = 19824;
parameter GG_WIDTH = 12'd336, GG_HEIGHT = 12'd59;
parameter START1_IMAGE_PIX_NUMBER = 34320;
parameter START1_WIDTH = 12'd429, START1_HEIGHT = 12'd80;




reg [13:0] rom_addr_enemy_plane,rom_addr_my_plane;
wire [11:0] rom_data_enemy_plane, rom_data_enemy_bullet,rom_data_my_bullet, rom_data_my_plane, rom_data_GG;
wire [11:0] rom_data_start1;
reg [9:0] rom_addr_enemy_bullet;
reg [10:0] rom_addr_my_bullet;
reg [14:0] rom_addr_GG;
reg [15:0] rom_addr_start1;

//输出rgb信号
initial begin //地址初始化
    rom_addr_enemy_plane = 14'b0;
    rom_addr_enemy_bullet = 10'b0;
    rom_addr_my_plane = 14'b0;
    rom_addr_my_bullet = 11'b0;
    rom_addr_GG = 16'b0;
    play = 1'b0;
end
always @(posedge up or posedge rst) begin
    if(rst) play <= 1'b0;
    else play <= 1'b1;
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        rgb <= 12'h000;
        rom_addr_enemy_plane <= 14'b0;
        rom_addr_enemy_bullet <= 14'b0;
        rom_addr_my_plane <= 14'b0;
        rom_addr_my_bullet <= 11'b0;
        rom_addr_start1 <= 16'b0;
        rom_addr_GG <= 16'b0;
    end
    //acitve_video:0~1023
    else  begin //一个判断是小于 一个是小于等于 不然addr的更新就每次差一个像素了
        if(active_video) rgb<=12'h000;
        if(!play) begin
             if((screen_x >= (HOR_SYNC + HOR_BACK_PORCH + 12'd300)) &&
                (screen_x <= (HOR_SYNC + HOR_BACK_PORCH + 12'd300 + START1_WIDTH - 1'b1)) &&
                (screen_y >= (VER_SYNC + VER_BACK_PORCH+ 12'd350 )) &&
                (screen_y <= (VER_SYNC + VER_BACK_PORCH+ 12'd350  + START1_HEIGHT - 1'b1)))
            begin
                if((screen_x == (HOR_SYNC + HOR_BACK_PORCH + 12'd300)) && (screen_y == (VER_SYNC + VER_BACK_PORCH+ 12'd350 ))) rom_addr_start1 <= 16'b0;
                rgb <= rom_data_start1;
                if(rom_addr_start1 == START1_IMAGE_PIX_NUMBER - 1'b1)
                    rom_addr_start1 <= 16'b0;
                else 
                    rom_addr_start1 <= rom_addr_start1 + 1'b1;
            end
        end else begin
        if((screen_x >= (HOR_SYNC + HOR_BACK_PORCH + 12'd350)) &&
            (screen_x <= (HOR_SYNC + HOR_BACK_PORCH + 12'd350 + GG_WIDTH - 1'b1)) &&
            (screen_y >= (VER_SYNC + VER_BACK_PORCH+ 12'd350 )) &&
            (screen_y <= (VER_SYNC + VER_BACK_PORCH+ 12'd350  + GG_HEIGHT - 1'b1))
            && hited >= 4'd3)
        begin
            if((screen_x == (HOR_SYNC + HOR_BACK_PORCH + 12'd350)) && (screen_y == (VER_SYNC + VER_BACK_PORCH+ 12'd350 ))) rom_addr_GG <= 14'b0;
            rgb <= rom_data_GG;
            if(rom_addr_GG == GG_IMAGE_PIX_NUMBER - 1'b1)
                rom_addr_GG <= 14'b0;
            else 
                rom_addr_GG <= rom_addr_GG + 1'b1;
        end
        else if(hited < 4'd3) begin
        if((screen_x >= (HOR_SYNC + HOR_BACK_PORCH + enemy_x - ENEMY_PLANE_HALF_WIDTH)) &&
            (screen_x <= (HOR_SYNC + HOR_BACK_PORCH + enemy_x + ENEMY_PLANE_HALF_WIDTH - 1'b1)) &&
            (screen_y >= (VER_SYNC + VER_BACK_PORCH + enemy_y - ENEMY_PLANE_HALF_HEIGHT)) &&
            (screen_y <= (VER_SYNC + VER_BACK_PORCH + enemy_y + ENEMY_PLANE_HALF_HEIGHT - 1'b1)))
        begin
          if((screen_x == (HOR_SYNC + HOR_BACK_PORCH + enemy_x - ENEMY_PLANE_HALF_WIDTH)) && (screen_y == (VER_SYNC + VER_BACK_PORCH + enemy_y - ENEMY_PLANE_HALF_HEIGHT))) rom_addr_enemy_plane <= 14'b0;
            rgb <= rom_data_enemy_plane;
            if(rom_addr_enemy_plane == IMAGE_PIX_NUMBER - 1'b1)
                rom_addr_enemy_plane <= 14'b0;
            else 
                rom_addr_enemy_plane <= rom_addr_enemy_plane + 1'b1;
        end
        if((screen_x >= (HOR_SYNC + HOR_BACK_PORCH + my_plane_x - MY_PLANE_HALF_WIDTH)) &&
                 (screen_x <= (HOR_SYNC + HOR_BACK_PORCH + my_plane_x + MY_PLANE_HALF_WIDTH - 1'b1)) &&
                 (screen_y >= (VER_SYNC + VER_BACK_PORCH + my_plane_y - MY_PLANE_HALF_HEIGHT)) &&
                 (screen_y <= (VER_SYNC + VER_BACK_PORCH + my_plane_y + MY_PLANE_HALF_HEIGHT - 1'b1)))
         begin
            if((screen_x == (HOR_SYNC + HOR_BACK_PORCH + my_plane_x - MY_PLANE_HALF_WIDTH)) && (screen_y == (VER_SYNC + VER_BACK_PORCH + my_plane_y - MY_PLANE_HALF_HEIGHT))) rom_addr_my_plane <= 14'b0;
            rgb <= rom_data_my_plane;
            if(rom_addr_my_plane == IMAGE_PIX_NUMBER - 1'b1)
                rom_addr_my_plane <= 14'b0;
            else 
                rom_addr_my_plane <= rom_addr_my_plane + 1'b1;
        end
        if((screen_x >= (HOR_SYNC + HOR_BACK_PORCH + enemy_bullet_x - ENEMY_BULLET_HALF_WIDTH)) &&
                (screen_x <= (HOR_SYNC + HOR_BACK_PORCH + enemy_bullet_x + ENEMY_BULLET_HALF_WIDTH - 1'b1)) &&
                (screen_y >= (VER_SYNC + VER_BACK_PORCH + enemy_bullet_y - ENEMY_BULLET_HALF_HEIGHT)) &&
                (screen_y <= (VER_SYNC + VER_BACK_PORCH + enemy_bullet_y + ENEMY_BULLET_HALF_HEIGHT - 1'b1)) &&
                have_enemy_bullet_now)
        begin
            if((screen_x == (HOR_SYNC + HOR_BACK_PORCH + enemy_bullet_x - ENEMY_BULLET_HALF_WIDTH)) && (screen_y == (VER_SYNC + VER_BACK_PORCH + enemy_bullet_y - ENEMY_BULLET_HALF_HEIGHT))) rom_addr_enemy_bullet <= 10'b0;
            rgb <= rom_data_enemy_bullet;
            if(rom_addr_enemy_bullet == ENEMY_BULLET_IMAGE_PIX_NUMBER - 1'b1)
                rom_addr_enemy_bullet <= 10'b0;
            else
                rom_addr_enemy_bullet <= rom_addr_enemy_bullet + 1'b1;
        end
        if((screen_x >= (HOR_SYNC + HOR_BACK_PORCH + my_bullet_x - MY_BULLET_HALF_WIDTH)) &&
                (screen_x <= (HOR_SYNC + HOR_BACK_PORCH + my_bullet_x + MY_BULLET_HALF_WIDTH - 1'b1)) &&
                (screen_y >= (VER_SYNC + VER_BACK_PORCH + my_bullet_y - MY_BULLET_HALF_HEIGHT)) &&
                (screen_y <= (VER_SYNC + VER_BACK_PORCH + my_bullet_y + MY_BULLET_HALF_HEIGHT - 1'b1)) && 
                have_bullet_now)
        begin
        if((screen_x == (HOR_SYNC + HOR_BACK_PORCH + my_bullet_x - MY_BULLET_HALF_WIDTH)) &&(screen_y == (VER_SYNC + VER_BACK_PORCH + my_bullet_y - MY_BULLET_HALF_HEIGHT))) rom_addr_my_bullet <= 10'b0;
            rgb <= rom_data_my_bullet;
            if(rom_addr_my_bullet == MY_BULLET_IMAGE_PIX_NUMBER - 1'b1)
                rom_addr_my_bullet <= 10'b0;
            else
                rom_addr_my_bullet <= rom_addr_my_bullet + 1'b1;
        end
 /*       else begin
            rgb <= 12'h000;
            if(!have_bullet_now) rom_addr_my_bullet <= 11'b0;
            if(!have_enemy_bullet_now) rom_addr_enemy_bullet <= 11'b0;
            rom_addr_enemy_plane <= rom_addr_enemy_plane;
            rom_addr_enemy_bullet <= rom_addr_enemy_bullet;
            rom_addr_my_plane <= rom_addr_my_plane;
            rom_addr_my_bullet <= rom_addr_my_bullet;
        end*/
        end
        end
    end 
end

ROM_enemy_plane2_image R0(
    .a      (rom_addr_enemy_plane),
    .spo    (rom_data_enemy_plane));

ROM_enemy_bullet_image R1(
    .a      (rom_addr_enemy_bullet),
    .spo    (rom_data_enemy_bullet));

ROM_my_bullet_image R2(
    .a      (rom_addr_my_bullet),
    .spo    (rom_data_my_bullet));

ROM_my_plane_image R3(
    .a      (rom_addr_my_plane),
    .spo    (rom_data_my_plane));
    
GAME_OVER(
    .addra      (rom_addr_GG),
    .clka    (clk),
    .douta    (rom_data_GG));

ROM_start1_image R4(
    .addra  (rom_addr_start1),
    .clka   (clk),
    .douta  (rom_data_start1));
endmodule
