%% Read data
fn = 'dotblot_tht.xlsx';
shts=sheetnames(fn);
dat = {};
    
for s = 1:size(shts,1)
    tab = table2array(readtable(fn,'Sheet',shts(s),'ReadVariableNames',true,'NumHeaderLines',0,'ReadRowNames',true));
    dat{s} = tab(:,2);
end

%% Plot ThT bar graphs of insulin used for dot blots

xLoc = [0.5,1,1.5,2.5,3,3.5,4.5,5,5.5];
colors = [[0 0 1];[0.4940 0.1840 0.5560];[0.4660 0.6740 0.1880]];

labels = {['Ideal (','4',char(176),'C)'] ['-20',char(176),'C'] ['65',char(176),'C']...
    ['Ideal (','4',char(176),'C)'] ['Expired'] ['65',char(176),'C']...
    ['Ideal (','4',char(176),'C)'] ['65',char(176),'C'] ['37',char(176),'C+ag.']};
for small = 1:2
    figure();
    hold on
    for s = 1:size(dat,2)
    
        % Novolog has 4 replicates
        if s == 2
            toPlot = zeros(4,3);
            qq=1;
            iti = [1 5 9];
            for q = iti
                toPlot(:,qq) = dat{s}(q:q+3);
                qq=qq+1;
            end
        else
            toPlot = zeros(3,3);
            qq=1;
            iti = [1 4 7];
            for q = iti
                toPlot(:,qq) = dat{s}(q:q+2);
                qq=qq+1;
            end
        end
        
        b(s)=bar(xLoc(1+(s-1)*3:3+(s-1)*3),mean(toPlot),'EdgeColor',[0 0 0],'LineWidth',3,'BarWidth',1,'FaceColor',colors(s,:));
    
        for i = 1:size(toPlot,2)
            for k = 1:size(toPlot,1)
        
                % built-in scatter jitter doesnt work for this, so create my own
                % jitter in x-direction
                a=-0.05;
                bb=0.05;
                r = a + (bb-a).*rand();
            
                % Plot scatter of each replicate
                scatter(xLoc(i+(s-1)*3)+r,toPlot(k,i),250,'filled','MarkerEdgeColor',[0 0 0],'LineWidth',3,'MarkerFaceColor',colors(s,:))
            end
            errorbar(xLoc(i+(s-1)*3),mean(toPlot(:,i)),std(toPlot(:,i)),'Color','black','LineWidth', 3,'CapSize',14);
        end
    end
    
    yticks([0 1 2 3 4 5 15 30 45 60])
    ylabel('ThT (norm.)')
    xticks(xLoc)
    set(gca,'XTickLabel',labels)
    hh=gca;
    hh.XAxis.TickLength = [0 0];
    
    yHigh = [15 30 52];
    if small == 1
        lgd = legend(b,'Humalog','Novolog','Basaglar','Location','northwest','AutoUpdate','off');
        ylim([5 65])
    else
        ylim([0 5])
    end

    set(findall(gcf,'-property','FontSize'),'FontSize',28)
    set(gcf, 'Position', get(0, 'Screensize'));

    % check if normal assumption holds before t-test and ANOVA.. user will be alerted if not
    % h is binary yes/no if reject null of normal. p is p-value

    comparisons = [...
        1 2;...
        1 3;...
        2 3];
    
    jj = [1 4 7; 1 5 9; 1 4 7];
    
    loop=1;
    for k = 1:size(dat,2)
        step = jj(k,2) - jj(k,1)-1;
        for j = jj(k,:)
            [h(loop),p(loop),~] = swtest(dat{k}(j:j+step),0.05);
            loop=loop+1;
        end
    
        if ~all(h)
            %disp('Normal distribution assumption is valid for all datasets.')
        else
            disp('Normal distribution assumption is rejected for at least one dataset')
        end
    
        % ANOVA: 1st input -> data, 2nd input -> grouping
        % assume alphas = 0.05
        datComp = dat{k};
        % 4 replicates in Novo
        if k == 2
            [~,~,stats] = anova1(datComp,[1;1;1;1;2;2;2;2;3;3;3;3],'off');
        else
            [~,~,stats] = anova1(datComp,[1;1;1;2;2;2;3;3;3],'off');
        end
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
        
        updCmp = [xLoc(k+(k-1)*2) xLoc(k+1+(k-1)*2);...
            xLoc(k+(k-1)*2) xLoc(k+2+(k-1)*2);...
            xLoc(k+1+(k-1)*2) xLoc(k+2+(k-1)*2)];
        % STYLISHLY add stats to current plot using ritzStar
        ritzStar(updCmp,pPairwise,yHigh(k),small);
    end
    
    % high quality output of open figure
    iptsetpref('ImshowBorder','tight');
    set(gcf, 'Position', [1 49 1550/2 765]);
    % if small == 1
    %     export_fig dotThT_high.tif -m2.5 -q101;
    % else
    %     export_fig dotThT_low.tif -m2.5 -q101;
    % end
end

%%
% Load bioactivity fit
load coeff_choFit

% choFit = [xb' xh' xn' yb' yh' yn'];

% Each insulin's color: Basaglar, Humalog, Novolog, respectively
colors = [[0.4660 0.6740 0.1880];[0 0 1];[0.4940 0.1840 0.5560]];

figure;
hold on
p=[];
for deg = [3 2 1]

    plot(choFit(:,deg), choFit(:,deg+3),'Color','black', 'LineWidth', 10);
    p(deg) = plot(choFit(:,deg), choFit(:,deg+3),'Color',colors(deg,:), 'LineWidth', 8);
end

for deg = [1 2 3]

    % Change to log10 to match original fit, and ensure
    % non-negative/non-zero
    xFit = log10(dat{deg});
    xFit(xFit<=0)=0.0001;

    yThT = coeff(1,deg) * xFit .^ coeff(2,deg) + coeff(3,deg);

    % Non-negative bioactivity
    yThT(yThT<=0)=0;

    scatter(xFit,yThT,350,'filled','MarkerFaceColor',colors(deg,:),'MarkerEdgeColor',[0 0 0],'LineWidth',3)

end
xlabel('Log_{10} ThT (norm.)')
ylabel('Bioactivity\newline(norm.)')
lgd = legend([p(2),p(3),p(1)],["Humalog","Novolog","Basaglar"],'Location','southwest','AutoUpdate','off','NumColumns', 3);
set(findall(gcf,'-property','FontSize'),'FontSize',28)

% horizontal line at 0 and 1
plot([-1 7],[0 0],'--k','LineWidth',3)
plot([-1 7],[1 1],'--k','LineWidth',3)

xlim([-0.1 2])
ylim([-0.1 1.4])

hold off

iptsetpref('ImshowBorder','tight');
set(gcf, 'Position', [1 239 1550 300]);
%export_fig DOTbio.tif -m2.5 -q101;