% plotWealthPermIncRatio.m
% Plot figure of wealth perm income ratio

clear all;

setup_params
Data_SCF_wealth

% plot
age = [30:5:60];
% plot(age,Top25WealthSCF,'k-.');
% hold on
plot(age,MeanWealthSCF,'b-.');
hold on
plot(age,MedianWealthSCF,'k');
hold on
% plot(age,Bot25WealthSCF,'k-.');
% hold off
axis([30 60 0 20])
legend('means ','medians ',2)
xlabel('age')
