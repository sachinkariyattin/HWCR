function [features]=feature_extract(image);

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

zone_height=row/3;
zone_width=column/3;
%say at this point image is 12x9, so no.of rows in each zone should be
%12/3=4, whereas columns should be 9/3=3. This is stored in variables zone
%height and width
zone11=image(1:zone_height,1:zone_width);
zone12=image(1:zone_height,(zone_width+1):2*zone_width);
zone13=image(1:zone_height,(2*zone_width+1):end);

zone21=image((zone_height+1):2*zone_height,1:zone_width);
zone22=image((zone_height+1):2*zone_height,(zone_width+1):2*zone_width);
zone23=image((zone_height+1):2*zone_height,(2*zone_width+1):end);

zone31=image((2*zone_height+1):end,1:zone_width);
zone32=image((2*zone_height+1):end,(zone_width+1):2*zone_width);
zone33=image((2*zone_height+1):end,(2*zone_width+1):end);

% feature_vectors
zone11_features=line_classifier(zone11);
zone12_features=line_classifier(zone12);
zone13_features=line_classifier(zone13);

zone21_features=line_classifier(zone21);
zone22_features=line_classifier(zone22);
zone23_features=line_classifier(zone23);

zone31_features=line_classifier(zone31);
zone32_features=line_classifier(zone32);
zone33_features=line_classifier(zone33);

% this is a feature called euler no...euler no. is diff between no.of
% objects and holes in that image
euler=bweuler(image);


features=[zone11_features;zone12_features;zone13_features;zone21_features;zone22_features;zone23_features;zone31_features;zone32_features;zone33_features];

%stats=regionprops(bwlabel(image),'all');

%skel_size=numel(image);

%convexarea=(stats.ConvexArea)/skel_size;

%eccentricity=stats.Eccentricity;

%extent=stats.Extent;

%filledarea=(stats.FilledArea)/skel_size;

%majoraxislength=(stats.MajorAxisLength)/skel_size;

%minoraxislength=(stats.MinorAxisLength)/skel_size;

%orientation =stats.Orientation;

% this are the regional features
%regional_features=[eccentricity;extent;orientation];

%features=[features;regional_features];   

