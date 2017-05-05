function [ edge ] = check_for_edge(x_begin, x_end, y_begin, y_end, image )

x_pixels = x_end - x_begin; 
y_pixels = y_end - y_begin; 

if abs(x_pixels) >=1 & abs(y_pixels) >=1
    if abs(x_pixels) > abs(y_pixels) % build arrays based on y pixel count 
        x_step = 1; 
        y_step =  abs(y_pixels) / abs(x_pixels);

        x_array = [x_begin : x_step*sign(x_pixels) : x_end];
        y_array = [y_begin : y_step*sign(y_pixels) : y_end];

        y_array = max(floor(y_array),1); 

    else %build arrays based on x_pixel count 
        y_step = 1; 
        x_step = abs(x_pixels) / abs(y_pixels);

        x_array = [x_begin : x_step*sign(x_pixels) : x_end];
        y_array = [y_begin : y_step*sign(y_pixels) : y_end];

        x_array = max(floor(x_array),1); 
    end 

elseif abs(x_pixels) < 1 & abs(y_pixels) <1

    y_array = [y_end];
    x_array = [x_end];

elseif abs(x_pixels) < 1 & abs(y_pixels) >=1
    y_step = 1; 
    y_array = [y_begin : y_step*sign(y_pixels) : y_end];
    x_array = ones(1, length(y_array))*x_end; 
    x_array = max(floor(x_array),1);
else
    x_step = 1; 
    x_array = [x_begin : x_step*sign(x_pixels) : x_end];
    y_array = ones(1, length(x_array))*y_end; 
    y_array = max(floor(y_array),1);
end 


image_values=zeros(length(x_array),1); 

for i = 1 : length(x_array)
    image_values(i) = image(y_array(i),x_array(i)); 
end 

if min(image_values) == 1
    edge = true;
else 
    edge = false; 
end 

end

