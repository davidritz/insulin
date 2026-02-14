%% Read data
huma = readtable('ThT_OD.xlsx','Sheet','Humalog');
novo = readtable('ThT_OD.xlsx','Sheet','Novolog');
bas = readtable('ThT_OD.xlsx','Sheet','Basaglar');

colors = [[0 0 1];[0.4940 0.1840 0.5560];[0.4660 0.6740 0.1880]];

%% Plot all insulins on one bar graph with expected

OD = zeros(1,3);

% find average of timepoint, per insulin
mu=[];
pt=[];
expect_pt=[];
expect_mu=[];

% Row where multiple exposure data is
g=29;

mu(1) = mean(huma{g:g+2,7});
mu(2) = mean(novo{g:g+2,7});
mu(3) = mean(bas{g:g+2,7});

pt(1:3,1) = huma{g:g+2,7};
pt(1:3,2) = novo{g:g+2,7};
pt(1:3,3) = bas{g:g+2,7};

% Adding each single exposure gain together
% minus the 3 added 1s (n-1)
% e.g.: 1.3,1.2,1.3 should be expected 1.8, not 3.8

% F/T + 37degC&ag + 65degC 6 hr + UV 30 min
expect_pt(1:3,1) = huma{10:12,3}+huma{13:15,3}+huma{34:36,6}+huma{24:26,3}-3;
expect_pt(1:3,2) = novo{10:12,3}+novo{13:15,3}+novo{34:36,8}+novo{24:26,3}-3;
expect_pt(1:3,3) = bas{10:12,3}+bas{13:15,3}+bas{7:9,3}+bas{24:26,3}-3;

expect_mu(1) = mean(expect_pt(:,1));
expect_mu(2) = mean(expect_pt(:,2));
expect_mu(3) = mean(expect_pt(:,3));



%%
% relative to first time point

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

% horizontal line at 1
%plot([-1 7],[1 1],'--k','LineWidth',4)
xlim([0.5 3.5])
ylim([0.5 4.1])
yticks([0 1 2 3 4])
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
    %disp('Normal distribution assumption is valid for all datasets.')
else
    disp('Normal distribution assumption is rejected for at least one dataset')
end

% ttest output: [rejected/accepted, p-value]
for k=1:size(pt,1)
    [~,pT] = ttest2(expect_pt(:,k),pt(:,k));

    % STYLISHLY add stats to current plot using ritzStar
    ritzStar([k-0.15 k+0.15],pT,3.4);
end

% high quality output of open figure
set(gca,'Box','off')
iptsetpref('ImshowBorder','tight');
set(gcf, 'Position', [1 49 1550/2 550]);
%export_fig bbd.tif -m2.5 -q101;
