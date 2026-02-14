%% Read data
huma = readtable('ThT_OD.xlsx','Sheet','Humalog');
novo = readtable('ThT_OD.xlsx','Sheet','Novolog');
bas = readtable('ThT_OD.xlsx','Sheet','Basaglar');

colors = [[0 0 1];[0.4940 0.1840 0.5560];[0.4660 0.6740 0.1880];];

%% Plot all insulins on one bar graph per degradation type

titText = {['4',char(176),'C'] ['37',char(176),'C'] ['65',char(176),'C'] ['-20',char(176),'C'] ['37',char(176),'C and agitation'] 'Air' 'Agitation' 'UV'};

OD = zeros(size(titText,2),3);
loop=1;
for g = [1 4 7 10 13 16 19 24]
    % find average of timepoint, per insulin
    mu=[];
    pt=[];
    err=[];
    
    if g == 24
        x = ["0 hr." "0.5 hr." "1 hr." "1.5 hr." "2 hr."];
    else
        x = ["0 hr." "8 hr." "24 hr." "48 hr." "72 hr." "96 hr."];
    end

    OD(loop,1) = huma{g,size(x,2)+2};
    OD(loop,2) = novo{g,size(x,2)+2};
    OD(loop,3) = bas{g,size(x,2)+2};
    
    for t = 1:size(x,2)
        mu(t,1) = mean(huma{g:g+2,1+t});
        mu(t,2) = mean(novo{g:g+2,1+t});
        mu(t,3) = mean(bas{g:g+2,1+t});

        err(t,1) = std(huma{g:g+2,1+t});
        err(t,2) = std(novo{g:g+2,1+t});
        err(t,3) = std(bas{g:g+2,1+t});
        
        pt(t,1:3,1) = huma{g:g+2,1+t};
        pt(t,1:3,2) = novo{g:g+2,1+t};
        pt(t,1:3,3) = bas{g:g+2,1+t};
    end
    
    % relative to first time point
    for i = 1:size(mu,2)
        pt(:,:,i) = pt(:,:,i)./mu(1,i);
        mu(:,i) = mu(:,i)./mu(1,i);
    end
    
    figure;
    b=bar((1:size(x,2)),mu,'EdgeColor',[0 0 0],'LineWidth',3,'BarWidth',0.5);
    
    for k = 1:size(b,2)
        b(k).FaceColor = colors(k,:);
    end
    hold on
    
    offset = [-0.22 0 0.22];
    for i = 1:size(mu,2)
        for k = 1:3

            % built-in scatter jitter doesnt work for this, so create my own
            % jitter in x-direction
            a=-0.1;
            b=0.1;
            r = a + (b-a).*rand();

            % Connect dots with lines to show time lapse
            plot((1:size(x,2))+offset(i)+r,pt(:,k,i),'LineWidth',5,'Color',[0 0 0])
            plot((1:size(x,2))+offset(i)+r,pt(:,k,i),'LineWidth',2,'Color',colors(i,:))
            scatter((1:size(x,2))+offset(i)+r,pt(:,k,i),150,'filled','MarkerEdgeColor',[0 0 0],'LineWidth',3,'MarkerFaceColor',colors(i,:))
            

            % Mark freezings in huma

            %pt -> (timepoint, replicate, insulin)
            szFreeze = 600;
            if loop == 4 && k == 1 && i == 1
                scatter([2 3 4 5 6]+offset(i)+r,pt(2:6,k,i),szFreeze,'filled','MarkerEdgeColor',[0 0 0],'LineWidth',3,'MarkerFaceColor',[0.3010 0.7450 0.9330])
            elseif loop == 4 && k == 2 && i == 1
                scatter([3 5]+offset(i)+r,pt([3 5],k,i),szFreeze,'filled','MarkerEdgeColor',[0 0 0],'LineWidth',3,'MarkerFaceColor',[0.3010 0.7450 0.9330])
            elseif loop == 4 && k == 3 && i == 1
                scatter([2 3 4 5 6]+offset(i)+r,pt(2:6,k,i),szFreeze,'filled','MarkerEdgeColor',[0 0 0],'LineWidth',3,'MarkerFaceColor',[0.3010 0.7450 0.9330])
            end
            
            % Mark freezings in novo
            if loop == 4 && k == 1 && i == 2
                scatter(2+offset(i)+r,pt(2,k,i),szFreeze,'filled','MarkerEdgeColor',[0 0 0],'LineWidth',3,'MarkerFaceColor',[1 0 1])
                scatter([4 5]+offset(i)+r,pt(4:5,k,i),szFreeze,'filled','MarkerEdgeColor',[0 0 0],'LineWidth',3,'MarkerFaceColor',[1 0 1])
            elseif loop == 4 && k == 2 && i == 2
                scatter([4 5]+offset(i)+r,pt(4:5,k,i),szFreeze,'filled','MarkerEdgeColor',[0 0 0],'LineWidth',3,'MarkerFaceColor',[1 0 1])
            end

            % Mark freezings in bas
            if loop == 4 && k == 1 && i == 3
                scatter(2+offset(i)+r,pt(2,k,i),szFreeze,'filled','MarkerEdgeColor',[0 0 0],'LineWidth',3,'MarkerFaceColor',[0 1 0])
                scatter(4+offset(i)+r,pt(4,k,i),szFreeze,'filled','MarkerEdgeColor',[0 0 0],'LineWidth',3,'MarkerFaceColor',[0 1 0])
                scatter(6+offset(i)+r,pt(6,k,i),szFreeze,'filled','MarkerEdgeColor',[0 0 0],'LineWidth',3,'MarkerFaceColor',[0 1 0])
            end
        end  
    end
    
    % Put error bars on top of everything
    for i = 1:size(mu,2)
        errorbar((1:size(x,2))+offset(i),mu(:,i),-err(:,i),err(:,i),'Color',[0 0 0],'LineWidth',2,'LineStyle','none');
    end


    % horizontal line at 1
    % plot([-1 7],[1 1],'--k','LineWidth',4)
    % easier to first (1) use numerical label, then (2) swap to non-numerical
    xlim([0.4 size(x,2)+0.5])
    
    set(gca,'XTickLabel',x)
    ylim([0 40])
    yticks([1 5 10])
    ylabel('ThT (norm.)')
    h=gca;
    h.XAxis.TickLength = [0 0];
    set(findall(gcf,'-property','FontSize'),'FontSize',50)
    
    % high quality output of open figure
    iptsetpref('ImshowBorder','tight');
    set(gcf, 'Position', get(0, 'Screensize'));
    %export_fig hold.tif -m2.5 -q101;
    % if loop ~=4
    %     saveas(gcf,[titText{loop} '.tif']);
    % else
    %     saveas(gcf,'freeze.tif');
    % end
    % 
    % if loop ~=4
    %     copyfile('hold.tif',[titText{loop} '.tif']);
    % else
    %     copyfile('hold.tif','freeze.tif');
    % end
    % loop=loop+1;

end



