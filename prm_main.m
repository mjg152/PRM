clear; 
close all; 

%% Algorithm Inputs

number_nodes = 750; 
k_nearest_neighbors = 12; 

Q_init_k_nearest_neighbors=20; 
Q_goal_k_nearest_neighbors=20; 

generate_plots = false; 

%% Set up our map 
images_directory = 'C:\Users\michael\OneDrive\Documents\Case Western\EECS 499 Algorithmic Robotics\Project 2\Images\'
simple_rooms = 'simple_rooms.png'; 

image_rgb=imread([images_directory, simple_rooms]); 
image_bw=im2bw(image_rgb); 

[y_pixels, x_pixels]=size(image_bw); 

%% Initialize algorithm and Distribute Nodes Randomly 

for i = 1: number_nodes+2
     n=node; 
     nodeTree(i)=n.randomize_location(x_pixels, y_pixels);

     while image_bw(nodeTree(i).y, nodeTree(i).x) == 0
         %try again until our point is useful 
         nodeTree(i)=n.randomize_location(x_pixels, y_pixels);
     end 
end

% Let's make an image of our original randomized particle locations
% We'll display the particles as if they're larger than they are for our
% viewing pleasure 

imageOut = plot_on_image(image_rgb, [nodeTree(3:end).x], [nodeTree(3:end).y], ...
    75, 0 , 130, 2); 
figure; 

imshow(imageOut); 
title('Map with initial Node Distribution, Nodes in Purple', 'FontSize', 26); 
set(gcf, 'Position', get(0,'Screensize'));
hold on; 

%% Take some user input 

%Let the user select the original location of the robot 
xlabel('Please select a new initial configuration', 'FontSize', 20); 
[config_x,config_y] = ginput(1); 

%These are pixel locations, don't need to deal with Matlab interpolation 
config_x = ceil(config_x); 
config_y = ceil(config_y); 

nodeTree(1).set_x_y(config_x,config_y); 

% Now let's show the robot on the image in red, this time really large. 
originalNodes_InitConfig=plot_on_image(imageOut, nodeTree(1).x, ...
    nodeTree(1).y, 0, 255, 0, 4); 
imshow(originalNodes_InitConfig); 

%Let the user select the desired location of the robot 
xlabel('Please select the desired configuration', 'FontSize', 20); 
[desired_x, desired_y] = ginput(1); 

desired_x = ceil(desired_x); 
desired_y = ceil(desired_y); 

nodeTree(2).set_x_y(desired_x,desired_y); 

originalNodes_Init_FinalConfig=plot_on_image(originalNodes_InitConfig,  nodeTree(2).x, ...
     nodeTree(2).y, 255, 0, 0, 4); 
imshow(originalNodes_Init_FinalConfig);
title('Map with Random Node Distribution (Purple) and Initial Configuration (Green) and Desired Configuration (Red)', 'FontSize', 20); 
set(gcf, 'Position', get(0,'Screensize'));
if generate_plots
    xlabel('', 'FontSize', 20); 
    saveas(gcf, 'InitialConfiguration', 'png'); 
end 

%% Calculate distance between nodes and identify nearest neighbors 

distance_matrix = create_distance_matrix(nodeTree); 

for i = 1: number_nodes
    if i == 1
        nodeTree(i).calculate_nearest_neighbors(distance_matrix(i,:),Q_init_k_nearest_neighbors);
    elseif i ==2
        nodeTree(i).calculate_nearest_neighbors(distance_matrix(i,:),Q_goal_k_nearest_neighbors);
    else 
        nodeTree(i).calculate_nearest_neighbors(distance_matrix(i,:),k_nearest_neighbors);
    end
end

%% Check for Edges 

for i = 1 : number_nodes 
    neighbors =nodeTree(i).nearest_neighbors;
    distances = nodeTree(i).nearest_distance;
    for j = 1: length (neighbors)
        potential_edge=neighbors(j); 
        potential_edge_distance = distances(j); 
        nodeTree(i).check_for_edge(nodeTree(potential_edge).x, ...
            nodeTree(potential_edge).y, potential_edge, ...
            potential_edge_distance, image_bw);
    end 
end 

%% Paint the edgemap 

shapeInserter = vision.ShapeInserter('Shape','Lines', ...
'BorderColor','Custom', 'CustomBorderColor',uint8([255 255 0]));
originalNodes_Graph = originalNodes_Init_FinalConfig; 
for i = number_nodes+2:-1:1 %Count down to define default shape inserter first
    %and to make red and green lines appear last for display purposes 
    if i == 1
        shapeInserter = vision.ShapeInserter('Shape','Lines', ...
        'BorderColor','Custom', 'CustomBorderColor',uint8([0 255 0]));
    elseif i == 2
        shapeInserter = vision.ShapeInserter('Shape','Lines', ...
        'BorderColor','Custom', 'CustomBorderColor',uint8([255 0 0]));
        
    end 
    edges = nodeTree(i).edges;
    begin_x = nodeTree(i).x; 
    begin_y = nodeTree(i).y; 
    
    for j = 1: length (edges)
        
        edge=edges(j); 
        end_x = nodeTree(edge).x; 
        end_y = nodeTree(edge).y; 
        
        lineCoordinates= int32([begin_x, begin_y, end_x, end_y]);   
        
        originalNodes_Graph= ...
        shapeInserter(originalNodes_Graph, lineCoordinates);
        
    end 
    
end 
 
fig=figure; 
imshow(originalNodes_Graph);
hold on; 
title('Map with Edges Shown in Yellow, Edges to Desired / Start Configuration in Red and Green ', 'FontSize', 20); 
set(gcf, 'Position', get(0,'Screensize'));
if generate_plots
    saveas(gcf, 'Edgemap', 'png'); 
end 

%% Build Roadmap 
Q_init=nodeTree(1); 
Q_goal=nodeTree(2); 

edges_near_goal= Q_goal.edges; 
edges = Q_init.edges; 

connection_to_goal=false; 

roadMap(1).x =Q_init.x;
roadMap(1).y =Q_init.y; 
roadMap(1).node = 1; 
roadMap(1).child_nodes= edges;
roadMap(1).distances = Q_init.edge_distances; 
roadMap(1).child_indices=[]; 
roadMap(1).proximate_to_goal=false;     
roadMap(1).parent_index=[]; 
roadMap(1).distance_to_parent=[]; 

counter = 1; 

incompleteNodes = [1]; 

  
while length(incompleteNodes > 0)
    counter=counter+1; 
    index = incompleteNodes(1);
    while length(roadMap(index).child_nodes) == 0
        %forget this node, its not helpful to us
        incompleteNodes = incompleteNodes(2:end); 
        counter = counter + 1; 
        index = incompleteNodes(1)
    end 
    
    neighbor_index=length(roadMap(index).child_indices)+1;
    neighbor = roadMap(index).child_nodes(neighbor_index);
    nodes = [roadMap.node];
    visitedBefore = max(neighbor == nodes) == 1;
    
    connection_to_goal=max(neighbor == edges_near_goal) ;
    roadMap(counter).proximate_to_goal=connection_to_goal; 
    if ~visitedBefore
        roadMap(index).child_indices = [roadMap(index).child_indices, counter];
        roadMap(counter).x = nodeTree(neighbor).x;
        roadMap(counter).y =nodeTree(neighbor).y;
        roadMap(counter).node=neighbor; 
        roadMap(counter).parent_index=index; 
        roadMap(counter).distance_to_parent=sqrt(((nodeTree(neighbor).x-...
           nodeTree(index).x)^2)+((nodeTree(neighbor).y-nodeTree(index).y)^2)); 
       
        %Check for connection to goal to see if we need to move on
        

        if ~connection_to_goal
             
            roadMap(counter).child_nodes= ...
                nodeTree(neighbor).edges;
            
            if max(counter == incompleteNodes) == 0
                incompleteNodes = [incompleteNodes, counter]; 
            end
        else
            
            incompleteNodes = incompleteNodes(2:end); 
 
            
        end 

              
        if length(roadMap(index).child_indices) == ...
                length(roadMap(index).child_nodes) && ~connection_to_goal

            incompleteNodes = incompleteNodes(2:end); 

        end
    else 
        %remove this child we've been here before 
       
        if connection_to_goal
            roadMap(counter)=[]; 
            incompleteNodes = incompleteNodes(2:end); 
        end
        
        roadMap(index).child_nodes(neighbor_index) = [];
        counter = counter -1; 

        %Check if we're done with this index 
        if (length(roadMap(index).child_indices) == ...
                length(roadMap(index).child_nodes)) ...
                && ~connection_to_goal

            incompleteNodes = incompleteNodes(2:end); 

        end

    end
    
end 
%% Generate Paths 

%First clean up proximate_to_goal to make sure our indices align 
for i = 1 : length(roadMap)
    if isempty(roadMap(i).proximate_to_goal);
        roadMap(i).proximate_to_goal = 0; 
    end
end 

proxGoal = [roadMap.proximate_to_goal];      
indicesNearGoal=find(proxGoal==1);

for i = 1 : length(indicesNearGoal) 
    currentGoal=indicesNearGoal(i); 
    parent_index = roadMap(currentGoal).parent_index; 
    path_plan(i).indices = []; 
    path_plan(i).distances=[]; 
    path_plan(i).nodes=[]; 
    
    while parent_index ~= 1
        path_plan(i).nodes = [path_plan(i).nodes, roadMap(currentGoal).node];
        path_plan(i).indices = [path_plan(i).indices, parent_index];
        path_plan(i).distances = [path_plan(i).distances, ...
            roadMap(currentGoal).distance_to_parent];
        currentGoal = parent_index; 
        parent_index = roadMap(currentGoal).parent_index; 
    end 
    
    path_plan(i).nodes=[2,path_plan(i).nodes,1];
    path_plan(i).distance_sum = sum( path_plan(i).distances); 
end 

%% Paint the path plan 
  
originalNodes_Path = originalNodes_Init_FinalConfig; 
for i = 1 : max(length(path_plan)-1,1)
    if i == 1
        shapeInserter = vision.ShapeInserter('Shape','Lines', ...
        'BorderColor','Custom', 'LineWidth', 4, ...
        'CustomBorderColor',uint8([255 0 0]));
    elseif i == 2
        shapeInserter = vision.ShapeInserter('Shape','Lines', ...
        'BorderColor','Custom','LineWidth', 4, ...
        'CustomBorderColor',uint8([0 255 0]));
    
    elseif i == 3
        shapeInserter = vision.ShapeInserter('Shape','Lines', ...
        'BorderColor','Custom','LineWidth', 4, ...
        'CustomBorderColor',uint8([0 0 255]));
    else 
        shapeInserter = vision.ShapeInserter('Shape','Lines', ...
        'BorderColor','Custom', 'LineWidth', 4, ...
        'CustomBorderColor',uint8([floor(255*rand(1))...
        floor(255*rand(1)) floor(255*rand(1))]));
    end
    
    edges = path_plan(i).nodes;
    
    for j = 1: length (edges) -1
        
        begin_x = nodeTree(edges(j)).x; 
        begin_y = nodeTree(edges(j)).y; 
    
        end_x = nodeTree(edges(j+1)).x; 
        end_y = nodeTree(edges(j+1)).y; 
        
        lineCoordinates= int32([begin_x, begin_y, end_x, end_y]);   
        
        originalNodes_Path= ...
        shapeInserter(originalNodes_Path, lineCoordinates);
        
    end 
    
end 
 
fig=figure; 
imshow(originalNodes_Path);
hold on;             
title('Path Plans: R is Shortest, G Second Shortest, B Third Shortest, Random Colors for Remaining Paths', 'FontSize', 20); 
set(gcf, 'Position', get(0,'Screensize'));
if generate_plots
    saveas(gcf, 'Paths', 'png'); 
end 

%% Clean Up Best Path 

best_path = path_plan(1); 
number_nodes = length(best_path.nodes ); 

reduced_nodes = []; 
nodes_to_keep = [best_path.nodes(1)];

index = 0; 
i = 1; 
while i < number_nodes - 2
    i = index+1;   
    current_node = best_path.nodes(i); 
   
    begin_x = nodeTree(best_path.nodes(i)).x; 
    begin_y = nodeTree(best_path.nodes(i)).y; 

    edge = ones(1,i); 

    counter = i; 
    while (counter < number_nodes-1) && (min(edge) == 1)
        counter = counter + 1;

        best_path.nodes(counter+1);

        end_x = nodeTree(best_path.nodes(counter+1)).x; 
        end_y = nodeTree(best_path.nodes(counter+1)).y;

        edge(counter) = check_for_edge(begin_x, end_x, begin_y,...
            end_y, image_bw);
         
    end 
    [index, ~]=max(find(edge == 1));
    index=min(number_nodes-1, index);
    nodes_to_keep = [nodes_to_keep , best_path.nodes(index+1)];
    
end 
  
%calculate new distance and compare to previous 

optimized_distance = calc_pixel_distance(nodes_to_keep, nodeTree); 
best_path_distance = calc_pixel_distance(best_path.nodes, nodeTree); 

distance_reduction_percent=100-(optimized_distance / best_path_distance)*100

shapeInserter = vision.ShapeInserter('Shape','Lines', ...
    'BorderColor','Custom', 'LineWidth', 4, ...
    'CustomBorderColor', uint8([255 0 0]));

%% Paint our best path 
edges = nodes_to_keep;
originalNodes_PathCleaned = originalNodes_Init_FinalConfig; 

fig=figure; 
imshow(originalNodes_PathCleaned);
hold on;             
title('Cleaned Up Shortest Distance Plan', 'FontSize', 20); 
set(gcf, 'Position', get(0,'Screensize'));

for j = 1: length (edges) -1

    begin_x = nodeTree(edges(j)).x;
    begin_y = nodeTree(edges(j)).y; 

    end_x = nodeTree(edges(j+1)).x; 
    end_y = nodeTree(edges(j+1)).y; 
   
    lineCoordinates= int32([begin_x, begin_y, end_x, end_y,])  ;

    line([begin_x,end_x],[begin_y,end_y],'Color','r','LineWidth',4)

end 
        

if generate_plots
    saveas(gcf, 'ShortestDistancePlan', 'png'); 
end 

