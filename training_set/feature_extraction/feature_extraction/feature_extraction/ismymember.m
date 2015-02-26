% func ismymember() cheks whether pixel is a element of given set
% chek doc for isnotmember for more info
function result=ismymember(pixel,set);
if isnotmember(pixel,set)
    result=0;
else
    result=1;
end