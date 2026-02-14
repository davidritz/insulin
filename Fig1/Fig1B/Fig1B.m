
%% Read data
huma = readtable('ThT_OD.xlsx','Sheet','Humalog');
novo = readtable('ThT_OD.xlsx','Sheet','Novolog');
bas = readtable('ThT_OD.xlsx','Sheet','Basaglar');

colors = [[0 0.4470 0.7410];[0.4940 0.1840 0.5560];[1 0.6471 0];[0.4660 0.6740 0.1880];[1 0 0];[0.4314 1 1];[0.5 0.5 0.5];[1 1 1]];


%% Plot all insulins on one bar graph per degradation type

titText = {['Ideal (4',char(176),'C)'] ['-20',char(176),'C'] ['37',char(176),'C'] ['37',char(176),'C+ag.'] ['65',char(176),'C'] 'Air' 'Ag.' 'UV'};

ODs = zeros(size(titText,2),3);
loop=1;

mu=[];
pt=[];
err=[];

% find average OD at final timepoint, per condition, per each insulin

for g = [1 4 7 10 13 16 19 24]
    
    % UV has less timepoints, so smaller step
    if g == 24
        step = 6;
    else
        step = 7;
    end
    
    % average 96 hr ThT
    mu(loop,1) = mean(huma{g:g+2,step});
    mu(loop,2) = mean(novo{g:g+2,step});
    mu(loop,3) = mean(bas{g:g+2,step});
    
    % std of 96 hr ThT
    err(loop,1) = std(huma{g:g+2,step});
    err(loop,2) = std(novo{g:g+2,step});
    err(loop,3) = std(bas{g:g+2,step});
    
    % each point for scatterplot 
    pt(loop,1:3,1) = huma{g:g+2,step};
    pt(loop,1:3,2) = novo{g:g+2,step};
    pt(loop,1:3,3) = bas{g:g+2,step};
    
    loop=loop+1;
end

figure;
b=bar(1:3,mu,'EdgeColor',[0 0 0],'LineWidth',3,'BarWidth',1);
    
for k = 1:size(b,2)
    b(k).FaceColor = colors(k,:);
end

hold on

% each bar offset by +-0.1
offset = -0.35:0.1:0.35;

for i = 1:size(mu,2)
    for k = 1:size(mu,1)
        for q = 1:size(pt,2)
            % built-in scatter jitter doesnt work for this, so create my own
            % jitter in x-direction
            rng(82+q);
            a=-0.025;
            b=0.025;
            r = a + (b-a).*rand();
    
            % Scatter on top of bars
            scatter(i+offset(k)+r,pt(k,q,i),150,'filled','MarkerEdgeColor',[0 0 0],'LineWidth',3,'MarkerFaceColor',colors(k,:))
        end
    end
end

x={'Humalog';'Novolog';'Basaglar'};
% Put error bars on top of everything
for i = 1:size(mu,2)
    errorbar(i+offset,mu(:,i),-err(:,i),err(:,i),'Color',[0 0 0],'LineWidth',2,'LineStyle','none');
end


% easier to first (1) use numerical label, then (2) swap to non-numerical
xlim([0.4 size(mu,2)+0.5])
set(gca,'XTickLabel',x)

%ylim([0 10])
%ylim([10 40])
ylim([0 40])
yticks([0 5 10 20 30 40 50])
ylabel('ThT (norm.)')
lgd = legend(titText,'Location','northeast','NumColumns', 2,'AutoUpdate','off');
h=gca;
h.XAxis.TickLength = [0 0];

set(findall(gcf,'-property','FontSize'),'FontSize',25)
%% Stats
yHigh = [18, 30, 12];
for k = 1:size(pt,3)
        
    % check if normal assumption holds before ANOVA.. user will be alerted if not
    % h is binary yes/no if reject null of normal. p is p-value
    
    comparisons = [...
        2 1;...
        3 1;...
        4 1;...
        5 1;...
        6 1;...
        7 1;...
        8 1];
    
    for kk = 1:size(pt,1)
        vec = pt(kk,:,k);
        [hh(kk,1),p(kk,1),~] = swtest(vec,0.05);
    end
    
    if ~all(hh)
        %disp('Normal distribution assumption is valid for all datasets.')
    else
        disp('Normal distribution assumption is rejected for at least one dataset between clades.')
    end
    
    % ANOVA: 1st input -> data, 2nd input -> grouping
    % assume alphas = 0.05

    % Matlab anova likes column vectors
    cats = [1;2;3;4;5;6;7;8;1;2;3;4;5;6;7;8;1;2;3;4;5;6;7;8];
    datStat = pt(:,:,k);
    datStat = datStat(:);

    pANOVA = anova1(datStat,cats,"off");
    [~,~,stats] = anova1(datStat,cats,'off');
    c = multcompare(stats,'Display','off','CriticalValueType','dunnett');
    szComp = size(comparisons,1);
    pPairwise = zeros(szComp,1);
    

    % Only check user-inputted pairwise comparisons for significance
    for w = 1:szComp
        % find [1 1] vector -- where c row and comparisons row are
        % equal
        idx = find(sum((c(:,1:2) == comparisons(w,:)),2) == 2);
        pPairwise(w) = c(idx,6);
    end


    % STYLISHLY add stats to current plot using ritzStar
    if any(pPairwise<=0.05)
        ritzStar(([offset(1),offset(2);offset(1),offset(3);offset(1),offset(4);offset(1),offset(5);offset(1),offset(6);offset(1),offset(7);offset(1),offset(8)]+k),pPairwise,yHigh(k));
    end
        
end

% high quality output of open figure
iptsetpref('ImshowBorder','tight');
%set(gcf, 'Position', get(0, 'Screensize'));
set(gcf,'Position',[0 174 1536 373])
set(gca,'Box','off')
%export_fig ThT_fin_big.tif -m2.5 -q101;