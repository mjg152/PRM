function [ distance_matrix ] = create_distance_matrix(n)
cols = length(n); 
distance_matrix=zeros(cols,cols); 

for i = 1 : cols
    for j = 1 : cols
        distance_matrix(i,j)=sqrt((n(i).x-n(j).x)^2 +(n(i).y-n(j).y)^2); 
    end
end

end

