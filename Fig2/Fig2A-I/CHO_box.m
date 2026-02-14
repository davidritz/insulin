function CHO_box(num,match1,match2,colors,lgdText,dat,hm,small)
    if hm > 1
        comparisons = [...
            2 1;...
            3 1;...
            4 1;...
            5 1;...
            6 1;...
            7 1;...
            8 1;...
            9 1];
    else
        comparisons = [...
            2 1;...
            3 1;...
            4 1;...
            5 1;...
            6 1;...
            7 1;...
            8 1];
    end

    % check if normal assumption holds before ANOVA.. user will be alerted if not
    % h is binary yes/no if reject null of normal. p is p-value
    k=1;
    for r = 1:2
        for c = 1:size(match1,2)-1
            if r == 1
                normCheck = (dat{num}(1,match1(c):match2(c)))';
            else
                normCheck = (dat{num}(2,match1(c):match2(c)))';
            end
            [h(k),p(k)] = adtest(normCheck);
            k=k+1;
        end
    end
    
    if ~all(h)
        %disp('Normal distribution assumption is valid for all datasets.')
    else
        disp('Normal distribution assumption is rejected for a dataset')
    end
    
    % Make boxplots bioactivity
    figure
    hold on
    for c = 1:size(match1,2)
        CHO = (dat{num}(1,match1(c):match2(c)))';
        ThT = log10((dat{num}(2,match1(c):match2(c)))');
        
        nOrder = c*ones(size(CHO,1),1);
    
        if c == 1
            allCHO = CHO;
            allThT = ThT;
            allOrder = nOrder;
        else
            allCHO = vertcat(allCHO,CHO);
            allThT = vertcat(allThT,ThT);
            allOrder = vertcat(allOrder,nOrder);
        end
        
        b = boxchart(nOrder,CHO);
        
        b.BoxWidth = 0.5;
        b.BoxFaceAlpha = 0.4;
        b.BoxEdgeColor = [0 0 0];
        b.LineWidth = 3;
        b.JitterOutliers = 'off';
        b.MarkerSize = 0.01;
        b.MarkerStyle = '.';
        b.BoxFaceColor = colors(c,:);
        scatter(nOrder,CHO,250,'filled','MarkerFaceAlpha',1,'jitter','on','jitteramount',0.15,'MarkerFaceColor',colors(c,:),'MarkerEdgeColor',[0,0,0],'LineWidth',3)
    end
    
    ylabel('Bioactivity (norm.)')

    if hm > 1
        ylim([-0.5 3.2])
        yticks([0 1 2 3])
        set(gca,'XTick',[1 2 3 4 5 6 7 8 9],'XTickLabels',lgdText)
        yHigh = 1.7;
        mult=2.6;
        set(gcf,'Position',[6 67 1550/2 325])
        set(findall(gcf,'-property','FontSize'),'FontSize',28)
    else
        ylim([-0.5 2.3])
        yticks([0 1 2])
        set(gca,'XTick',[1 2 3 4 5 6 7 8],'XTickLabels',lgdText)
        yHigh=2;
        mult = 1.2;
        set(gcf,'Position',[6 67 1550/4 325])
        set(findall(gcf,'-property','FontSize'),'FontSize',29)
    end
    
    % Add stats to graph
    runANOVA(allCHO,allOrder,comparisons,yHigh,mult)


    if num == 2
        str1 = 'huma';
    elseif num == 1
        str1  = 'novo';
    else
        str1 = 'bas';
    end

    xticklabels([])

    % high quality output of open figure
    iptsetpref('ImshowBorder','tight');
    export_fig hold.tif -m2.5 -q101;
    copyfile('hold.tif',[str1,'_boxBIO.tif']);
    
    % Make boxplots ThT
    figure
    hold on
    for c = 1:size(match1,2)
        ThT = (dat{num}(2,match1(c):match2(c)))';
        
        nOrder = c*ones(size(ThT,1),1);
        
        b = boxchart(nOrder,ThT);
        
        b.BoxWidth = 0.5;
        b.BoxFaceAlpha = 0.4;
        b.BoxEdgeColor = [0 0 0];
        b.LineWidth = 3;
        b.JitterOutliers = 'off';
        b.MarkerSize = 0.01;
        b.MarkerStyle = '.';
        b.BoxFaceColor = colors(c,:);
        scatter(nOrder,ThT,250,'filled','MarkerFaceAlpha',1,'jitter','on','jitteramount',0.15,'MarkerFaceColor',colors(c,:),'MarkerEdgeColor',[0,0,0],'LineWidth',3)
    end
    
    ylabel('ThT (norm.)')
    if hm == 1
        set(gca,'XTick',[1 2 3 4 5 6 7 8],'XTickLabels',lgdText)
        ylim([0 90])
        yticks([1 25 50 75 100])
        yHigh = 1.5;
        mult = 140;
        set(gcf,'Position',[6 67 1550/4 325])
        set(findall(gcf,'-property','FontSize'),'FontSize',29)
    elseif hm == 2
        set(gca,'XTick',[1 2 3 4 5 6 7 8 9],'XTickLabels',lgdText)
        ylim([0 37])
        yticks([1 10 20 30])
        yHigh = 1.5;
        mult = 37;
        set(gcf,'Position',[6 67 1550/2 325])
        set(findall(gcf,'-property','FontSize'),'FontSize',28)
    elseif hm == 3
        set(gca,'XTick',[1 2 3 4 5 6 7 8 9],'XTickLabels',lgdText)
        ylim([0 19])
        yticks([1 5 10 15 20])
        yHigh = 1.5;
        mult = 23;
        set(gcf,'Position',[6 67 1550/2 325])
        set(findall(gcf,'-property','FontSize'),'FontSize',28)
    end

    if small == 1
        ylim([0.7 2])
        xlim([0.5 4.5])
        yticks([0 1 1.5 2])
        yHigh = 4.5;
        set(gcf,'Position',[6 67 1550/2 350])
        set(findall(gcf,'-property','FontSize'),'FontSize',28)
    else
        xticklabels([])
    end
    
    % Add stats to graph
    runANOVA(allThT,allOrder,comparisons,yHigh,mult)

    % high quality output of open figure
    %ylim([0 2])
    iptsetpref('ImshowBorder','tight');
    export_fig hold.tif -m2.5 -q101;
    if small == 1
        copyfile('hold.tif',[str1,'_smallboxTHT.tif']);
    else
        copyfile('hold.tif',[str1,'_boxTHT.tif']);
    end

end