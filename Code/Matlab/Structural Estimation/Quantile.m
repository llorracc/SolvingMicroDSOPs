% Quantile.m
% function to give median and so on

function f = Quantile(cum,x)

f=1;
while cum(f)<1-x
    f=f+1;
end