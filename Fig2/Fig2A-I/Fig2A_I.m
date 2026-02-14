
%% Read data

fn = 'data_CHO.xlsx';

shts=sheetnames(fn);
dat = {};
ss = [1 2 3];

for s = ss
    tab = table2array(readtable(fn,'Sheet',shts(s),'ReadVariableNames',true,'NumHeaderLines',0,'ReadRowNames',true));

    % remove all rows with only NaN
    tab( all( isnan( tab ), 2 ), : ) = [];
    % remove all columns with only NaN
    tab( :, all( isnan( tab ), 1 ) ) = [];
    
    dat{s} = tab;
end

% Find AUC of data
findAUC;

%% BoxCHART and scatter Humalog

% (1) 4 degC [0 0.4470 0.7410]
% (2) 37 degC+ag 48 hr [0.4660 0.6740 0.1880]
% (3) F/T*3 [0.4940 0.1840 0.5560 ]
% (4) Expired [1 0 1]
% (5) 65 degC 6 hr [1 1 0]
% (6) 65 degC 12 hr [0.8941 0.8157 0.2392]
% (7) 65 degC 24 hr [1 0.6745 0.1098]
% (8) 65 degC 36 hr [0.8500 0.3250 0.0980]
% (9) 65 degC 48 hr [1 0 0]

% Sheet number where Humalog is
num = ss(2);
lgdLoc = 'eastoutside';

matchAll1 = [1 33 27 39 45 52 57 64 72];
matchAll2 = [26 38 32 44 51 56 63 71 77];
colorsAll = [[0    0.4470    0.7410];[0.4940    0.1840    0.5560];...
    [0.4660    0.6740    0.1880];[1 0 1];[1 1 0];[0.8941 0.8157 0.2392];...
    [1 0.6745 0.1098];[0.8500 0.3250 0.0980];...
    [1 0 0]];

lgdTextAll = {['Ideal (','4',char(176),'C)'],['-20',char(176),'C'],['37',char(176),'C + ag.'],['Expired'],['65',char(176),'C 6 hr'],['65',char(176),'C 12 hr'],['65',char(176),'C 24 hr'],['65',char(176),'C 36 hr'],['65',char(176),'C 48 hr']};

[xh,yh,ch] = CHO_scatter(num,matchAll1,matchAll2,colorsAll,lgdTextAll,lgdLoc,dat,"all","all",3);

% #########################################################################

% box charts
CHO_box(num,matchAll1,matchAll2,colorsAll,lgdTextAll,dat,3,0)
CHO_box(num,matchAll1,matchAll2,colorsAll,lgdTextAll,dat,3,1)


%% BoxCHART and scatter Novolog

% (1) 4 degC [0 0.4470 0.7410]
% (2) 37 degC+ag 48 hr [0.4660 0.6740 0.1880]
% (3) F/T*3 [0.4940 0.1840 0.5560]
% (4) Expired [1 0 1]
% (5) 65 degC 6 hr [1 1 0]
% (6) 65 degC 12 hr [0.8941 0.8157 0.2392]
% (7) 65 degC 24 hr [1 0.6745 0.1098]
% (8) 65 degC 36 hr [0.8500 0.3250 0.0980]
% (9) 65 degC 48 hr [1 0 0]

num = ss(1);
lgdLoc = 'eastoutside';

matchAll1 = [1 33 28 38 42 48 54 60 68];
matchAll2 = [27 37 32 41 47 53 59 67 71];

matchRemove1 = [4 30 35 38 45 48 54 60 70];
matchRemove2 = [27 32 37 41 47 53 59 67 71];

colorsAll = [[0    0.4470    0.7410];[0.4940    0.1840    0.5560 ];...
    [0.4660    0.6740    0.1880];[1 0 1];[1 1 0];[0.8941 0.8157 0.2392];...
    [1 0.6745 0.1098];[0.8500 0.3250 0.0980];...
    [1 0 0]];

lgdTextAll = {['Ideal (','4',char(176),'C)'],['-20',char(176),'C'],['37',char(176),'C + ag.'],['Expired'],['65',char(176),'C 6 hr'],['65',char(176),'C 12 hr'],['65',char(176),'C 24 hr'],['65',char(176),'C 36 hr'],['65',char(176),'C 48 hr']};

[xn,yn,cn] = CHO_scatter(num,matchAll1,matchAll2,colorsAll,lgdTextAll,lgdLoc,dat,"all","all",2);

% #########################################################################

% box charts
CHO_box(num,matchAll1,matchAll2,colorsAll,lgdTextAll,dat,2,0)
CHO_box(num,matchAll1,matchAll2,colorsAll,lgdTextAll,dat,2,1)

%% Control: no first plate for scatter
CHO_scatter(num,matchRemove1,matchRemove2,colorsAll,lgdTextAll,lgdLoc,dat,"all","all",2);

%% BoxCHART and scatter Basaglar

% (1) 4 degC [0 0.4470 0.7410]
% (2) F/T*3 [0.4940 0.1840 0.5560]
% (3) 65 degC 48 hr [1 0 0]
% (4) Expired [1 0 1]
% (5) 37 degC+ag 72 hr [0.4660 0.6740 0.1880]*1.4
% (6) 37 degC+ag 84 hr [0.4660 0.6740 0.1880]
% (7) 37 degC+ag 96 hr [0.4660 0.6740 0.1880]/1.5
% (8) 37 degC+ag 168 hr [0.4660 0.6740 0.1880]/3

num = ss(3);
lgdLoc = 'eastoutside';

matchAll1 = [1 14 18 24 30 34 40 51];
matchAll2 = [13 17 23 29 33 39 50 54];

colorsAll = [[0    0.4470    0.7410];[0.4940 0.1840 0.5560];...
   [1 0 0];[1 0 1];[0 1 0];[0.4660    0.6740    0.1880]*1.4;...
   [0.4660    0.6740    0.1880];[0.4660    0.6740    0.1880]/3];

lgdTextAll = {['Ideal (','4',char(176),'C)'],['-20',char(176),'C'],['65',char(176),'C 48 hr'],'Expired',['37',char(176),'C + ag. 3 days'],['37',char(176),'C + ag. 3.5 days'],['37',char(176),'C + ag. 4 days'],['37',char(176),'C + ag. 7 days']};

[xb,yb,cb] = CHO_scatter(num,matchAll1,matchAll2,colorsAll,lgdTextAll,lgdLoc,dat,"all","all",1);

% #########################################################################

% box charts
CHO_box(num,matchAll1,matchAll2,colorsAll,lgdTextAll,dat,1,0)
CHO_box(num,matchAll1,matchAll2,colorsAll,lgdTextAll,dat,1,1)

%% Curve export for CD plot
choFit = [xb' xh' xn' yb' yh' yn'];
coeff = [cb,ch,cn];
save('coeff_choFit.mat', 'choFit', 'coeff');