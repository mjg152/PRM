function [ x_ext, y_ext ] = add_pixels(x, y, pixelsToAdd)

xLength=length(x); 
pixelsToAdd = ceil(pixelsToAdd); 
    for i = 1: xLength 
        %First add pixels to the left and right of the original x, y pair
        %and keey y constant 
        xRight = [x(i):1:x(i)+pixelsToAdd];
        xLeft = [x(i)-1:-1:x(i)-pixelsToAdd];
        xNewRow=[xLeft,xRight];

        if i > 1
            x_ext=[x_ext, xNewRow];
        else
            x_ext=[xNewRow];
        end
        yNew=y(i)*ones(1,length(xNewRow)); 
        if i > 1
            y_ext=[y_ext, yNew];
        else
            y_ext=[yNew];
        end
        %once we've established our new x row, move up and down the y range
        for j = 1 : pixelsToAdd
            %Move above first
             x_ext = [x_ext, xNewRow];
             yNew=(y(i)+j)*ones(1,length(xNewRow));
             y_ext=[y_ext, yNew];

             %Then move below 
             x_ext = [x_ext, xNewRow];
             yNew=(y(i)-j)*ones(1,length(xNewRow));
             y_ext=[y_ext, yNew];
        end

    end
end

