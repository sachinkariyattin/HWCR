function [discoursed]=discourser(image);
currentimage=image;
[row,column]=size(currentimage);
for j=1:row
    currentrow=currentimage(j,:);
    temp=find(currentrow==1);
    if isempty(temp)
        continue;
    else
        uppermost=j;
        break;
    end
end
for j=1:column
    currentcolumn=currentimage(:,j);
    temp=find(currentcolumn==1);
    if isempty(temp)
        continue;
    else
        leftmost=j;
        break;
    end
end
for j=column:-1:1
    currentcolumn=currentimage(:,j);
    temp=find(currentcolumn==1);
    if isempty(temp)
        continue;
    else
        rightmost=j;
        break;
    end
end
for j=row:-1:1
    currentrow=currentimage(j,:);
    temp=find(currentrow==1);
    if isempty(temp)
        continue;
    else
        lowermost=j;
        break;
    end
end
discoursed=currentimage(uppermost:lowermost,leftmost:rightmost);
end
