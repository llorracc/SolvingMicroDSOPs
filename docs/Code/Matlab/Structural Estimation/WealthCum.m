% WealthCum.m

function f = WealthCum(x)

f = zeros(1,length(x));

f(1) = x(1);

for i=2:length(x)
    f(i) = f(i-1) + x(i);
end