% this function will be taking a image and the co-ordinates of the central pixel will be given.
% It should return co-ordinates of all the neighbours of the central pixel
% with value as 1.
function [neighbours]=findneighbours(image,coords)
imwindow=image((coords(1)-1):(coords(1)+1),(coords(2)-1):(coords(2)+1));
neighbours=[];
imwindow(2,2)=0; %% the reason should be obvious!!!!!!!!!
indexes=find(imwindow==1);
for i=1:length(indexes)
    currentindex=indexes(i);
    row=rem(currentindex,3);
    if(row==0)
        row=3; %rem(currentindex,3) will be zero if its in 3rd row
    end
    column=ceil(currentindex/3);
    neighbours=[neighbours;[row,column]];
end
 neighbours(:,1)=coords(1)+(neighbours(:,1)-2); % the center pixel is (2,2), 'neighbours-2' implies center becomes (0,0)..rest,u figure out!!!
 neighbours(:,2)=coords(2)+(neighbours(:,2)-2);