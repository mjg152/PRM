    classdef node < handle
    properties 
        x = 0; 
        y = 0; 
        nearest_neighbors = [];
        nearest_distance =[]; 
        edges =[]; 
        edge_distances=[]; 
    end
    
    methods
        % Get some random locations for our particles. We're talking in 
        % pixels here so be sure to round to nearest integer value
        
        function obj=randomize_location(obj,x_size, y_size)
            rand_location = [x_size, y_size].*rand(1,2);
            obj.x=ceil(rand_location(1)); 
            obj.y=ceil(rand_location(2)); 
        end
        

        function obj=calculate_nearest_neighbors(obj, distance_matrix_row, k)
           
            [sorted_distance, sorted_indices]=...
                sort(distance_matrix_row, 'ascend');
           obj.nearest_neighbors= sorted_indices(1,2:k+1); 
           obj.nearest_distance = sorted_distance(1,2:k+1); 
           
          
        end
        
        function obj = check_for_edge(obj, x, y, node_number, node_distance, image)
            edge = check_for_edge(obj.x, x, obj.y, y, image); 
            
            if edge 
                obj.edges = [obj.edges, node_number]; 
                obj.edge_distances = [obj.edge_distances, node_distance]; 
            end 
            
        end 
        
        function obj=set_x_y(obj, desiredX, desiredY)
            
          obj.x = floor(desiredX); 
          obj.y = floor(desiredY); 
          
        end
        

        
    end
    
end

