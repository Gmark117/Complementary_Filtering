%% Main optimization to find compl filters 

close all
clear 
clc 

addpath (genpath (pwd))

%% Complementary filtering

ft0=[10 10];

% High pass
% B numerator coefficient
% A denominator coeff
[Bh, Ah]= butter(5,ft0(1),"high","s");
[Bl, Al]= butter(5,ft0(2),"low","s");

tfH = tf(Bh, Ah);
tfL= tf(Bl, Al);

%% Plot

figure(10), bode(tfH,tfL,{1e-6, 1e6})
legend('High pass', 'Low pass')
grid on

%% Simulation
myobj = sim('AltBaroInertial.slx',...
    'SrcWorkspace', 'current',...
    'StopTime', '300');
out = myobj.yout;

%% Plot inizialization results
figure(20);
p= plot( out(:,1), out(:,2), ...
    out(:,1), out(:,3), ...
    out(:,1), out(:,4), ...
    out(:,1), out(:,5));
p(1).LineWidth = 1.5;
p(2).LineWidth = 2;

legend ('Real Height', 'Filtered Height', 'Barometric Height', 'Accelerometer Height')
title ('Initialization')

%% Optimization step

ft= runOPTIM_comp_no_const(ft0)


%% Optimization output 


[Bh, Ah]= butter(5,ft(1),"high","s");
[Bl, Al]= butter(5,ft(2),"low","s");

tfH = tf(Bh, Ah);
tfL= tf(Bl, Al);


n_p=10000;
err= 1e2/n_p;
w = logspace(0,2,n_p);
[magH,phaseH]=bode(tfH,w);
magH_db=mag2db(magH);

[magL,phaseL]=bode(tfL,w);
magL_db=mag2db(magL);
% equivalent complementary filter frequency 
ft_eq_index = find(abs(magH_db-magL_db)<err);
ft_eq= w(ft_eq_index);



myobj = sim('AltBaroInertial.slx',...
    'SrcWorkspace', 'current',...
    'StopTime', '300');
out = myobj.yout;


figure(21)
bodeplot(tfH,tfL,{1e0, 1e2})
xline(ft_eq)

legend('High pass', 'Low pass')
grid on

figure(30);
p= plot( out(:,1), out(:,2), ...
    out(:,1), out(:,3), ...
    out(:,1), out(:,4), ...
    out(:,1), out(:,5));
p(1).LineWidth = 1.5;
p(2).LineWidth = 2;

legend ('Real Height', 'Filtered Height', 'Barometric Height', 'Accelerometer Height')
title ('Optimized value')


%% Verify if the two filters are complementary 


