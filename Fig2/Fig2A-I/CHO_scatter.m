function [xFitted,yFitted,coefficients] = CHO_scatter(num,match1,match2,colors,lgdText,lgdLoc,dat,fitting,howmany,ins)
    figure
    hold on

    % horizontal line at 0 and 1
    plot([-1 7],[0 0],'--k','LineWidth',3)
    plot([-1 7],[1 1],'--k','LineWidth',3)

    for c = 1:size(match1,2)
        CHO = (dat{num}(1,match1(c):match2(c)))';
        ThT = log10((dat{num}(2,match1(c):match2(c)))');
    
        if c == 1
            allCHO = CHO;
            allThT = ThT;
            meanCHO = mean(CHO);
            meanThT = mean(ThT);
        else
            allCHO = vertcat(allCHO,CHO);
            allThT = vertcat(allThT,ThT);
            meanCHO = vertcat(meanCHO,mean(CHO));
            meanThT = vertcat(meanThT,mean(ThT));
        end

        scatter(ThT,CHO,250,'filled','MarkerFaceColor',colors(c,:),'MarkerEdgeColor',[0 0 0],'LineWidth',3)
        % This is just to make legend more readable. Scatterplot legend
        % entries don't show up well
        pp(c) = plot(ThT+1000,CHO+1000,'LineWidth',10,'Color',colors(c,:));
    end
    
    xlabel('Log_{10} ThT (norm.)')
    ylabel('Bioactivity (norm.)')

    % Put data to fit into table.. remove negative values from analysis
    % since fitting power2
    if fitting == "mean"
        X = meanThT(meanThT>=0);
        Y = meanCHO(meanThT>=0);
    else
        X = allThT(allThT>=0 & allCHO>=0);
        Y = allCHO(allThT>=0 & allCHO>=0);
    end

    tbl = table(X,Y);
    
    % Fit to power2 model using best guess for parameters
    modelfun = @(b,x) b(1) * x(:, 1) .^ + b(2) + b(3);
    if ins == 1
        mdl = fitnlm(tbl, modelfun, [0, 23, 1.2]);
    else
        mdl = fitnlm(tbl, modelfun, [-0.2, 7, 1]);
    end
    
    % Extract coefficients
    coefficients = mdl.Coefficients{:, 'Estimate'};
    
    % Create smoothed/regressed data using the model
    xFitted = linspace(min(X), max(X), 50);
    yFitted = coefficients(1) * xFitted .^ coefficients(2) + coefficients(3);
    
    % plot the smooth model
    plot(xFitted, yFitted, 'k-', 'LineWidth', 6);

    lgd = legend(pp,convertCharsToStrings(lgdText),'Location',lgdLoc,'AutoUpdate','off');
    lgd.FontSize = 40;
    lgd.NumColumns = 2;
    colororder(colors);
    
    if num == 3
        xlim([-0.25 2.3])
        xticks([0 1 2])
    elseif num == 1
        xlim([-0.25 1.5])
        xticks([0 1])
    else
        xlim([-0.25 1.5])
        xticks([0 1])
    end
    ylim([-0.5 2])
    
    % P-value
    p = mdl.ModelFitVsNullModel.Pvalue;
    p=string(round(p,2,"significant"));

    % Adjusted R^2 -> Pearson R
    r = sqrt(mdl.Rsquared.Ordinary);
    r=string(round(r,2,"significant"));

    outp = strcat("{\itp} = ",p);
    outr = strcat("{\itr} = ",r);
    text(0.16,1.95,outp,'FontSize',42);
    text(0.181,1.6,outr,'FontSize',42);
    if num == 2
        str1 = 'huma';
    elseif num == 1
        str1  = 'novo';
    else
        str1 = 'bas';
    end
    % high quality output of open figure
    set(findall(gcf,'-property','FontSize'),'FontSize',29)
    iptsetpref('ImshowBorder','tight');
    %set(gcf, 'Position', get(0, 'Screensize'));
    set(gcf,'Position',[0 174 1550 375])
    %export_fig hold.tif -m2.5 -q101;
    
    %copyfile('hold.tif',[str1+howmany+'_scatter.tif']);

end