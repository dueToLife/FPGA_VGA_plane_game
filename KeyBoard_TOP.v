`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/07 15:55:00
// Design Name: 
// Module Name: KeyBoard_TOP
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module KeyBoard_TOP(
    input clk,
    input rst,
    input ps2_clk,ps2_data,
    
    output reg A_left_key_press,
	output reg A_right_key_press,
	output reg A_up_key_press,
	output reg A_down_key_press,
	
	output reg B_left_key_press,
	output reg B_right_key_press,
	output reg B_up_key_press,
	output reg B_down_key_press,
	
	output  A_fire,
	output  B_fire
    );
    
    wire [23:0] key;
    KeyBoard_detection(clk, rst, ps2_clk, ps2_data, key);
    initial A_up_key_press=0;
    initial A_right_key_press=0;
    initial A_down_key_press=0;
    initial A_left_key_press=0;
    initial B_up_key_press=0;
    initial B_right_key_press=0;
    initial B_down_key_press=0;
    initial B_left_key_press=0;

       
       
       reg afire,bfire;
    always@(posedge clk) begin
      if((key[23:16]==8'h1D)&&(key[15:8]<8'hF0))
        A_up_key_press<=1;
      else if((key[23:16]==8'h23)&&(key[15:8]<8'hF0))
        A_right_key_press<=1;
      else if((key[23:16]==8'h1B)&&(key[15:8]<8'hF0))
        A_down_key_press<=1;
      else if((key[23:16]==8'h1C)&&(key[15:8]<8'hF0))
        A_left_key_press<=1;
      
      else if((key[23:16]==8'h1D)&&(key[15:8]==8'hF0))
        A_up_key_press<=0;
      else if((key[23:16]==8'h23)&&(key[15:8]==8'hF0))
        A_right_key_press<=0;
      else if((key[23:16]==8'h1B)&&(key[15:8]==8'hF0))
        A_down_key_press<=0;
      else if((key[23:16]==8'h1C)&&(key[15:8]==8'hF0))
        A_left_key_press<=0;
        
        
      else if((key[23:16]==8'h75)&&(key[15:8]<8'hF0))
        B_up_key_press<=1;
      else if((key[23:16]==8'h74)&&(key[15:8]<8'hF0))
        B_right_key_press<=1;
      else if((key[23:16]==8'h72)&&(key[15:8]<8'hF0))
        B_down_key_press<=1;
      else if((key[23:16]==8'h6B)&&(key[15:8]<8'hF0))
        B_left_key_press<=1;
        
      else if((key[23:16]==8'h75)&&(key[15:8]==8'hF0))
        B_up_key_press<=0;
      else if((key[23:16]==8'h74)&&(key[15:8]==8'hF0))
        B_right_key_press<=0;
      else if((key[23:16]==8'h72)&&(key[15:8]==8'hF0))
        B_down_key_press<=0;
      else if((key[23:16]==8'h6B)&&(key[15:8]==8'hF0))
        B_left_key_press<=0;
      else ;
      
      if((key[23:16]==8'h29)&&(key[15:8]<8'hF0))//´ýÈ¡±ßÑØ
        afire<=1;
      else if((key[23:16]==8'h29)&&(key[15:8]==8'hF0))
        afire<=0;
      else;
      
      if((key[23:16]==8'h70)&&(key[15:8]<8'hF0))
        bfire<=1;
      else if((key[23:16]==8'h70)&&(key[15:8]==8'hF0))
        bfire<=0;
      else;
    end
    
    reg afire_r1,afire_r2; 
    always@(posedge clk)     
      afire_r1 <= afire; 
    always@(posedge clk)     
      afire_r2 <= afire_r1; 
    
    assign A_fire = afire_r1 & (~afire_r2); 
    
        reg bfire_r1,bfire_r2; 
    always@(posedge clk)     
      bfire_r1 <= bfire; 
    always@(posedge clk)     
      bfire_r2 <= bfire_r1; 
    
    assign B_fire = bfire_r1 & (~bfire_r2); 
    
endmodule
