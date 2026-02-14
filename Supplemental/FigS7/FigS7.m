%% Read data

load data

%% Enter Novolog data
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


%% Control: no first plate for scatter
CHO_scatter(num,matchRemove1,matchRemove2,colorsAll,lgdTextAll,lgdLoc,dat,"all","all",2);

%% control: box chart showing background of first plate vs all other plates'
findAUC;
