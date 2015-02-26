function [featurevector]=line_classifier(image)

row=size(image,1);
column=size(image,2);

[Gmag, Gdir]=imgradient(image);
code0=0;
code1=0;
code2=0;
code3=0;
code3=0;
code4=0;
code5=0;
code6=0;
code7=0;
code8=0;
code9=0;
code10=0;
code11=0;

for r = 1:row
    for c = 1:column
        if Gdir(r,c) >= 0 && Gdir(r,c) < 30
           Code(r,c) = 0;
           code0=code0+1;
        elseif Gdir(r,c) >= 30 && Gdir(r,c) < 60
                Code(r,c) = 1;
                code1=code1+1;
        elseif Gdir(r,c) >= 60 && Gdir(r,c) < 90
                Code(r,c) = 2;
                code2=code2+1;
        elseif Gdir(r,c) >= 90 && Gdir(r,c) < 120
                Code(r,c) = 3;
                code3=code3+1;
        elseif Gdir(r,c) >= 120 && Gdir(r,c) < 150
                Code(r,c) = 4;
                code4=code4+1;
        elseif Gdir(r,c) >= 150 && Gdir(r,c) <180
                Code(r,c) = 5;
                code5=code5+1;
        elseif Gdir(r,c) >= -180 && Gdir(r,c) < -150
                Code(r,c) = 6;
                code6=code6+1;
        elseif Gdir(r,c) >= -150 && Gdir(r,c) < -120
                Code(r,c) = 7;
                code7=code7+1;
        elseif Gdir(r,c) >= -120 && Gdir(r,c) < -90
                Code(r,c) = 8;
                code8=code8+1;
        elseif Gdir(r,c) >= -90 && Gdir(r,c) < -60
                Code(r,c) = 9;
                code9=code9+1;
        elseif Gdir(r,c) >= -60 && Gdir(r,c) < -30
                Code(r,c) = 10;
                code10=code10+1;
        elseif Gdir(r,c) >= -30 && Gdir(r,c) < 0
                Code(r,c) = 11;
                code11=code11+1;
        end        
    end
end

featurevector=[code0;code1;code2;code3;code4;code5;code6;code7;code8;code9;code10;code11]