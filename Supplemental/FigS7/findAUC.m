function findAUC
%% Read data and find AUC

fn = 'AUC.xlsx';

shts=sheetnames(fn);
dat = {};
AUC = {};
back1 = {};
back2 = {};
norm1 = {};
norm2 = {};
ss = [1 2 3];

% blank location for each plate per insulin
back1{1} = [73 73 75 78 81 84 87 90 92];
back2{1} = [74 74 77 80 83 86 89 91 93];

back1{2} = [79 81 84 87 90 93 96 99 101];
back2{2} = [80 83 86 89 92 95 98 100 102];

back1{3} = [56 59 62 64 67];
back2{3} = [58 61 63 66 69];

% unaltered insulin location for each plate per insulin
norm1{1} = [1 4 7 10 13 16 19 22 25];
norm2{1} = [3 6 9 12 15 18 21 24 27];

norm1{2} = [1 3 6 9 12 15 18 21 24];
norm2{2} = [2 5 8 11 14 17 20 23 26];

norm1{3} = [1 3 6 8 11];
norm2{3} = [2 5 7 10 13];

% Read each Excel sheet
for s = ss
    tab = table2array(readtable(fn,'Sheet',shts(s)));
    loop=1;

    % Normalize secondary ab flu by Hoechst stain flu
    for row = 1:2:size(tab,1)-2
        dat{s}(loop,:) = tab(row,:)./tab(row+1,:);
        loop=loop+1;
    end
    
    % Find area under curve for each column of data
    AUC{s} = trapz(dat{s},1);

    % Control novolog graph for different background subtraction
    if s == 1
        figure;
        b=boxchart(AUC{s}(75:end));
        b.BoxFaceColor = [0.8 0.8 0.8];
        b.BoxFaceAlpha = 0.4;
        b.BoxEdgeColor = [0 0 0];
        b.LineWidth = 3;
        randX1 = 0.8 + (1.2-0.8).*rand(size(AUC{s},2)-74,1);
        randX2 = 0.8 + (1.2-0.8).*rand(2,1);
        hold on
        scatter(randX1,AUC{s}(75:end),250,'filled','MarkerFaceColor',[0.5 0.5 0.5],'MarkerEdgeColor',[0 0 0])
        scatter(randX2,AUC{s}(73:74),250,'filled','MarkerFaceColor',[1 0 0],'MarkerEdgeColor',[0 0 0])
        ylabel('Fluorescence AUC')
        xlabel('')
        xticks('')
        set(findall(gcf,'-property','FontSize'),'FontSize',30)
        set(gcf,'Position',[4 59 1530 500])
        %export_fig novo_background.tif -m2.5 -q101;
    end

    % CHO plate numbers used for this insulin type
    if s == 3
        colPlate = 5;
    else
        colPlate = 7;
    end
    platesUsed = unique(tab(colPlate,:));
    platesUsed = platesUsed(~isnan(platesUsed));

    loop=1;
    for plate = platesUsed

        % Minus plate background (TBS)
        AUC{s}(:,find(tab(colPlate,:)==plate)) = AUC{s}(:,find(tab(colPlate,:)==plate)) - mean(AUC{s}(back1{s}(loop):back2{s}(loop)));

        % Normalize to unaltered insulin bioactivity
        AUC{s}(:,find(tab(colPlate,:)==plate)) = AUC{s}(:,find(tab(colPlate,:)==plate))/mean(AUC{s}(norm1{s}(loop):norm2{s}(loop)));

        loop=loop+1;

    end
    writematrix(AUC{s}, 'auc_cho.xlsx', 'Sheet', shts(s))
end
end
