% This function tests whether pixel is in the given set
function result=isnotmember(pixel,set)
result=1;
for i=1:size(set,1)
    if pixel==set(i,:)
        result=0;
        break;
    end
end