
load data

%% Create heat maps

for d = 1:size(dat,2)
    figure;
    h = heatmap(round(dat{d},1));
    h.YLabel = 'ThT';
    h.XLabel = 'Insulin';
    h.XDisplayLabels = {['60 ' char(181) 'M'],['297 ' char(181) 'M'],['595 ' char(181) 'M']};
    h.YDisplayLabels = {['0 ' char(181) 'M'],['1 ' char(181) 'M'],['2 ' char(181) 'M'],['6 ' char(181) 'M'],['16 ' char(181) 'M'],['41 ' char(181) 'M'],['106 ' char(181) 'M'],['270 ' char(181) 'M']};
    annotation('textarrow',[0.98,0.98],[0.5,0.5],'string','Gain', ...
      'HeadStyle','none','LineStyle','none','HorizontalAlignment','center','TextRotation',90,'FontSize',44);
    set(findall(gcf,'-property','FontSize'),'FontSize',50)

    % high quality output of open figure
    iptsetpref('ImshowBorder','tight');
    set(gcf, 'Position', get(0, 'Screensize'));
    %export_fig hold.tif -m2.5 -q101;
    
    % "dynamic" naming of figure
    %copyfile('hold.tif',strcat(shts(d),"_optThT.tif"));
end