function [prepared]=prep_image(image)
original=image; % backing up the original image

% later code to skeletonize the image and such things have to be added to
% this function. currently this function removes the spurious pixels in the
% image like singly standing pixels without any connections

%removing the spurious pixels
[labeled,N_obj]=bwlabel(image);
for i=1:N_obj
    N_currentobj=numel(find(labeled==i));
    if N_currentobj==1
        labeled(find(labeled==i))=0;
    end
end
non_zero=find(labeled~=0);
labeled(non_zero)=1;
prepared=labeled;