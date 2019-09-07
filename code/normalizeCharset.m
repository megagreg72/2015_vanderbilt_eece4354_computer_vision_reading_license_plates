% loads in images of each legal character, nomalizes their height,
% and saves them as a .mat data file
problem = '0';
inDirName = './charset_unnormalized/';
outDirName = './normalizeCharset_results/';
characters = '-0123456789abcdefghijklmnopqrstuvwxyz';
files = dir(strcat(inDirName, '*.tif'));

images = {};
tallestCharacterHeight = 0;
for i=1:length(files)
    fileName = files(i).name;
    % remove file extension
    char = fileName(1:length(fileName)-4);
    imagePath = strcat(inDirName, fileName);
    
    strcat('image #', num2str(i), '/', num2str(length(files))) 
    outputPrefix = strcat(outDirName, char, '_');
    I = imread(imagePath);
    [h, w, bands] = size(I);
    if(bands == 1)
        images{i} = I;
        imwrite(I, strcat(outDirName, char, '.tif'));
    elseif(bands == 4)
        % pretty weird
        I_rgb = I(:,:,1:3);
        I_fixed = rgb2gray(I_rgb);
        images{i} = I_fixed;
        imwrite(I_fixed, strcat(outDirName, char, '.tif'));
    else
        % really bad
        % crash it!
        x = ones(9999999999999,9999999999999);
    end
    % images should be in same order files were loaded, i.e. -012..ab..z
    
    [h, w, bands] = size(I);
    if h > tallestCharacterHeight
        tallestCharacterHeight = h;
    end
end

% resize images
Is = {};
images_blobs_resized = {};
for i=1:length(images)
    I = images{i};
    char = characters(i);
    outputPrefix = strcat(outDirName);
    [height, width] = size(I);
    scaleFactor = tallestCharacterHeight / height;
    if(scaleFactor ~= 1)
        I_resized = imresize(images{i}, scaleFactor,'lanczos2');
    else
        I_resized = I;
    end
    Is{i} = I_resized;
    imwrite(Is{i}, strcat(outputPrefix, char, '.tif'));
end 
