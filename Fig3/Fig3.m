
load data

%% Plot CD spectra of 3 degradation states with std around mean line

% basaglar colors
col(1,:)=[0 0.4470 0.7410];
col(2,:)=[0.4660 0.6740 0.1880]*1.4;
col(3,:)=[0.4660 0.6740 0.1880]/1.5;

lgdText = {['Ideal (','4',char(176),'C)'],['37',char(176),'C + ag. 7 days'],['37',char(176),'C + ag. 14 days']};

% bas, huma, novo, respectively
q=0;
for i = 1:9:size(dat,2)
    if q == 1
        col(2,:)=[1 0.6745 0.1098];
        col(3,:)=[1 0 0];
        lgdText = {['Ideal (','4',char(176),'C)'],['65',char(176),'C 24 hr'],['65',char(176),'C 48 hr']};
    end
    iRange = [i,i+3,i+6];
    plotCD(col,iRange,dat,lgdText,q)
    q=q+1;
end

%% (1) 208nm, (2) 222nm/208nm ratio, and (3) 222nm
wl = [208.5,207.5,222.5,221.5];

for g = 1:3
    col=[[0 0.4470 0.7410];[0.4660 0.6740 0.1880]*1.4;[0.4660 0.6740 0.1880]/1.5];
    
    % Basaglar, humalog, novolog, respectively
    cdBar(col,dat,wl,[1,9],g,{['Ideal (','4',char(176),'C)'],['37',char(176),'C+ag.\newline7 days'],['37',char(176),'C+ag.\newline14 days']})
    
    col(2,:) = [1 0.6745 0.1098];
    col(3,:) = [1 0 0];
    
    cdBar(col,dat,wl,[10,18],g,{['Ideal (','4',char(176),'C)'],['65',char(176),'C 24 hr'],['65',char(176),'C 48 hr']})
    cdBar(col,dat,wl,[19,27],g,{['Ideal (','4',char(176),'C)'],['65',char(176),'C 24 hr'],['65',char(176),'C 48 hr']})
end

%% Plot CD ThT data on bioactivity plot

fn = 'CD_tht.xlsx';

shts=sheetnames(fn);
datTHT = {};
ss = [1 2 3];

for s = ss
    tab = table2array(readtable(fn,'Sheet',shts(s),'ReadVariableNames',true,'NumHeaderLines',0,'ReadRowNames',true));

    % remove all rows with only NaN
    tab( all( isnan( tab ), 2 ), : ) = [];
    % remove all columns with only NaN
    tab( :, all( isnan( tab ), 1 ) ) = [];
    
    datTHT{s} = tab;
end

%% Load bioactivity fit
load coeff_choFit

% choFit = [xb' xh' xn' yb' yh' yn'];

% Each insulin's color: Basaglar, Humalog, Novolog, respectively
colors = [[0.4660 0.6740 0.1880];[0 0 1];[0.4940 0.1840 0.5560]];

% plot ThT data points onto smooth model
yThT = zeros(size(datTHT{1},1),3);

figure;
hold on
p=[];
for deg = [3 2 1]

    % Change to log10 to match original fit, and ensure
    % non-negative/non-zero
    xFit = log10(datTHT{deg});
    xFit(xFit<=0)=0.0001;

    yThT(:,deg) = coeff(1,deg) * xFit .^ coeff(2,deg) + coeff(3,deg);

    % Non-negative bioactivity
    yThT(yThT<=0)=0;

    plot(choFit(:,deg), choFit(:,deg+3),'Color','black', 'LineWidth', 10);
    p(deg) = plot(choFit(:,deg), choFit(:,deg+3),'Color',colors(deg,:), 'LineWidth', 8);
    scatter(xFit,yThT(:,deg),350,'filled','MarkerFaceColor',colors(deg,:),'MarkerEdgeColor',[0 0 0],'LineWidth',3)

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
%export_fig CDbio.tif -m2.5 -q101;
