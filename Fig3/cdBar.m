function cdBar(colors,dat,wl,ii,g,xlab)

    idx1 = find(dat{1}(:,1)==wl(1));
    idx2 = find(dat{1}(:,1)==wl(2));
    idx3 = find(dat{1}(:,1)==wl(3));
    idx4 = find(dat{1}(:,1)==wl(4));
    
    rat1 = [];
    rat2 = [];
    rat3 = [];
    
    q=1;
    for i = ii(1):3:ii(2)
        if g == 2
            rat1(q) = mean(abs(dat{i}(idx3:idx4,2)))/mean(abs(dat{i}(idx1:idx2,2)));
            rat2(q) = mean(abs(dat{i+1}(idx3:idx4,2)))/mean(abs(dat{i+1}(idx1:idx2,2)));
            rat3(q) = mean(abs(dat{i+2}(idx3:idx4,2)))/mean(abs(dat{i+2}(idx1:idx2,2)));
        elseif g == 1
            rat1(q) = mean(abs(dat{i}(idx1:idx2,2)));
            rat2(q) = mean(abs(dat{i+1}(idx1:idx2,2)));
            rat3(q) = mean(abs(dat{i+2}(idx1:idx2,2)));
        else
            rat1(q) = mean(abs(dat{i}(idx3:idx4,2)));
            rat2(q) = mean(abs(dat{i+1}(idx3:idx4,2)));
            rat3(q) = mean(abs(dat{i+2}(idx3:idx4,2)));
        end
        q=q+1;
    end

    % Plot all insulin degradation on each bar graph, but 1 graph per
    % insulin type
    mu=[];
    pt=[];
    
    % Huma, novo, bas, respectively
    for i = 1:3
        mu(i) = mean([rat1(i),rat2(i),rat3(i)]);
        pt(1:3,i) = [rat1(i),rat2(i),rat3(i)];
    end

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
            scatter(i+r,pt(k,i),250,'filled','MarkerEdgeColor',[0 0 0],'LineWidth',4,'MarkerFaceColor',colors(i,:))
            errorbar(i,mu(i),std(pt(:,i)),'Color','black','LineWidth', 4,'CapSize',20);
        end
    end
    
    % plotting based on g
    xlim([0.5 3.5])
    ylabel(['mdeg (',char(1012),')'])
    if g == 1
        ylim([0 18])
        yticks([0 5 10 15])
        yHigh = 9;
        saveStr2 = '208';
    elseif g == 2
        ylim([0 3.5])
        yticks([0 1 2 3])
        ylabel('unitless')
        yHigh = 2;
        saveStr2 = '222_208';
    else
        ylim([0 14])
        yticks([0 5 10 15])
        yHigh = 7.5;
        saveStr2 = '222';
    end
    
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
    if ii(1) == 1
        saveStr1 = 'bas'; 
    elseif ii(1) == 10
        saveStr1 = 'huma';
    else
        saveStr1 = 'novo';
    end
    set(findall(gcf,'-property','FontSize'),'FontSize',29)
    ritzStar(comparisons,pPairwise,yHigh);

    %xtickangle(0);
    hh=gca;
    hh.XAxis.TickLength = [0 0];
    xticklabels([])
    
    % high quality output of open figure
    set(gca,'Box','off')
    iptsetpref('ImshowBorder','tight');
    set(gcf, 'Position', [1 239 1550/3 250]);
    %export_fig hold.tif -m2.5 -q101;
    %copyfile('hold.tif',[saveStr1,'_',saveStr2,'.tif']);
end