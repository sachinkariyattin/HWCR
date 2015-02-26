% this func del_pixel(pixel,set) deletes the given pixel from the set;
function modified_set=del_pixel(pixel,set)
i=1;
while i<=size(set,1)
    if(pixel==set(i,:))
        temp1=set(1:i-1,:);
        temp2=set((i+1):end,:);
        set=[temp1;temp2];
        i=1;
    else
        i=i+1;
    end
end
modified_set=set;