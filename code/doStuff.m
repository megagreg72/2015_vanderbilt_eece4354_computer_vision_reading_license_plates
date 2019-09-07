inDirName = './plates/report_example_hard/';
outDirName = './results/';
delete(strcat(outDirName, '*.*'));
files = dir(strcat(inDirName, '*.jpg'));
characters = '-0123456789abcdefghijklmnopqrstuvwxyz';
load charset.mat;

x_crop_left = 0.05;
x_crop_right = 0.04;
y_crop_top = 0.26;
y_crop_bottom = 0.26;

% how close to the correct color (black) a pixel has to be
% color_blob_thresh = 0.7;
color_blob_thresh_1 = 0.9;
color_blob_thresh_2 = 1.2;
% how much of a row or column has to be the correct color or get thrown out
x_crop_density = 0.05;
y_crop_density = 0.1;
% how wide a blob needs to be compare to the whole image
min_blob_width = 0.2;

recognizedPlates = {};
numCorrect = 0;
numIncorrect = 0;
for i=1:length(files)
    imageName = files(i).name;
    imagePath = strcat(inDirName, imageName);
    % remove file extension from image name
    imageName = imageName(1:length(imageName)-4);
    strcat('image #', num2str(i), '/', num2str(length(files))) 
    outputPrefix = strcat(outDirName, imageName, '_');
    I = imread(imagePath);
    images{i} = I;
    imwrite(I, strcat(outputPrefix, 'original.jpg'));
    
    [h, w, bands] = size(I);
    x_left = round(x_crop_left*w);
    x_right = round((1 - x_crop_right)*w);
    y_top = round(y_crop_top*h);
    y_bottom = round((1 - y_crop_bottom)*h);
    I2 = I(y_top:y_bottom, x_left:x_right, :);
    imwrite(I2, strcat(outputPrefix, 'cropped.jpg'));
    
    I3 = rgb2gray(I2);
    imwrite(I3, strcat(outputPrefix, 'cropped.tif'));
    x2_right = (x_right - x_left);
    y2_bottom = (y_bottom - y_top);

%     I3 = wiener2(I3);
%     I_thresholded = I3<(color_blob_thresh*mean(double(I3(:))));
    [I_thresholded, I_bernsen, I_otsu, I_hysthresh, I_colorthresh] ...
        = thresh(I2, color_blob_thresh_1, color_blob_thresh_2, 2);
    imwrite(I_bernsen, strcat(outputPrefix, 'bernsen.tif'));
    imwrite(I_otsu, strcat(outputPrefix, 'otsu.tif'));
    imwrite(I_hysthresh, strcat(outputPrefix, 'hysthresh.tif'));
    imwrite(I_colorthresh, strcat(outputPrefix, 'colorthresh.tif'));
    imwrite(double(I_thresholded), strcat(outputPrefix, 'thresholded.tif'));
    
    [width, height] = size(I_thresholded);
    
    % do horizontal cuts based on how many pixels are correct color
    y_trimmed_boxes = [];
    y_trimmed_box_index = 1;
    row_sums = sum(I_thresholded, 2);
    blob_started = false;
    for j = 1:length(row_sums)
        if(row_sums(j) > y_crop_density*height)
            if(~blob_started)
                blob_started = true;
                blob_top = j;
            end
        else
            if(blob_started)
                blob_bottom = j - 1;
                blob = [blob_top, blob_bottom];
                y_trimmed_boxes(y_trimmed_box_index,:) = blob;
                y_trimmed_box_index = y_trimmed_box_index + 1;
                blob_started = false;
            end
        end
    end
    I_y_trimmed = [];
    I_y_trimmed_index = 1;
    for(y = 1:length(row_sums))
        if(row_sums(y) > y_crop_density*height)
             I_y_trimmed(I_y_trimmed_index, :) = I_thresholded(y,:);
             I_y_trimmed_index = I_y_trimmed_index + 1;
        end
    end
    [width, height] = size(I_y_trimmed);
    imwrite(I_y_trimmed, strcat(outputPrefix, 'y_trimmed.tif'));
    
    % do vertical cuts based on how many pixels are correct color
    blob_boxes = {};
    blob_box_index = 1;
    column_sums = sum(I_y_trimmed, 1);
    blob_started = false;
    for j = 1:length(column_sums)
        if(column_sums(j) > x_crop_density*width)
            if(~blob_started)
                blob_started = true;
                blob_left = j;
            end
        else
            if(blob_started)
                blob_right = j - 1;
                blob_box = I_y_trimmed(:, blob_left:blob_right);
                if (blob_right-blob_left)>min_blob_width*width
                    blob_boxes{blob_box_index} = blob_box;
                    blob_box_index = blob_box_index + 1;
                end
                blob_started = false;
            end
        end
    end
    % end the last blob if one is still active
    if(blob_started)
        blob_right = j;
        blob_box = I_y_trimmed(:, blob_left:blob_right);
        if (blob_right-blob_left)>min_blob_width*width
            blob_boxes{blob_box_index} = blob_box;
            blob_box_index = blob_box_index + 1;
        end
        blob_started = false;
    end
    
    I_trimmed = [];
    I_trimmed_index = 1;
    for x = 1:length(column_sums)
        if(column_sums(x) > x_crop_density*width)
             I_trimmed(:, I_trimmed_index) = I_y_trimmed(:,x);
             I_trimmed_index = I_trimmed_index + 1;
        end
    end
    [width, height] = size(I_y_trimmed);
    imwrite(I_trimmed, strcat(outputPrefix, 'trimmed.tif'));
    
    [~, num_blobs] = size(blob_boxes);
    recognizedPlate = '';
    for blob_index = 1:num_blobs
        I_blob = blob_boxes{blob_index};
        imwrite(I_blob, strcat(outputPrefix, 'blob_', num2str(blob_index), '.tif'));
        
        bestMatch = '?';
        bestMatchStrength = 0;
        bestMatchNoShiftStrength = 0;
        bestMatchShift = [0, 0];
        for k=1:length(characters)
            targetChar = characters(k);
            targetCharI = charset{k};
            blob_resized = imresize(I_blob, size(targetCharI));
            blob_resized = (blob_resized - min(blob_resized(:)))/ ...
                (max(blob_resized(:)) - min(blob_resized(:)))*255;
            [matchStrength, noShiftStrength, shift] ...
                = getMatchStrength(blob_resized, targetCharI);
            if matchStrength > bestMatchStrength
                bestMatch = targetChar;
                bestMatchStrength = matchStrength;
                bestMatchNoShiftStrength = noShiftStrength;
                bestMatchShift = shift;
            end
        end
        recognizedPlate(blob_index) = bestMatch;
%         bestMatch
%         bestMatchStrength
%         bestMatchNoShiftStrength
%         bestMatchShift
    end
    recognizedPlates{i} = recognizedPlate;
    correctPlate = imageName;
    if(size(recognizedPlate) == size(correctPlate))
        if (recognizedPlate == correctPlate)
            numCorrect = numCorrect + 1;
        else
            numIncorrect = numIncorrect + 1;
            strcat('Mis-recognized the image "', imageName, ...
                '" as having plate "', recognizedPlate, '"')
        end
    else
        numIncorrect = numIncorrect + 1;
        strcat('Wrong number of blobs.  Mis-recognized the image "', imageName, ...
            '" as having plate "', recognizedPlate, '"')
    end
end
strcat('correctly recognized ', num2str(numCorrect), '/', num2str(numCorrect+numIncorrect), ' license plates.')
    
    
