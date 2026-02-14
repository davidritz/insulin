%% Put each cropped dot blot pic into one pic
parFile = {'bas','huma','novo'};

% blank image (7 columns, 15 rows)
mult = 31;
step = floor(mult/2);
db = zeros(15*mult,7*mult);

% Basaglar blots only in 2 pics, not necessarily in order
orderBas = [3;6;2;5;0;1;4];
picsBas = [3 4];

% x, y coord of dots below. Will crop around dot and put into 1 pic

% Basaglar
x(:,:,1) = [...
    232,235,242,141,68;...
    494,495,485,425,351;...
    765,765,760,682,610;...
    207,209,211,142,58;...
    288,292,300,385,485;...
    824,825,824,729,623;...
    645,524,757,402,403;...
    ];

y(:,:,1) = [...
    344,216,458,116,116;...
    355,242,459,125,131;...
    540,540,630,288,280;...
    365,250,453,122,124;...
    203,320,80,449,438;...
    369,254,469,129,118;...
    579,575,577,666,763;...
    ];

% Humalog
x(:,:,2) = [...
    215,220,210,219,125;...
    228,215,225,205,130;...
    760,760,760,682,603;...
    200,308,65,409,387;...
    323,215,426,74,76;...
    295,297,304,70,60;...
    170,257,56,414,419;...
    ];

y(:,:,2) = [...
    279,43,395,157,164;...
    263,150,395,45,47;...
    197,137,373,71,66;...
    208,214,202,205,116;...
    245,243,243,243,149;...
    284,175,420,399,273;...
    250,240,246,241,143;...
    ];

% Novolog
x(:,:,3) = [...
    267,270,275,177,74;...
    224,224,226,235,130;...
    201,186,186,193,120;...
    204,202,211,215,118;...
    242,242,240,240,166;...
    325,296,313,30,70;...
    219,209,201,193,112;...
    ];

y(:,:,3) = [...
    330,235,142,41,51;...
    304,212,109,26,26;...
    312,238,160,63,67;...
    302,206,100,16,24;...
    273,195,134,49,52;...
    283,72,133,63,34;...
    321,255,172,78,93;...
    ];

% looping variable
row=0;
baseFolder=pwd;
for i = 1:size(parFile,2)

    % cd into directory and order files by alphabetical order
    cd([baseFolder,'\',parFile{i}])
    parDir = dir;
    [~,ind]=sort({parDir.name});
    parDir = parDir(ind);
    
    % Remove any blank files from dir variable
    blank = 0;
    for fov=1:size(parDir,1)
        fov = fov-blank;
        if parDir(fov).bytes == 0
            parDir(fov) = [];
            blank=blank+1;
        end
    end

    for pic=1:size(parDir,1)
        fname = [parFile{i},'\',parDir(pic).name];
        info = imfinfo(fname);
      
        % minus 0.5 from everything and change to white background, black dot
        currentImg = imcomplement(imread(fname,'Info', info)-0.5);

        % output image for supplemental
        % figure;
        % f = imshow(currentImg);
        % imwrite(f.CData,[baseFolder '\supplemental\' 'supp_' parFile{i} '_' parDir(pic).name(1:end-4) '.png'],'png')
        
        % 3 blots in pic 1, 4 blots in pic 2
        if strcmp(parFile{i},'bas')
            if pic == 1
                for p = 1:picsBas(i)
                    for dot = 1:5
                        xMid = (step+1)+orderBas(p)*mult;
                        yMid = (step+1)+(dot-1)*mult;
                        db(yMid-step:yMid+step,xMid-step:xMid+step) = currentImg(y(p,dot,i)-step:y(p,dot,i)+step,x(p,dot,i)-step:x(p,dot,i)+step);
                    end
                end
            else
                for p = picsBas(pic):7
                    for dot = 1:5
                        xMid = (step+1)+orderBas(p)*mult;
                        yMid = (step+1)+(dot-1)*mult;
                        db(yMid-step:yMid+step,xMid-step:xMid+step) = currentImg(y(p,dot,i)-step:y(p,dot,i)+step,x(p,dot,i)-step:x(p,dot,i)+step);
                    end
                end
            end
        % Humalog and Novolog have 1 blot per pic
        else
            for dot = 1:5
                xMid = (step+1)+(pic-1)*mult;
                yMid = (step+1)+(dot+row-1)*mult;

                % don't override N exp mOC87 from H mOC87 blot
                if i == 3 && pic == 6 && dot == 2  
                else
                    db(yMid-step:yMid+step,xMid-step:xMid+step) = currentImg(y(pic,dot,i)-step:y(pic,dot,i)+step,x(pic,dot,i)-step:x(pic,dot,i)+step);
                end
            end
        end
        
        % N exp mOC87 (2nd last, exp on H mOC87 blot)
        if i == 2 && pic == 6
            xMid = (step+1)+(pic-1)*mult;
            yMid = (step+1)+(2+10-1)*mult;
            db(yMid-step:yMid+step,xMid-step:xMid+step) = currentImg(y(pic,2,3)-step:y(pic,2,3)+step,x(pic,2,3)-step:x(pic,2,3)+step);
        end


    end
    row = row+5;
end

cd(baseFolder)
figure;
imshow(db)

% high quality output of open figure
iptsetpref('ImshowBorder','tight');
set(gcf, 'Position', get(0, 'Screensize'));
%export_fig dotblot.tif -m2.5 -q101;
