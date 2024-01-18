function ft = runOPTIM_comp_no_const(ft0)


options = optimoptions (@lsqnonlin, ...
    'Algorithm', 'levenberg-marquardt',...
    'Display', 'iter',...
    'StepTolerance', 0.00001,...
    'OptimalityTolerance', 0.00001);

ft= lsqnonlin(@(ft)FITlsq(ft), ft0, [],[], options);


end

function res= FITlsq(ft)

[Bh, Ah]= butter(5,ft(1),"high","s"); 

[Bl, Al]= butter(5,ft(2),"low","s"); 


myobj = sim('AltBaroInertial.slx' , ...
            'SrcWorkspace', 'current', ...
            'stopTime', '300');
out =  myobj.yout;


figure (21)

p= plot( out(:,1), out(:,2), ...
    out(:,1), out(:,3));
p(1).LineWidth = 1.5;
p(2).LineWidth = 2;

legend ('Real Height', 'Filtered Height')
title ('Optimization')

res = out (:,2) - out(:,3);

end

