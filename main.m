%% Main optimization to find compl filters 
close all
clear 
clc 

addpath(genpath(pwd))

%% Complementary filtering
ft0 = [30 30];
filt_order = 5;

% High pass
% B numerator coefficient
% A denominator coeff
[Bh, Ah] = butter(filt_order, ft0(1), "high", "s");
[Bl, Al] = butter(filt_order, ft0(2),  "low", "s");

tfH = tf(Bh, Ah);
tfL = tf(Bl, Al);

%% Plot
figure()
bode(tfH, tfL, {1e-6, 1e6})
legend('High pass', 'Low pass')
grid on

%% Simulation
myobj = sim('AltBaroInertial.slx', ...
    'SrcWorkspace', 'current', ...
    'StopTime', '200');
out = myobj.yout;

%% Plot initialization results
figure();
p = plot( out(:,1), out(:,2), ...
    out(:,1), out(:,3), ...
    out(:,1), out(:,4), ...
    out(:,1), out(:,5));
p(1).LineWidth = 1.5;
p(2).LineWidth = 2;

legend('Real Height', 'Filtered Height', 'Barometric Height', 'Accelerometer Height')
title('Initialization')

%% Optimization step
ft = runOPTIM_comp_no_const(ft0)

%% Optimization output 
[BH, AH, KH] = butter(5, ft(1), "high", "s"); 
[BL, AL, KL] = butter(5, ft(2),  "low", "s");

[Bh, Ah] = zp2tf(BH, AH, KH);
[Bl, Al] = zp2tf(BL, AL, KL);

tfH = tf(Bh, Ah);
tfL = tf(Bl, Al);

n_p = 10000;
err = 1e2/n_p;
w   = logspace(0,2,n_p);

[magH,~] = bode(tfH,w);
[magL,~] = bode(tfL,w);

magH_db = mag2db(magH);
magL_db = mag2db(magL);

% equivalent complementary filter frequency 
ft_eq_index = find(abs(magH_db-magL_db)<err);
ft_eq       = w(ft_eq_index);

%% Simulation
myobj = sim('AltBaroInertial.slx',...
    'SrcWorkspace', 'current',...
    'StopTime', '200');
out = myobj.yout;

%% Plot optimization results
figure()
bodeplot(tfH,tfL,{1e0, 1e2})
xline(ft_eq)

legend('High pass', 'Low pass')
grid on

figure();
p= plot( out(:,1), out(:,2), ...
    out(:,1), out(:,3), ...
    out(:,1), out(:,4), ...
    out(:,1), out(:,5));
p(1).LineWidth = 1.5;
p(2).LineWidth = 2;

legend ('Real Height', 'Filtered Height', 'Barometric Height', 'Accelerometer Height')
title ('Optimized value')

%% Verify if the two filters are complementary 
figure()
bodeplot(tfH+tfL, {1e-6,1e6})
xline(ft_eq)
