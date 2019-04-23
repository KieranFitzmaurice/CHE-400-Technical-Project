function [z,PA,CA,CB,CE] = solve_countercurrent(h,PA0,CA0,CB0,CE0)

%% Use Newton's Method to solve for percent removal SO2 that satisfies B.C.
tol = 1e-10;      % convergence criteria 
delta_eta = 1e-5; % stepsize for computation of objective func derivative  
eta_1 = 0.5;      % initial guess for percent removal SO2

while 1
    obj = BVP_objective_func(eta_1);
    obj_prime = (BVP_objective_func(eta_1 + delta_eta) - obj)/delta_eta;

    eta_2 = eta_1 - obj/obj_prime;
    
    if obj < tol;
        eta = eta_2;    % True value of percent removal SO2
        break
    else
        eta_1 = eta_2;  % If B.C. not satisfied, keep iterating
    end
end

%% Now that top of tower is fully specified, can solve as I.V.P.
z =   linspace(0,h,1000);
x0 = [PA0*(1-eta),CA0,CB0,CE0];
[z,states] = ode45(@countercurrent,z,x0);
PA = states(:,1);
CA = states(:,2);
CB = states(:,3);
CE = states(:,4);
