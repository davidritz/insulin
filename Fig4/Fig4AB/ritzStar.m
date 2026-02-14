function ritzStar(comparisons,pPairwise,upperY,small)
    yInc1 = 6;
    if small == 2
        yInc2 = 0.2;
    else
        yInc2 = 0.5;
    end
    xCorrect = 0;
    ct=1;
    for q = 1:size(comparisons,1)

        if pPairwise(q) <= 0.05
            % Add line for each pairwise comparison
            newY = upperY+yInc1*(ct-1);
    
            % x-values slightly off
            line([comparisons(q,1) comparisons(q,2)],[newY newY],'Color','black','LineWidth',2)
            halfPt = sum(comparisons(q,:))/2-xCorrect;
    
            % Draw significance marking for pairwise comparison
            if pPairwise(q) <= 0.00001
                text(halfPt,newY+yInc2,'*****','FontSize',50,'FontWeight','bold','HorizontalAlignment','center');
            elseif pPairwise(q) <= 0.0001
                text(halfPt,newY+yInc2,'****','FontSize',50,'FontWeight','bold','HorizontalAlignment','center');
            elseif pPairwise(q) <= 0.001
                text(halfPt,newY+yInc2,'***','FontSize',50,'FontWeight','bold','HorizontalAlignment','center');
            elseif pPairwise(q) <= 0.01
                text(halfPt,newY+yInc2,'**','FontSize',50,'FontWeight','bold','HorizontalAlignment','center');
            elseif pPairwise(q) <= 0.05
                text(halfPt,newY+yInc2,'*','FontSize',50,'FontWeight','bold','HorizontalAlignment','center');
            else
                %text(halfPt,newY+yInc2*1.5,'n.s.','FontSize',30,'FontWeight','bold','HorizontalAlignment','center');
            end
            ct=ct+1;
        end
    end
    
end
