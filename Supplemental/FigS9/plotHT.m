function plotHT(col,iRange,dat,lgdText,qq)
    figure()
    hold on
    q=1;
    for j = 1:size(iRange,2)
        idx = iRange(j);
        
        % Load 3 replicates
        v1 = dat{idx}(:,3);
        v2 = dat{idx+1}(:,3);
        v3 = dat{idx+2}(:,3);
    
        x = dat{idx}(:,1)';
    
        % Find confidence interval for each pt, assuming normal
        sigma = zeros(size(v1,1),1);
        v = zeros(size(v1,1),1);
        for k = 1:size(v1,1)
            slice = [v1(k);v2(k);v3(k)];
            distHold = fitdist(slice,'normal');
            sigma(k) = distHold.sigma;
            v(k) = distHold.mu;
        end
    
        confInt = [v+sigma v-sigma];
        % CD data outputted 250->200 instead of 200->250, so switch order
        % of flipping
        xconf = [fliplr(x) x];
        yconf = [fliplr(confInt(:,1)') confInt(:,2)'];
        
        % plot mean and std
        fill(xconf,yconf,col(q,:),'FaceColor',col(q,:),'EdgeColor','black','FaceAlpha',0.5);
        
        if q == 1
            p1 = plot(x,v,'Color',col(q,:),'LineWidth',4);
        elseif q == 2
            p2 = plot(x,v,'Color',col(q,:),'LineWidth',4);
        elseif q == 3
            p3 = plot(x,v,'Color',col(q,:),'LineWidth',4);
        end

        q=q+1;
 
    end
    ylim([0 850])
    xlim([200 250])
    
    set(gca,'FontSize',15,'XTick',[200 210 220 230 240 250],'YTick',[0 300 600],'box','off')
    ylabel(['HT (V)'],'FontSize',20)
    xlabel('Wavelength (nm)','FontSize',20)
    l=legend([p1,p2,p3],lgdText,'Location','northeast');
    set(findall(gcf,'-property','FontSize'),'FontSize',28)
    l.FontSize = 20;

    if qq == 0
        saveStr1 = 'bas'; 
    elseif qq == 1
        saveStr1 = 'hum';
    else
        saveStr1 = 'nov';
    end
    iptsetpref('ImshowBorder','tight');
    set(gcf, 'Position', [1 239 1550 300]);
    % export_fig hold.tif -m2.5 -q101;
    % copyfile('hold.tif',[saveStr1,'_plotHT.tif']);

end