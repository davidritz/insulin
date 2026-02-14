function runANOVA(dat1,dat2,comparisons,yTop,mult)
    % ANOVA: 1st input -> data, 2nd input -> grouping
    % assume alphas = 0.05
    [~,~,stats] = anova1(dat1,dat2,'off');
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
    ritzStar(comparisons,pPairwise,yTop,mult);
end