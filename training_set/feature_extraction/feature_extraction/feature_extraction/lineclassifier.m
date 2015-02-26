% this function should give me the no and type of line segments in a given
% input
function [featurevector]=lineclassifier(image)
% input will be a image
% the output will contain a 9 element feature vector whose elements are
% 1. The number of horizontal lines, 2.The total length of horizontal lines,
%3. The number of right diagonal lines,
% 4. The total length of right diagonal lines,
% 5. The number of vertical lines, 6. The total length of
% vertical lines, 7. The number of left diagonal lines, 8. The
% total length of left diagonal lines and 9. The number of
% intersection points

%% you have not considered the condition where direction types can repeat

down=1;         %trying to improve the readability,remember those # define things?:)))
downleft=2;
left=3;
upleft=4;
up=5;
upright=6;
right=7;
downright=8;
previousdirection=0;
currentpixel=[0,0];
nextdirection=0;     %hufff!!!!
image=prep_image(image);
skel_size=length(find(image==1));
if skel_size<=1
    featurevector=-1*ones(1,9);
    return;
end
coordinates=find(image==1);
segments=linesegmenter(image);
N_segments=numel(segments);
segmentdirection={}; %contains the direction vector corresponding to each segment.

%% going to find direction vector corresponding to each segment.
for i=1:N_segments
    currentsegment=segments{i};
    currentdirectionvector=[];
    if size(currentsegment,1)==1
        error('At lineclassifier.m, buddy you have a segment with only one pixel');
    else
        for j=1:(size(currentsegment,1)-1)
            currentpixel=currentsegment(j,:);
            nextpixel=currentsegment(j+1,:);
            nextdirection=finddirection(currentpixel,nextpixel);
            currentdirectionvector=[currentdirectionvector;nextdirection];
        end
    end
    segmentdirection{i}=currentdirectionvector;
end
%%
% ok lets go with this!!!!!!!!!
% IF any ONE of the following conditions is satisfied, commencement of a
% new line will be detected.

% 1. The previous direction was up-right or down-left
% AND the next direction is down-right or up-left OR
% 2. The previous direction is down-right or up-left AND
% the next direction is up-right or down-left OR
% 3. The direction of a line segment has been changed in
% more than three types of direction OR
% 4. The length of the previous direction type is greater
% than three pixels

%The above rules will be applied to every direction vector corresponding to
%every segment.
Truelines={};
N=1;
for i=1:N_segments
    currentdir_segment=segmentdirection{i};
    currentsegment=segments{i};
    %rule 3 has not been implemented
    if numel(currentdir_segment)>2 %in accordance with rule 4
        j=1;
        currentline=[];
        while j<numel(currentdir_segment)
            previousdirection=currentdir_segment(j);
            nextdirection=currentdir_segment(j+1);
            rule_one=(previousdirection==upright | previousdirection==downleft) & (nextdirection==downright | nextdirection==upleft);
            rule_two=(previousdirection==downright | previousdirection==upleft) & (nextdirection==upright | nextdirection==downleft);
            if (rule_one | rule_two)
                Truelines{N}=[currentline;previousdirection;nextdirection];
                N=N+1;
                if j+2>=numel(currentdir_segment)  %checking whether only one pixel remains then it is considered spurious.
                    break;
                else
                    j=j+2;
                end
            else
                currentline=[currentline;currentdir_segment(j)];
                j=j+1;
                if j==numel(currentdir_segment) %if complete line have been scanned,,then it shud be added to list
                    Truelines{N}=[currentline;currentdir_segment(end)];
                    N=N+1;
                    break;
                end
            end
        end
    elseif numel(currentdir_segment)<3
        currentdir_segment(:)=currentdir_segment(1); %assuming the first direction is the entire direction vector.
        %error('buddy, your line segment is less than 3 pixels');
        currentline=currentdir_segment;
        Truelines{N}=currentline;
        N=N+1;
    end
end

%% Line type detection
 % here we will try to find the type of the line.
 N_Truelines=numel(Truelines);
 Normallines={}; %set to hold normalized lines
 N=1;
 % line type normalization
 for i=1:N_Truelines
     currentmaxtype=0;
     currentmaxoccurence=0;
     currentline=Truelines{i};
     currentlength=numel(currentline);
     occurencematrix=[];
     for j=1:8         % to find the number occuring the maximum no.of times
         occurencematrix=[occurencematrix,numel(find(currentline==j))];
     end
     currentmaxoccurence=max(occurencematrix); % finding the max of occurence
     current_max_direction=find(currentmaxoccurence==occurencematrix); %%finding the direction which occurs max
     repetition=numel(current_max_direction)-1;  %%finding whether two directions has occured same no.of times.
     if repetition~=0
%         display('buddy,two directions have occured same no.of times');
     end
     Normallines{N}=current_max_direction(1)*ones(1,currentlength);% in case two dir types occured same no.of times,first dir is taken
     N=N+1;
 end
  % line type detection
N_horizontal=0; % no of horizontal lines.
N_vertical=0;   % no of vertical lines.
N_rightslant=0; % no of right diagonal lines.
N_leftslant=0; %no of left diagonal lines.
L_horizontal=0; % total length of all horizontal lines.
L_vertical=0;   % total length of all vertical lines.
L_rightslant=0; % total length of all right slanting lines.
L_leftslant=0;  % total length of all left slanting lines


N_Normallines=numel(Normallines);
for i=1:N_Normallines
    currentline=Normallines{i};
    firstelement=currentline(1);
    if firstelement==left | firstelement==right
        N_horizontal=N_horizontal+1;
        L_horizontal=L_horizontal+length(currentline);
    elseif firstelement==up | firstelement==down
        N_vertical=N_vertical+1;
        L_vertical=L_vertical+length(currentline);
    elseif firstelement==upleft | firstelement==downright
        N_leftslant=N_leftslant+1;
        L_leftslant=L_leftslant+length(currentline);
    elseif firstelement==upright | firstelement==downleft
        N_rightslant=N_rightslant+1;
        L_rightslant=L_rightslant+length(currentline);
    end
end

window_height=size(image,1);
window_width=size(image,2);

% Normalizing the feature values
% if its no.of lines then it will be normalized as 
% value=1-((no.of lines)/10)*2
V_horizontal=1-((N_horizontal)/10)*2;
V_vertical=  1-((N_vertical)/10)*2;
V_rightslant=1-((N_rightslant)/10)*2;
V_leftslant=1-((N_leftslant)/10)*2;

% length is found using the formula
% length= (total no.of pixels in a particular direction)/(total no.of all
% pixels belonging to skeleton)
if skel_size~=0
    norm_horizontal=L_horizontal/skel_size;
    norm_vertical= L_vertical/skel_size;
    norm_rightslant=L_rightslant/skel_size;
    norm_leftslant=L_leftslant/skel_size;
else
    norm_horizontal=-1;
    norm_vertical=-1;
    norm_rightslant=-1;
    norm_leftslant=-1;
end


% this gives the euler number for the image,its difference between no.of
% objects and no.of holes in a particular image

%this feature gives the proportion of total pixels in the image
filled_area=skel_size/numel(image);

featurevector=[V_horizontal,V_vertical,V_rightslant,V_leftslant,norm_horizontal,norm_vertical,norm_rightslant,norm_leftslant,filled_area];