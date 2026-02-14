%% Read data

fn = 'stress_recover.xlsx';

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

%% Plot all insulins on one bar graph with expected

% Get data from Excel sheet
mu=[];
pt=[];

expect_mu=[];
expect_pt=[];

% Huma, novo, bas, respectively
for i = 1:3
    mu(i) = mean(dat{i}(1:3,end));
    pt(1:3,i) = dat{i}(1:3,end);
    
    expect_mu(i) = mean(dat{i}(4:6,1));
    expect_pt(1:3,i) = dat{i}(4:6,1);
end



%%
% relative to first time point

colors = [[0 0 1];[0.4940 0.1840 0.5560];[0.4660 0.6740 0.1880]];

figure;
b=bar([mu;expect_mu]','grouped','EdgeColor',[0 0 0],'LineWidth',3,'BarWidth',0.5);
b(1).FaceColor = 'flat';
b(2).FaceColor = 'flat';
b(1).BaseValue = -1;
b(2).BaseValue = -1;
for k = 1:size(pt,1)
    b(1).CData(k,:) = colors(k,:);
    b(2).CData(k,:) = colors(k,:)/2.5;
end
hold on
offset = [-0.145 0.145];
for i = 1:size(mu,2)
    for k = 1:size(pt,2)

        % built-in scatter jitter doesnt work for this, so create my own
        % jitter in x-direction
        a=-0.05;
        b=0.05;
        r = a + (b-a).*rand();
    
        % Plot scatter of each replicate
        scatter(i+offset(1)+r,pt(k,i),250,'filled','MarkerEdgeColor',[0 0 0],'LineWidth',3,'MarkerFaceColor',colors(i,:))
        scatter(i+offset(2)+r,expect_pt(k,i),250,'filled','MarkerEdgeColor',[0 0 0],'LineWidth',3,'MarkerFaceColor',colors(i,:)/2.5);
    end
    errorbar(i+offset(1),mu(i),std(pt(:,i)),'Color','black','LineWidth', 3,'CapSize',14);
    errorbar(i+offset(2),expect_mu(i),std(expect_pt(:,i)),'Color','black','LineWidth', 3,'CapSize',14);
end

xlim([0.5 3.5])
ylim([0 34])
yticks([1 15 30 45])
ylabel('ThT (norm.)')

set(gca,'XTickLabel',["Humalog" "Novolog" "Basaglar"])
hh=gca;
hh.XAxis.TickLength = [0 0];
set(findall(gcf,'-property','FontSize'),'FontSize',28)

%% check if normal assumption holds before t-test.. user will be alerted if not
% h is binary yes/no if reject null of normal. p is p-value

for k = 1:size(pt,1)
    [h(k,1),p(k,1),~] = swtest(pt(:,k),0.05);
    [h(k,2),p(k,2),~] = swtest(expect_pt(:,k),0.05);
end

if ~all(h)
    disp('Normal distribution assumption is valid for all datasets.')
else
    disp('Normal distribution assumption is rejected for at least one dataset')
end

% ttest output: [rejected/accepted, p-value]
for k=1:size(pt,1)
    [~,pT] = ttest2(expect_pt(:,k),pt(:,k));

    % STYLISHLY add stats to current plot using ritzStar
    ritzStar([k-0.15 k+0.15],pT,28);
end

% high quality output of open figure
set(gca,'Box','off')
iptsetpref('ImshowBorder','tight');
set(gcf, 'Position', [1 49 1550/2 550]);
%export_fig stress_recover.tif -m2.5 -q101;