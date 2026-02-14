function OD_huma_compare(mu,pt,colors,ylab,xlab,yLIM,yTop,yay)
    figure;
    b=bar(mu','EdgeColor',[0 0 0],'LineWidth',3,'BarWidth',0.5);
    b.FaceColor = 'flat';
    b.CData = colors;
    
    hold on
    for i = 1:size(mu,2)
        for k = 1:size(pt,2)
    
            % built-in scatter jitter doesnt work for this, so create my own
            % jitter in x-direction
            a=-0.05;
            b=0.05;
            r = a + (b-a).*rand();
        
            % Plot scatter and error of each replicate
            scatter(i+r,pt(k,i),250,'filled','MarkerEdgeColor',[0 0 0],'LineWidth',3,'MarkerFaceColor',colors(i,:))
            errorbar(i,mu(i),std(pt(:,i)),'Color','black','LineWidth', 3,'CapSize',14);
        end
    end
    
    % horizontal line at 1
    % plot([-1 7],[1 1],'--k','LineWidth',4)
    xlim([0.5 3.5])
    ylim(yLIM)
    yticks([0 0.1 0.2 1 10 20 50 75])
    ylabel(ylab)
    
    set(gca,'XTickLabel',xlab)
    set(gca,'box','off')
    hh=gca;
    hh.XAxis.TickLength = [0 0];
    set(findall(gcf,'-property','FontSize'),'FontSize',28)
    
    %% check if normal assumption holds before t-test.. user will be alerted if not
    % h is binary yes/no if reject null of normal. p is p-value
    
    comparisons = [...
        1 2;...
        1 3;...
        2 3];

    for k = 1:size(pt,1)
        [h(k,1),p(k,1),~] = swtest(pt(:,k),0.05);
    end
    
    if ~all(h)
        %disp('Normal distribution assumption is valid for all datasets.')
    else
        disp('Normal distribution assumption is rejected for at least one dataset')
    end
    
    % ANOVA: 1st input -> data, 2nd input -> grouping
    % assume alphas = 0.05
    pANOVA = anova1(pt(:),[1;1;1;2;2;2;3;3;3],"off");
    [~,~,stats] = anova1(pt(:),[1;1;1;2;2;2;3;3;3],'off');
    c = multcompare(stats,'Display','off','CriticalValueType','tukey-kramer');
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
    ritzStar2(comparisons,pPairwise,yTop,yay);
  
end