function [ distance ] = calc_pixel_distance(nodes, nodeTree)

distance = zeros(1,length(nodes)-1); 
for i = 1: (length(nodes)-1)
    begin_node =nodes(i); 
    end_node = nodes(i+1); 
    
    begin_x = nodeTree(begin_node).x; 
    begin_y = nodeTree(begin_node).y; 
    
    end_x = nodeTree(end_node).x;
    end_y = nodeTree(end_node).y;
    
    
    distance(i) = sqrt((begin_x-end_x)^2 + (begin_y-end_y)^2);
end

distance = sum(distance);


end

