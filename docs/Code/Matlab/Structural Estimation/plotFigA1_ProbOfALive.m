% Plot Figure A1

setup_params % Load data
age = [26:1:90];

% Plot 
plot(age,ProbOfAlive)
axis([20 90 0.5 1.1])
xlabel('age')