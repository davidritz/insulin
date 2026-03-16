
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
    plotHT(col,iRange,dat,lgdText,q)
    q=q+1;
end