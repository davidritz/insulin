function makeCurve(v1,v2,v3,x,colors,s)
    % +- max/min
    v = zeros(size(v1,1),1);
    sigma = zeros(size(v1,1),1);
    if s == 1
        vVals = 3:5;
    elseif s == 3
        vVals = 2:4;
    else
        vVals = 2:3;
    end

    for k = 1:size(v1,1)
        % check if there are 2 or 3 reps
        if v3 == 0
            slice = [v1(k);v2(k)];
        else
            slice = [v1(k);v2(k);v3(k)];
        end
        distHold = fitdist(slice,'normal');
        %sigma(k,1) = (max(slice)-min(slice))/2;
        sigma(k,1) = max(slice);
        sigma(k,2) = min(slice);
        v(k) = distHold.mu;
    end
    
    
    confInt = [sigma(:,1) sigma(:,2)];
    xconf = [x fliplr(x)];         
    yconf = [confInt(:,1)' flip(confInt(:,2))'];
    
    fill(xconf,yconf,colors,'FaceColor',colors,'EdgeColor','black','FaceAlpha',0.3);
    plot(x,v,'Color',colors,'LineWidth',10);
    scatter(x,v,500,'filled','MarkerFaceColor',colors,'MarkerEdgeColor','black','LineWidth',5);
    scatter(x(vVals),v(vVals),2000,'filled','MarkerFaceColor',colors,'MarkerEdgeColor','black','LineWidth',5);

    % Fit line fit through the data points I'll use for analysis
    % coefficients = polyfit(x(vVals), v(vVals), 1);
    % xFit = linspace(min(x(vVals))-0.1, max(x(vVals))+0.1, 1000);
    % yFit = polyval(coefficients , xFit);
    % plot(xFit, yFit, colors2, 'LineWidth', 6);


    
end