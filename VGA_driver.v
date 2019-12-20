module VGA_driver(
    input clk, rst,
    output reg hs, vs, 
    output reg [10:0] screen_x, screen_y,
    output vs_neg,
    output active_video);

    parameter HCNT = 11'd1343; //136+160+1024+24=1344
    parameter VCNT = 11'd805; //6+29+768+3=806

    reg [10:0] h_cnt, v_cnt; //curr_cnt
    reg     h_de, v_de;//data_enable

    always@(posedge clk)
    begin
        if(rst)
            h_cnt <= 11'd0;
        else if(h_cnt >= 11'd1343)
            h_cnt <= 11'd0;
        else
            h_cnt <= h_cnt + 11'd1; 
    end

    always@(posedge clk)
    begin
        if(rst)
            v_cnt <= 11'd0;
        else if(h_cnt == 11'd1343) begin
            if(v_cnt >= 11'd805)
                v_cnt <= 11'd0;
            else
                v_cnt <= v_cnt + 11'd1;
        end
    end

    always @(posedge clk) begin
        if(rst) 
            h_de <= 1'b0;
        else if((h_cnt >= 296) && (h_cnt <= 1319)) 
            h_de <= 1'b1;
        else 
            h_de <= 1'b0;
    end

    always @(posedge clk)
    begin
        if(rst)
            v_de <= 1'b0;
        else if((v_cnt >= 35) && (v_cnt <= 802))
            v_de <= 1'b1;
        else 
            v_de <= 1'b0;
    end

    always @(posedge clk)
    begin
        if(rst)
            hs <= 1'b1;
        else if(h_cnt <= 11'd135)
            hs <= 1'b0;
        else
            hs <= 1'b1;
    end

    always @(posedge clk)
    begin
        if(rst)
            vs <= 1'b1;
        else if(v_cnt <= 11'd5)
            vs <= 1'b0;
        else 
            vs <= 1'b1;
    end
    reg v1,v2;
always @(posedge clk) begin
    if(rst) begin
        v1 <= 0;
        v2 <= 0;
    end else begin
        v1 <= vs;
        v2 <= v1;
    end
end

assign vs_neg = ~v1 && v2;
assign active_video = ((v_de == 1) && (h_de == 1)) ? 1'b1 : 1'b0;
always @(posedge clk or posedge rst)begin
    if(rst) begin
        screen_x <= 11'd0;
        screen_y <= 11'd0;
    end else begin
        screen_x <= h_cnt;
        screen_y <= v_cnt;
    end
end
endmodule