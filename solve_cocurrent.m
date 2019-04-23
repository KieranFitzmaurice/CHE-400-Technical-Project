function [z,PA,CA,CB,CE] = solve_cocurrent(h,PA0,CA0,CB0,CE0)

%% Absorption tower with co-current configuration, inlet fully specified

% Solve for concentration profiles as I.V.P.
z = linspace(0,h,1000);
x0 = [PA0,CA0,CB0,CE0];
[z,states] = ode45(@cocurrent,z,x0);
PA = states(:,1);
CA = states(:,2);
CB = states(:,3);
CE = states(:,4);

