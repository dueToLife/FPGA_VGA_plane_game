module enemy_position( //目前只有x方向的来回运动
    input clk, rst, vs_neg,
    output reg [10:0] enemy_x, enemy_y); //给11位，1024=2^10

parameter HOR_SYNC = 11'd136, HOR_BACK_PORCH = 11'd160, HOR_ACTIVE_VEDIO = 11'd1024, HOR_FRONT_PORCH = 11'd24;//136+160+1024+24=1345
parameter VER_SYNC = 11'd6, VER_BACK_PORCH= 11'd29, VER_ACTIVE_VEDIO = 11'd768, VER_FRONT_PORCH = 11'd3; //6+29+768+3=806
parameter ENEMY_PLANE_HALF_WIDTH = 11'd64, ENEMY_PLANE_HALF_HEIGHT = 11'd64;
parameter RIGHT = 1'b1, LEFT = 1'b0;
reg enemy_v_direction;
initial begin
    enemy_x = ENEMY_PLANE_HALF_WIDTH;
    enemy_y = ENEMY_PLANE_HALF_HEIGHT;
    enemy_v_direction = RIGHT;
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        enemy_x <= ENEMY_PLANE_HALF_WIDTH;
        enemy_y <= ENEMY_PLANE_HALF_HEIGHT;
    end else if(enemy_v_direction == RIGHT && vs_neg) 
        enemy_x <= enemy_x + 2'd2;
    else if(enemy_v_direction == LEFT && vs_neg) 
        enemy_x <= enemy_x - 2'd2;
end

always @(posedge clk or posedge rst) begin
    if(rst)
        enemy_v_direction <= RIGHT;
    else
        case(enemy_v_direction)
            RIGHT:
                if(enemy_x + ENEMY_PLANE_HALF_WIDTH >= HOR_ACTIVE_VEDIO - 1) 
                    enemy_v_direction <= LEFT;
            LEFT:
                if(enemy_x - ENEMY_PLANE_HALF_WIDTH <= 4'd4)//不用0用1，因为用0的时候因为同步时序的原因有一帧是越界的，造成屏幕闪烁
                    enemy_v_direction <= RIGHT;
        endcase
end
endmodule

