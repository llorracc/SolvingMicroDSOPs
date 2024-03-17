% WeightedSumDist.m
% Function to give weighted sum of distance

function f = WeightedSumDist(x,y,pi,weight) % pi indicates pith quantile

f = 0;
for i=1:length(x)
  if x(i,1)-y(x(i,2))>0
    f = f + (x(i,1)-y(x(i,2)))*pi*weight(x(i,2))*x(i,3);      % x(i,3) is sample weight (defined as omega(i) in paper)
  else
    f = f + (x(i,1)-y(x(i,2)))*(pi-1)*weight(x(i,2))*x(i,3);
  end
end