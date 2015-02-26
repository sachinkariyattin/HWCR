% this function is supposed to extract features from the input image
%% this function divides the image into 1x3 zone and then extracts the
%% features then it divides into 3x1 zone and then extracts the features
function [features]=feature_extractor_2d(image);
% this function zones the input image
% and extracts features for each zone.



%% preprocessing of image


if length(size(image))>2 % checking if rgb image;
    image=rgb2gray(image);
    image=im2bw(image,graythresh(image));
end    
% by now image should be binary    
% skeletonizing image
image=bwmorph(image,'skel',inf);

%selecting the universe of discourse
image=discourser(image);

original_image=image;% just backing up the orginal image
row=size(image,1);
column=size(image,2);
% we have to ceil this no.s to the nearest multiple of 3 since
% 3x3 windowing is used

% first we have to ensure that image consists of minimum 9 rows and minimum
% 9 columns
add_rows=0; %no of additional rows to make min of 9x9 matrix
add_columns=0; % similar for columns
if row<9
    add_rows=9-row;
end
if column<9
    add_columns=9-column;
end

if mod(add_rows,2)==0
    image=[zeros(add_rows/2,column);image;zeros(add_rows/2,column)];
else
    image=[zeros((add_rows-1)/2,column);image;zeros((add_rows+1)/2,column)];
end
%appending rows of zeros
%after above op, no.of rows changes so it should be updated
%equal no of rows should be added on top and bottom
row=size(image,1);
if mod(add_columns,2)==0
    image=[zeros(row,(add_columns)/2),image,zeros(row,(add_columns)/2)];
else
    image=[zeros(row,(add_columns-1)/2),image,zeros(row,(add_columns+1)/2)];
end
column=size(image,2); %updating the column value


n_rows=ceil(row/3)*3-row; % no of rows of zeros to be added
n_columns=ceil(column/3)*3-column; % no of columns of zeros to be added
% assume row=4, so 2 rows of zeros should be added. ceil(4/3)*3 will return
% 6 which is nearest multiple of 3 to 4 from right side. So n_rows will
% contain no.of rows to be added to the image.

if mod(n_rows,2)==0
    image=[zeros(n_rows/2,column);image;zeros(n_rows/2,column)];
else
    image=[zeros((n_rows-1)/2,column);image;zeros((n_rows+1)/2,column)];
end
%appending rows of zeros
%after above op, no.of rows changes so it should be updated
%equal no of rows should be added on top and bottom
row=size(image,1);
if mod(n_columns,2)==0
    image=[zeros(row,(n_columns)/2),image,zeros(row,(n_columns)/2)];
else
    image=[zeros(row,(n_columns-1)/2),image,zeros(row,(n_columns+1)/2)];
end
column=size(image,2); %updating the column value
% so now the image can be divided into 3x3 zones
% here in above code some more features are to be added, like if two rows
% of zeros are to be added then one on either side of the image and
% similarily for columns.

column_zone_height=row;
column_zone_width=column/3;
%say at this point image is 12x9, so no.of rows in each column zone should be
%12, whereas columns should be 9/3=3. This is stored in variables zone
%height and width
column_zone1=image(1:column_zone_height,1:column_zone_width);
column_zone2=image(1:column_zone_height,(column_zone_width+1):2*column_zone_width);
column_zone3=image(1:column_zone_height,(2*column_zone_width+1):end);

row_zone_height=row/3;
row_zone_width=column;

row_zone1=image(1:row_zone_height,1:row_zone_width);
row_zone2=image((row_zone_height+1):2*row_zone_height,1:row_zone_width);
row_zone3=image((2*row_zone_height+1):end,1:row_zone_width);


% feature_vectors
column_zone1_features=lineclassifier(column_zone1);
column_zone2_features=lineclassifier(column_zone2);
column_zone3_features=lineclassifier(column_zone3);

row_zone1_features=lineclassifier(row_zone1);
row_zone2_features=lineclassifier(row_zone2);
row_zone3_features=lineclassifier(row_zone3);


% this is a feature called euler no...euler no. is diff between no.of
% objects and holes in that image
euler=bweuler(image);
features=[column_zone1_features;column_zone2_features;column_zone3_features;row_zone1_features;row_zone2_features;row_zone3_features];
features=[reshape(features',numel(features),1);euler];

% here the region properties of the image are going to be considered
stats=regionprops(bwlabel(image),'all');

skel_size=numel(image);

%convexarea=(stats.ConvexArea)/skel_size;

eccentricity=stats.Eccentricity;

extent=stats.Extent;

%filledarea=(stats.FilledArea)/skel_size;

%majoraxislength=(stats.MajorAxisLength)/skel_size;

%minoraxislength=(stats.MinorAxisLength)/skel_size;

orientation =stats.Orientation;

% this are the regional features
regional_features=[eccentricity;extent;orientation];

% now the previous geometric and this regional features have to be combined
%features=[features;regional_features];


