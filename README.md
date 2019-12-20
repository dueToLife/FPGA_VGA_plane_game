# FPGA_VGA_plane_game
Just a homework.

这是本学期模拟与数字电路实验课的大作业，使用verilog硬件语言，开发板是Xilinx Nexys4。


粗略的写了一个飞机大战小游戏，mygame.v是顶层模块，用vga显示图像，并且用到了ps2接口的键盘。
但是整个程序的reset功能还是有bug，在每次reset的时候显示出来的图片可能被切割。
而且verilog没有数组啊啥的，要实现多子弹多飞机只能ctrlc+ctrlv,所以只设定了一架敌机和敌我各一颗子弹。


由于是第一次用硬件语言写程序，代码风格和架构也很丑，欢迎指正和修改。

（.m文件是提供图片转.ceo文件的一个脚本）
