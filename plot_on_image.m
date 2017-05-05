 function [ imageOut ] = plot_on_image(originalImage, xCoords, yCoords, ...
    R, G, B, pixelsToAdd)
    
    if pixelsToAdd > 0     
        [xCoords, yCoords]=add_pixels(xCoords,yCoords, pixelsToAdd); 
    end 
    
    imageOut = originalImage; 
    [y_pixels, x_pixels, RGB]=size(originalImage); 
    for i = 1 :  x_pixels
            for j = 1 : y_pixels
                if max(i == xCoords & j == yCoords) > 0.5
                    imageOut(j,i,:) = cat(3, R, G, B); 
                else 
                    imageOut(j,i,:) = originalImage(j,i,:); 
                end
            end 
    end


end

