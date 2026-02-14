%% Read data
huma = readtable('ThT_OD.xlsx','Sheet','Humalog');
novo = readtable('ThT_OD.xlsx','Sheet','Novolog');
bas = readtable('ThT_OD.xlsx','Sheet','Basaglar');

colors = [[0.4660 0.6740 0.1880]/0.75;[0.4660 0.6740 0.1880]/2.5];

%% Plot all insulins on one bar graph with expected

OD = zeros(1,3);

% find average of timepoint, per insulin
mu=[];
pt=[];
expect_pt=[];
expect_mu=[];

% Row where 37+ag data is
g=13;

mu(1) = mean(huma{g:g+2,7});
mu(2) = mean(novo{g:g+2,7});
mu(3) = mean(bas{g:g+2,7});

pt(1:3,1) = huma{g:g+2,7};
pt(1:3,2) = novo{g:g+2,7};
pt(1:3,3) = bas{g:g+2,7};

% Adding each single exposure gain together
% minus the added 1 (n-1)
% e.g.: 1.3, 1.2 should be expected 1.5, not 2.5

% 37degC + ag
expect_pt(1:3,1) = huma{4:6,7}+huma{19:21,7}-1;
expect_pt(1:3,2) = novo{4:6,7}+novo{19:21,7}-1;
expect_pt(1:3,3) = bas{4:6,7}+bas{19:21,7}-1;

expect_mu(1) = mean(expect_pt(:,1));
expect_mu(2) = mean(expect_pt(:,2));
expect_mu(3) = mean(expect_pt(:,3));



%%
% relative to first time point

figure;
b=bar([mu;expect_mu]','grouped','EdgeColor',[0 0 0],'LineWidth',3,'BarWidth',0.5);
b(1).FaceColor = 'flat';
b(2).FaceColor = 'flat';
b(1).BaseValue = -4;
b(2).BaseValue = -4;
b(1).ShowBaseLine='off';
b(2).ShowBaseLine='off';

for k = 1:size(pt,1)
    b(1).CData(k,:) = colors(1,:);
    b(2).CData(k,:) = colors(2,:);
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
        scatter(i+offset(1)+r,pt(k,i),250,'filled','MarkerEdgeColor',[0 0 0],'LineWidth',3,'MarkerFaceColor',colors(1,:))
        scatter(i+offset(2)+r,expect_pt(k,i),250,'filled','MarkerEdgeColor',[0 0 0],'LineWidth',3,'MarkerFaceColor',colors(2,:));
    end
    errorbar(i+offset(1),mu(i),std(pt(:,i)),'Color','black','LineWidth', 3,'CapSize',14);
    errorbar(i+offset(2),expect_mu(i),std(expect_pt(:,i)),'Color','black','LineWidth', 3,'CapSize',14);
end

% horizontal line at 1
% plot([-1 7],[1 1],'--k','LineWidth',4)
xlim([0.5 3.5])
ylim([0 11])
yticks([1 5 10])
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
    ritzStar([k-0.15 k+0.15],pT,9);
end

% high quality output of open figure
set(gca,'Box','off')
iptsetpref('ImshowBorder','tight');
set(gcf, 'Position', [1 49 1550/2 550]);
%export_fig 37ag.tif -m2.5 -q101;
