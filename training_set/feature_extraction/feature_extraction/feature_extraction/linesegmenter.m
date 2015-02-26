% This file should help me in distinguishing individual line segments


% The work in this code is based on a paper 'A novel feature extraction
% technique for the recognition of segmented handwritten characters' by
% Blumenstein, Verma and H.Basli. ( See section 2.3.2)
%% features to be added
% currently if there are no starters in a input image, the code would not
% work.(for eg , the letter 'O' would be in trouble.
%% The function starts here
function [segments]=linesegmenter(image)
% before segmenting image, it has to be skeletonized and spurious pixels
% have to be removed. function prep_image works on that.
[starters,intersections]=starter_intersection(image);
% starters and intersections contain row column coordinates
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


% i am going to add a border of zeros on all 4 sides of the orginal image
image=[image,zeros(size(image,1),1)];  % appending zeros on right border
image=[zeros(1,size(image,2));image];% appending zeros on top border
image=[zeros(size(image,1),1),image];  % appending zeros on left border
image=[image;zeros(1,size(image,2))];% appending zeros on bottom border
%Now the co-ordinates of the orginal pixel have changed, i have to bring
%this change in the starters and intersections also
minor_starters_queue=[];
starters = starters + 1;
intersections = intersections + 1;
if isempty(starters) % think about a perfect D
    [r,c]=find(image==1);
    coordinates=[r,c];
    starter1=coordinates(1,:);
    starter2=coordinates(end,:);
    minor_starters_queue=[starter1;starter2];
end
% so that a neighberhood could be defined for
N=1;  % supposed to contain No of segments.
segments={}; %the cell supposed to contain individual segments
starters_queue=starters; 
visited=[];              %set of all pixels that have been visited.
%for i=1:size(starters_queue,1)
skel_size=numel(find(image==1)); % gives the no.of pixels with value as one
%% This is the main loop, it would keep running until all starters are
% dealt with or minor starters are dealt with or entire skeleton has been visited.
while(isnotempty(starters_queue) | isnotempty(minor_starters_queue))% | size(visited,1)<skel_size)BE SERIOUS ABOUT THESE
    currentsegment=[];% supposed to contain the current segments pixel list
    %% This portion of code deals with normal starters_queue members
    if isnotempty(starters_queue)
        if isnotmember(starters_queue(1,:),visited)
            current_starter=starters_queue(1,:);
            starters_queue=del_pixel(current_starter,starters_queue);
            currentpixel=findneighbours(image,current_starter);
            visited=[visited;current_starter];
            currentsegment=[currentsegment;current_starter];
            nextdirection=finddirection(current_starter,currentpixel);
            previousdirection=nextdirection; %this portions are initialization parts and it happens at the pixel next to starter
            %findneighbours() is a function to find neighbours of the current pixel
        else
            starters_queue=del_pixel(starters_queue(1,:),starters_queue);
            continue; %if the starter has been dealt with... there is no point in running remaining code, so we have to go for next starter
            % so the control should pass to while.
        end

        %%  This portion of code TRIES(!!!) to deal with minor starters
    elseif (isempty(starters_queue) & isnotempty(minor_starters_queue))
        currentminor=minor_starters_queue(1,:);
        currentsegment=[];
        if ismymember(currentminor,visited) % remember the case of second intersection in skeletonized 'A'.
            minor_starters_queue=del_pixel(currentminor,minor_starters_queue);
            continue;
        end
        visited=[visited;currentminor]; % adding currentminor to visited set
        neighbours=findneighbours(image,currentminor); % finding neighbours of current minor
        temp=1;
        while temp<=size(neighbours,1) %deleting visited neighbours from current minors neighbours list
            current_neighbour=neighbours(temp,:);
            if (ismymember(current_neighbour,visited) | ismymember(current_neighbour,minor_starters_queue))
                neighbours=del_pixel(current_neighbour,neighbours);
                temp=1;
            else
                temp=temp+1;
            end
        end
        unvisited_neighbours=neighbours;
        if size(unvisited_neighbours,1)>2
            minor_starters_queue=del_pixel(currentminor,minor_starters_queue);
            continue;
            %error('buddy,your current minor have more than two unvisited neighbours');
        end
        if size(unvisited_neighbours,1)==2
            discarded=unvisited_neighbours(1,:);
            currentpixel=unvisited_neighbours(2,:);
            currentsegment=[currentsegment;currentminor];
            minor_starters_queue=[minor_starters_queue;discarded];
        elseif isempty(unvisited_neighbours)
            minor_starters_queue=del_pixel(currentminor,minor_starters_queue);
            continue;
        elseif size(unvisited_neighbours,1)==1
            currentpixel=unvisited_neighbours;
            currentsegment=[currentsegment;currentminor];
            unvisited_neighbours=[];
        end
    end
    %% This line of code process the currentpixel
    while(isnotmember(currentpixel,visited))
        %% the point of this cell is to find next pixel if current pixel is neither
        % intersection nor starter  nor minor
        if(isnotmember(currentpixel,intersections) & isnotmember(currentpixel,starters_queue)) %isnotmember() func cheks if currentpixel is in intersections,it also implies that current pixel has only two neighbour
           
            neighbours=findneighbours(image,currentpixel);
            visited=[visited;currentpixel];
            %% going to delete visited pixels as well as starters from neighbours and find the
            %next pixel
            temp=1;
            while temp<=size(neighbours,1)
                current_neighbour=neighbours(temp,:);
                if (ismymember(current_neighbour,visited))
                    neighbours=del_pixel(current_neighbour,neighbours);
                    temp=1;
                else
                    temp=temp+1;
                end
            end
            % the next if portion removes all the minor starters in the
            % neighbours list.
            if size(neighbours,1)>2 %this happens in situation if one of the neighbours is a minor starter.
                temp=1;
                while temp<=size(neighbours,1)
                    current_neighbour=neighbours(temp,:);
                    if (ismymember(current_neighbour,minor_starters_queue))
                        neighbours=del_pixel(current_neighbour,neighbours);
                        temp=1;
                    else
                        temp=temp+1;
                    end
                end
            end
            if isempty(neighbours)  %see bottom section for explanation
                currentsegment=[currentsegment;currentpixel];
                segments{N}=currentsegment;
                N=N+1;
                break;
            end
            if size(neighbours,1)==1
                nextpixel=neighbours;
            elseif size(neighbours,1)==2 % remember that you have removed all visited neighbours.so this two are unvisited. From this, one of them will be
                first_neighbour=neighbours(1,:);
                second_neighbour=neighbours(2,:);
                % a situation can occur where one of the neighbours is a
                % intersection. so lets stop the segment here if it is
                % so,till this pixel and consider  pixel other than intersection as a
                % minor.else continue
                if ismymember(first_neighbour,intersections)|ismymember(second_neighbour,intersections)
                    currentsegment=[currentsegment;currentpixel];
                    if ismymember(first_neighbour,intersections)
                        currentsegment=[currentsegment;first_neighbour];
                        segments{N}=currentsegment;
                        N=N+1;
                        visited=[visited;first_neighbour];
                        minor_starters_queue=[minor_starters_queue;second_neighbour];
                    else
                        currentsegment=[currentsegment;second_neighbour];
                        segments{N}=currentsegment;
                        N=N+1;
                        visited=[visited;second_neighbour];
                        minor_starters_queue=[minor_starters_queue;first_neighbour];
                    end
                    minor_starters_queue=[minor_starters_queue;first_neighbour;second_neighbour];
                    break;
                end
                neighbour_one_direction=finddirection(currentpixel,first_neighbour);
                neighbour_two_direction=finddirection(currentpixel,second_neighbour);
                if(neighbour_one_direction==previousdirection)
                    neighbours=del_pixel(second_neighbour,neighbours);
                    nextpixel=neighbours;
                    previousdirection=neighbour_one_direction;
                else
                    neighbours=del_pixel(first_neighbour,neighbours);
                    nextpixel=neighbours;
                    previousdirection=neighbour_two_direction;
                end
            elseif size(neighbours,1)>2
                %since there are more than 2 neighbours there are very high
                %chances that one of them will be a intersection. so we
                %have to find that intersection and end the segment here.
                %else if a minor starter exists,its enough to consider it
                %as endpoint.
                %display('hi, you have more than two unvisited neighbours');
                unconsidered=neighbours;
                for i=1:size(neighbours,1)
                    current_neighbour=neighbours(i,:);
                    if ismymember(current_neighbour,intersections)
                        unconsidered=del_pixel(current_neighbour,unconsidered);
                        visited=[visited;current_neighbour];
                        currentsegment=[currentsegment;current_neighbour];
                        segments{N}=currentsegment;
                        N=N+1;
                        currentsegment=[];
                        break;
                    end
                end
                % after this for loop all pixels other than intersection
                % will be in unconsidered.so all of them should be added to
                % minor_starters_queue.another prob is if there are more
                % than two intersections who are neighbours,then only one
                % of them will be considered.
                minor_starters_queue=[minor_starters_queue;unconsidered];
                break;
            end
            currentsegment=[currentsegment;currentpixel];
            previousdirection=finddirection(currentpixel,nextpixel);
            previouspixel=currentpixel; % sometimes,this might help
            currentpixel=nextpixel;  % moving on to next pixel
            %% point of this section is to deal with situation when current pixel is a intersection
        elseif (ismymember(currentpixel,intersections)) %implies that it have more than two neigbhours
            visited=[visited;currentpixel];
            neighbours=findneighbours(image,currentpixel);
            unvisited_neighbours=[]; %to hold unvisited neighbours
            for i=1:size(neighbours,1)
                if isnotmember(neighbours(i,:),visited)
                    unvisited_neighbours=[unvisited_neighbours;neighbours(i,:)];
                end
            end
            unvisited_directions=[];
            direction_flag=0; % this is a flag to chek whether the current traversal direction is preserved.
            for i=1:size(unvisited_neighbours,1)
                current_neighbour=unvisited_neighbours(i,:);
                current_neighbour_direction=finddirection(currentpixel,current_neighbour);
                if current_neighbour_direction==previousdirection
                    direction_flag=1;
                    currentsegment=[currentsegment;currentpixel];
                    previouspixel=currentpixel;
                    currentpixel=current_neighbour;
                    unvisited_neighbours=del_pixel(current_neighbour,unvisited_neighbours);
                    minor_starters_queue=[minor_starters_queue;unvisited_neighbours];
                    unvisited_neighbours=[];
                    break;
                end
                % a situation might occur where none of neighbouring pixels
                % is in the current traversal direction. Then all of them
                % should be added to minor_starters_queue. See bottom
                % section for an example.if the break here happens,it means
                % one of the pixel was in current traversal direction,else
                % after this for loop,all of them should be added to st
            end
            if direction_flag==0
                minor_starters_queue=[minor_starters_queue;unvisited_neighbours];
                currentsegment=[currentsegment;currentpixel];
                segments{N}=currentsegment;
                N=N+1;
            end
            
            %% point of this section is deal with situation when current pixel is a starter
        elseif (ismymember(currentpixel,starters_queue))
            currentsegment=[currentsegment;currentpixel];
            starters_queue=del_pixel(currentpixel,starters_queue);
            visited=[visited;currentpixel];
            segments{N}=currentsegment;
            N=N+1;
            %% point of this section is to deal with situation when current pixel is a
            % minor
        elseif (ismymember(currentpixel,minor_starters_queue))
            currentsegment=[currentsegment;currentpixel];
            minor_starters_queue=del_pixel(currentpixel,minor_starters_queue);
            visited=[visited;currentpixel];
            segments{N}=currentsegment;
            N=N+1;
        end
    end
end

% now all the segments is shifted to their orginal position because by
% adding border of zeros, every (x,y) point was shifted to (x+1,y+1)
for i=1:(N-1)
    segments{i}=segments{i}-1;
end
save debug.mat
% [1 1 1 1
%  0 1 0 0]
% in this case, the traversal will start from (1,4) and when it reaches (1,2), there is two neighbours
% (1,1) and (2,2), since the current direction of traversal is in (1,1), (2,2) is added to starters_list
% now (1,1) is the current pixel, from the perspective of that, neighbours are (1,2) and (2,2), but (1,2) is already
% visited and (2,2) cant be visited
% cpr=currentpixel(1);cpc=currentpixel(2);% cpr is current pixel row and
% cpc is current pixel column
% [1 0 1
%  0 1 0
%  0 1 0]
% in this case whatever be the starting pixel, at central pixel, the direction of traversal is not preserved.
