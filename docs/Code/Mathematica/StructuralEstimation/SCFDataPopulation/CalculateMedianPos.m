% CalculateMedianPos.m
% function to calculate position of median

function f = CalculateMedianPos(x)

% Cumlative distribution
cum    = zeros(1,length(x));
cum(1) = x(1);
for i=2:length(x)
    cum(i) = cum(i-1) + x(i);
end

% Calculate position of median
f=1;
while cum(f)<0.5
    f=f+1;
end