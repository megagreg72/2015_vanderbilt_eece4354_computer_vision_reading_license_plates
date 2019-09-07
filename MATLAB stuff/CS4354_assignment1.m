imageName = 'trees.tif';
imageName = 'football.jpg';
imageName = 'Mona-Lisa-256x256.jpg';
I = imread(imageName);
hsv = rgb2hsv(I);
imwrite(I, 'original.png');

hsv = rgb2hsv(I);
brightness = hsv(:,:,3);
brightness2 = brightness.*3.0;
hsv(:,:,3) = brightness2;
I_brighter = hsv2rgb(hsv);
imwrite(I_brighter, 'brightness+.png');

hsv = rgb2hsv(I);
brightness = hsv(:,:,3);
brightness2 = brightness.*0.5;
hsv(:,:,3) = brightness2;
I_brighter = hsv2rgb(hsv);
imwrite(I_brighter, 'brightness-.png');

hsv = rgb2hsv(I);
saturation = hsv(:,:,2);
saturation2 = saturation.*2.0;
hsv(:,:,2) = saturation2;
I_saturated = hsv2rgb(hsv);
imwrite(I_saturated, 'saturation+.png');

hsv = rgb2hsv(I);
saturation = hsv(:,:,2);
saturation2 = saturation.*0.3;
hsv(:,:,2) = saturation2;
I_saturated = hsv2rgb(hsv);
imwrite(I_saturated, 'saturation-.png');

hsv = rgb2hsv(I);
gamma = 2.0;
brightness = hsv(:,:,3);
brightness2 = brightness.^gamma;
hsv(:,:,3) = brightness2;
I_gamma = hsv2rgb(hsv);
imwrite(I_gamma, 'gamma+.png');

hsv = rgb2hsv(I);
gamma = 0.5;
brightness = hsv(:,:,3);
brightness2 = brightness.^gamma;
hsv(:,:,3) = brightness2;
I_gamma = hsv2rgb(hsv);
imwrite(I_gamma, 'gamma-.png');

I_contrast = imadjust(I,stretchlim(I));
imwrite(I_contrast, 'contrast+.png');

I_contrast = imadjust(I,[0.0, 1.0],[0.3, 0.7]);
imwrite(I_contrast, 'contrast-.png');