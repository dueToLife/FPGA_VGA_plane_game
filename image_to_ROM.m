clear
clc
image_filename = 'SNAKE.jpg ';
coe_filename =  'SNAKE.coe';
image_array = imread(image_filename);
[height, width, z] = size(image_array);

imshow(image_array);
red = image_array(:, :, 1);
green = image_array(:, :, 2);
blue = image_array(:, :, 3);
r = uint32(reshape(red', 1, height * width));
g = uint32(reshape(green', 1, height * width));
b = uint32(reshape(blue', 1, height * width));

rgb = zeros(1, height * width);

for i = 1: height * width
    rgb(i) = bitshift(bitshift(r(i), -4), 8) + bitshift(bitshift(g(i), -4), 4) + bitshift(bitshift(b(i), -4), 0);
end

fid = fopen(coe_filename, 'w+');
fprintf(fid, 'memory_initialization_radix=16;\n');
fprintf(fid, 'memory_initialization_vector=\n');
fprintf(fid, '%x,', rgb(1:end-1));
fprintf(fid, '%x;\n', rgb(end));
fclose(fid);

