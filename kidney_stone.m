%% Selecting Input Ultrasonic Image 
clc
clear all
close all
warning off
[filename, pathname]=uigetfile('*.*', 'Pick a MATLAB code file');
filename=strcat(pathname,filename);
original_image=imread(filename);
figure;
imshow(original_image),title('Sample Image'); %a


%% Image Preprocessing phase

%Converting into grayscale image && %% Getting pixel info 

gray_image=rgb2gray(original_image); %a and b
figure;
imshow(gray_image),title('Grayscale Image');
impixelinfo %Give pixel intensity of any [x,y] data coordinates  

%% Plotting histogram of grayscale image

% figure; %%Useful for applying thresolding and finding particular
% thresolding value
% imhist(gray_image),title('Histogram of grayscale image');

%% Thresolding using 20 intensity value, above 20 pixel value 1 or 0

binary_image=imbinarize(gray_image,20/255); %Otherwise Binary image or c = b>20; %divide by 255 because imbinarize
%function accepts values between 1 and 0
figure;
imshow(binary_image),title('Binary Thresolding Image');
impixelinfo

%% Filling empty black holes in binary image(thresolding)

filled_image=imfill(binary_image,'holes'); %filling black holes presented in area of interest which will fill all holes
figure;
imshow(filled_image),title('Holes filled Image');

%% Removing all binary objects which are around the Area of interest by bwareaopen function

filtered_image=bwareaopen(filled_image,1000); %Remove small objects from binary image that have fewer than P=1000
%filtered image can be used as mask which can be apply on original image
figure;
imshow(filtered_image),title('Backgroud noise filtered Image');

%% Using filtered image as mask and multiple with original image gives complete preprocessed image

PreprocessedImage=uint8(double(original_image).*repmat(filtered_image,[1 1 3])); %for arithmetic operation
%convert into double and then again convert to uint8
figure,imshow(PreprocessedImage),title("Preprocessed Image");
figure,imshowpair(original_image,PreprocessedImage,'montage'),title('Original and Preprocessed Image');

%part1 end here

%% part2 starts here

PreprocessedImage_adjust=imadjust(PreprocessedImage,[0.3 0.7],[])+50; %adjust
%imadjust function will adjust value, and <0.3 it will map to 0 & >0.7 it will map to 1 and in between [0.3,0.7] it map
% to in between floating value > this will give center area of interest and 
% by adding 50 we can enhance intensity of that specific region of interest
figure;
imshow(PreprocessedImage_adjust); 

PreprocessedImage_gray=rgb2gray(PreprocessedImage_adjust); %convert PreprocessedImage rgb image to gray scale
figure;
imshow(PreprocessedImage_gray);

median_filtered_image=medfilt2(PreprocessedImage_gray,[5 5]); %median filter for noise removal or morphological analysis can be used also
figure;
imshow(median_filtered_image);
impixelinfo
%imhist(median_filtered_image); %%global thresolding failed because of histogram isn't bimodel shape

final_filtered=median_filtered_image>250; %%applying thresolding intensity value of 250 to get main area 
figure;
imshow(final_filtered);
impixelinfo

%part2 end here

%%

%part3 starts here
[r, c, m]=size(final_filtered);
x1=r/2; %height of image/2 > r/2 < rows
y1=c/3; %width of image/3 > c/3 < coloumns

row=[x1 x1+200 x1+200 x1];%row coordinates > %making rectangle around only kidney stone area 
col=[y1 y1 y1+40 y1+40];%coloumn coordniates

poly_image=roipoly(final_filtered,row,col); %roipoly Select polygonal region of interest.
   % Use roipoly to select a polygonal region of interest within an
  %  image. roipoly returns a binary image that you can use as a mask for
   % masked filtering.
figure;
imshow(poly_image),title('Region of Interest Poly Image');

%apply this poly_image as mask with final filtered image
stone_image=final_filtered.*double(poly_image);
figure;
imshow(stone_image),title('Kidney stone image');

%binary object has more than 4 pixels than only 
final_stone_image=bwareaopen(stone_image,4);
[ya, num]=bwlabel(final_stone_image);
if(num>=1)
    disp('Stone is Detected');
else
    disp('No Stone is detected');
end
