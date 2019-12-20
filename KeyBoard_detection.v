`timescale 1ns / 1ps

module KeyBoard_detection(
    input clk,
    input rst,
    input ps2_clk,
    input ps2_data, 
    output reg  [23:0] key  
    );
    
    reg [23:0] out;
    reg ps2_clk_r1,ps2_clk_r2; 
    wire ps2_clk_neg; 
    reg [3:0] ps2_clk_cnt; 
 
 always@(posedge clk or posedge rst) begin    
   if(rst)       
      ps2_clk_r1  <= 1'b1;   
   else        
      ps2_clk_r1  <= ps2_clk;     
 end 
      
 always@(posedge clk or posedge rst) begin     
    if(rst)        
        ps2_clk_r2  <= 1'b1;     
    else 
        ps2_clk_r2  <= ps2_clk_r1;
    end 
  
  assign ps2_clk_neg = (~ps2_clk_r1)&&(ps2_clk_r2);   
  
  always@(posedge clk or posedge rst) begin    
   if(rst)         
     ps2_clk_cnt <= 4'd0;    
   else if(ps2_clk_neg) begin         
     if(ps2_clk_cnt>=4'd10)            
       ps2_clk_cnt <= 4'd0;       
      else             
       ps2_clk_cnt <= ps2_clk_cnt + 4'd1;     
       end 
    end 
    

    always@(posedge clk or posedge rst) begin     
       if(rst)begin
        key <= 24'h0;        
        out   <= 24'h0;     
       end 
       else if(ps2_clk_neg)     
         begin        
           if((ps2_clk_cnt>=1)&&(ps2_clk_cnt<=8))            
             out <= { ps2_data,out[23:1]};
           if(ps2_clk_cnt==4'd9)
             key<=out; 
         end 
     end  
     
endmodule 

