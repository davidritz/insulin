%% Dose response for Novolog, Basaglar, Humalog  insulin

load data

%% Plot dose response Novolog, Basaglar, Humalog 

x = log10([2.04;0.816;0.204;0.034;0.005667;0.000944;0.000157;0.0000262]');

reps = [1,4;1,5;1,5];
colors{1} = [[0 0.4470 0.7410];[1 0 0]];
colors{2} = [[0 0.4470 0.7410];[0.4660    0.6740    0.1880]];
colors{3} = [[0 0.4470 0.7410];[1 0 0]];

str1 = {'novo','bas','huma'};
for s = 1:3
    figure;
    hold on
    for d = 1:size(reps,2)
        % Load 3 replicates, minus background: 4 degC, 65 degC 48 hr
        if s ~= 2
            v1 = dat{1,s}(:,reps(s,d)) - dat{1,s}(end,3);
            v2 = dat{1,s}(:,reps(s,d)+1) - dat{1,s}(end,4);
        else
            v1 = dat{1,s}(:,reps(s,d)) - dat{1,s}(:,end);
            v2 = dat{1,s}(:,reps(s,d)+1) - dat{1,s}(:,end);
        end
    
        % 65 degC 48 hr novolog, all humalog/basaglar only has 2 reps
        if s == 1 && d==2
            v3 = 0;
        elseif s == 2 || s == 3
            v3 = 0;
        else
            v3 = dat{1,s}(:,reps(s,d)+2) - dat{1,s}(end,reps(s,d)+2);
        end
        
        % normalize so highest conc bioactivity for 4 degC = 1
        if d == 1 && s == 1
            f = mean([v1(2),v2(2),v3(2)]);
        elseif (d == 1 && s == 2) || (d == 1 && s == 3)
            f = mean([v1(2),v2(2)]);
        end

        v1 = v1/f;
        v2 = v2/f;
        v3 = v3/f;
        
        makeCurve(v1,v2,v3,x,colors{s}(d,:),s);
    end
    
    xlim([-4.7 0.5])
    ylim([-0.5 1.2])
    yticks([0 0.4 0.8 1.2])
    xticks([-4 -3 -2 -1 0])
    xlabel(['Log_{10} insulin conc. (' char(181) 'M)'])
    ylabel('Bioactivity (norm.)')
    
    hold off

    % Humalog insulin conc.
    x = log10([2.04;0.68;0.226667;0.075556;0.025185;0.008395;0.002798;0.000933]');
    if s > 1
        xlim([-3.1 0.5])
    end

    % high quality output of open figure
    set(findall(gcf,'-property','FontSize'),'FontSize',50)
    iptsetpref('ImshowBorder','tight');
    set(gcf, 'Position', get(0, 'Screensize'));
    %export_fig hold.tif -m2.5 -q101;

    %copyfile('hold.tif',[str1{s},'_doseCHO.tif']);

    
end
