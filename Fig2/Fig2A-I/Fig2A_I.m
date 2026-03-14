%% Read data

fn = 'cho_bioreps.xlsx';

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


% Sheet number where Humalog is
num = ss(2);
lgdLoc = 'eastoutside';

matchAll1 = [1 33 27 38 43 50 55 61 67];
matchAll2 = [26 37 32 42 49 54 60 66 72];
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


num = ss(1);
lgdLoc = 'eastoutside';

matchAll1 = [1 33 28 38 41 47 53 59 65];
matchAll2 = [27 37 32 40 46 52 58 64 68];

matchRemove1 = [4 35 30 38 44 47 53 59 67];
matchRemove2 = [27 37 32 40 46 52 58 64 68];

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

num = ss(3);
lgdLoc = 'eastoutside';

matchAll1 = [1 14 18 21 24 28 30 37];
matchAll2 = [13 17 20 23 27 29 36 40];

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