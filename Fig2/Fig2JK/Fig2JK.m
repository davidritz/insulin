
load data

fntSz = 28;
ht = 450;

%% (1) Plot 7 days vial 1 vs 7 days vial 2 (2) Plot all degradation from same vial

% none #1, 37ag 3 days, 37ag 3.5 days, 37ag 4 days, 37ag 7 days, none #2, 37ag 7 days #2, respectively
mu = mean(dat,2);
divBy(1) = mu(1);
divBy(2) = mu(6);

% data relative to unaltered treatment
for i = 1:size(dat,1)
    if i < 6
        mu(i) = mu(i)/divBy(1);
        dat(i,:) = dat(i,:)/divBy(1);
    else
        mu(i) = mu(i)/divBy(2);
        dat(i,:) = dat(i,:)/divBy(2);
    end
end

colors = [[0    0.4470    0.7410];[0 1 0];[0.4660    0.6740    0.1880]*1.4;...
    [0.4660    0.6740    0.1880];[0.4660    0.6740    0.1880]/3;[0.4660    0.6740    0.1880]/5;[0.4660    0.6740    0.1880]/9];

colors2 = [[245,222,179]/255;[0.7 0.7 0.7]];
figure;
b=bar([mu(5);mu(7)]','grouped','EdgeColor',[0 0 0],'LineWidth',3,'BarWidth',0.5);
b.FaceColor = 'flat';
b.BaseValue = -30;
b.CData(1,:) = colors2(1,:);
b.CData(2,:) = colors2(2,:);

hold on
loop=1;
for i = [5 7]
    for k = 1:size(dat,2)

        % built-in scatter jitter doesnt work for this, so create my own
        % jitter in x-direction
        a=-0.05;
        b=0.05;
        r = a + (b-a).*rand();
    
        % Plot scatter of each replicate
        scatter(loop+r,dat(i,k),250,'filled','MarkerEdgeColor',[0 0 0],'LineWidth',3,'MarkerFaceColor',colors2(loop,:))
    end
    errorbar(loop,mu(i),std(dat(i,:)),'Color','black','LineWidth', 3,'CapSize',14);
    loop=loop+1;
end

xlim([0.5 2.5])
ylim([-5 90])
yticks([1 25 50 75])
ylabel('ThT (norm.)')

set(gca,'XTickLabel',["Vial 1" "Vial 2"])
hh=gca;
hh.XAxis.TickLength = [0 0];

% check if normal assumption holds before t-test and ANOVA.. user will be alerted if not
% h is binary yes/no if reject null of normal. p is p-value

for k = 1:size(dat,1)
    [h(k,1),p(k,1),~] = swtest(dat(k,:),0.05);
end

if ~all(h)
    disp('Normal distribution assumption is valid for all datasets.')
else
    disp('Normal distribution assumption is rejected for at least one dataset')
end

% t-test between different vials
% ttest output: [rejected/accepted, p-value]
[~,pT] = ttest2(dat(5,:),dat(7,:));

% STYLISHLY add stats to current plot using ritzStar
set(findall(gcf,'-property','FontSize'),'FontSize',fntSz)
ritzStar([1 2],pT,75);

% high quality output of open figure
set(gca,'Box','off')
iptsetpref('ImshowBorder','tight');
set(gcf,'Position',[6 67 330 ht])
%export_fig betweenVials.tif -m2.5 -q101;

%% Heterogeneity within vial
figure;

lgdText = {['Ideal (4',char(176),'C)'],['3 days'],['3.5 days'],['4 days'],['7 days']};


b=bar([mu(1:5)]','grouped','EdgeColor',[0 0 0],'LineWidth',3,'BarWidth',0.5);
b.FaceColor = 'flat';
b.BaseValue = -30;
for k = 1:size(dat,1)-2
    b.CData(k,:) = colors(k,:);
end

hold on
for i = 1:size(dat,1)
    for k = 1:size(dat,2)

        % built-in scatter jitter doesnt work for this, so create my own
        % jitter in x-direction
        a=-0.05;
        b=0.05;
        r = a + (b-a).*rand();
    
        % Plot scatter of each replicate
        if i == 5
            scatter(i+r,dat(i,k),250,'filled','MarkerEdgeColor',colors(4,:),'LineWidth',3,'MarkerFaceColor',colors(i,:))
        else
            scatter(i+r,dat(i,k),250,'filled','MarkerEdgeColor',[0 0 0],'LineWidth',3,'MarkerFaceColor',colors(i,:))
        end
    end
    errorbar(i,mu(i),std(dat(i,:)),'Color','black','LineWidth', 3,'CapSize',14);
end

xlim([0.5 5.5])
ylim([-5 23])
yticks([1 10 20 40])
ylabel('ThT (norm.)')

set(gca,'XTickLabel',lgdText)
hh=gca;
hh.XAxis.TickLength = [0 0];
xticklabels([]);

% ANOVA stats
comparisons = [...
        1 2;...
        1 3;...
        1 4;...
        1 5;...
        2 3;...
        2 4;...
        2 5;...
        3 4;...
        3 5;...
        4 5];

statsChecky = dat(1:5,:);
statsChecky = statsChecky(:);
% ANOVA: 1st input -> data, 2nd input -> grouping
% assume alphas = 0.05
pANOVA = anova1(statsChecky,[1;2;3;4;5;1;2;3;4;5;1;2;3;4;5],"off");
[~,~,stats] = anova1(statsChecky,[1;2;3;4;5;1;2;3;4;5;1;2;3;4;5],'off');
c = multcompare(stats,'Display','off','CriticalValueType','tukey-kramer');
szComp = size(comparisons,1);
pPairwise = zeros(szComp,1);

% Only check user-inputted pairwise comparisons for significance
for w = 1:szComp
    % find [1 1] vector -- where c row and comparisons row are equal
    idx = find(sum((c(:,1:2) == comparisons(w,:)),2) == 2);
    pPairwise(w) = c(idx,6);
end

% STYLISHLY add stats to current plot using ritzStar
set(findall(gcf,'-property','FontSize'),'FontSize',fntSz)
ritzStar(comparisons,pPairwise,20);

% high quality output of open figure
set(gca,'Box','off')
iptsetpref('ImshowBorder','tight');
set(gcf,'Position',[6 67 330 ht])
%export_fig withinVials.tif -m2.5 -q101;