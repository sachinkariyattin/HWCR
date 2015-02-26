

x=feature_extractor(~im2bw(b22));

fid = fopen('imageresize.txt','a');
x=x';
fprintf(fid,'%6.2f \n',x);
fclose(fid);
