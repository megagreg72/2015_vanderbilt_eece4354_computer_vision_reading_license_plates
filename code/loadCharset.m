% creates an image for each legal character, using license plate images
problem = '0';
inDirName = './plates/character_set/';
outDirName = './loadCharset_results/';
characters = '-0123456789abcdefghijklmnopqrstuvwxyz';
files = dir(strcat(inDirName, '*.jpg'));

x_crop_left = 0.02;
x_crop_right = 0.02;
y_crop_top = 0.25;
y_crop_bottom = 0.2;

% how close to the correct color (black) a pixel has to be
color_blob_thresh = 0.2;
% how much of a row or column has to be the correct color or get thrown out
x_crop_density = 0.05;
y_crop_density = 0.1;
% how wide a blob needs to be compare to the whole image
min_blob_width = 0.1;

imageWidths = [];
for i=1:length(files)
    imageName = files(i).name;
    imagePath = strcat(inDirName, imageName);
    I = imread(imagePath);
    [~,imageWidths(i)] = size(I);
end
[sortImageWidths,IndexSortImageWidths] = sort(imageWidths);

Is_trimmed = {};
images_blobs = {};
tallestCharacterHeight = 0;
for i=1:length(files)
    imageName = files(i).name;
    imagePath = strcat(inDirName, imageName);
    
    strcat('image #', num2str(i), '/', num2str(length(files))) 
    outputPrefix = strcat(outDirName, 'q', problem, '_', imageName, ...
        '_');
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

    I_thresholded = I3<(color_blob_thresh*255);
    imwrite(I_thresholded, strcat(outputPrefix, 'thresholded.tif'));
    
    [~, height] = size(I_thresholded);
    
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
    I_trimmed = [];
    I_trimmed_index = 1;
    for x = 1:length(column_sums)
        if(column_sums(x) > x_crop_density*width)
             I_trimmed(:, I_trimmed_index) = I_y_trimmed(:,x);
             I_trimmed_index = I_trimmed_index + 1;
        end
    end
    [height,width] = size(I_y_trimmed);
    imwrite(I_trimmed, strcat(outputPrefix, 'trimmed.tif'));
    
    [~, num_blobs] = size(blob_boxes);
    for blob_index = 1:num_blobs
        I_blob = blob_boxes{blob_index};
        imwrite(I_blob, strcat(outputPrefix, 'blob_', num2str(blob_index), '.tif'));
    end
    
    % save information about this image
    Is_trimmed{i} = I_trimmed;
    images_blobs{i} = blob_boxes;
    if height > tallestCharacterHeight
        tallestCharacterHeight = height;
    end
    
end

sample_blobs = {};
for i=1:length(files)
    fileName = files(IndexSortImageWidths(i)).name;
    fileName = fileName(1:length(fileName)-4)
    blobs = images_blobs{IndexSortImageWidths(i)};
    numBlobs = length(blobs);
    if(numBlobs ~= length(fileName))
        strcat('Error: expected to find ', num2str(length(fileName)), ...
        ' characters, but found ', num2str(numBlobs), ' blobs')
    end
    for j = 1:length(fileName)
        strcat('mapping character #', num2str(j))
        alphaIndex = (find(characters == fileName(j)));
        if(size(alphaIndex,2) > 0)
            % we use ~ in some filenames to denote a junk blob
            sample_blobs{alphaIndex} = blobs{j};
        end
    end
end

outputPrefix = strcat(outDirName, 'q', problem, '_');
% resize images
Is = {};
images_blobs_resized = {};
for i=1:length(sample_blobs)
    I = sample_blobs{i};
    [height, width] = size(I);
    scaleFactor = tallestCharacterHeight / height;
    I_resized = imresize(sample_blobs{i}, scaleFactor);
    Is{i} = I_resized;
    imwrite(Is{i}, strcat(outputPrefix, 'char_', characters(i), '.tif'));
end 
