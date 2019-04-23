function obj = BVP_objective_func(eta);

% eta is guess for percent removal of SO2 in countercurrent configuration

% System parameters
yA = 700/1e6;            % SO2 fraction in flue gas (700 ppm)   [ ]
P = 1;                   % System Pressure                      [atm]
PA0 = yA*P;              % Partial pressure of SO2 in flue gas  [atm]
CA0 = 0;                 % Concentration of SO2(aq) in liquid   [mol]
pH = 8.0;                % pH of seawater                       [ ]
CB0 = 1000*10^(-pH);     % Initial concentration of H+          [mol / m^3]
CE0 = 2.3783;            % Total Alkalinity of Seawater         [mol / m^3]
h = 5;                   % Tower Height                         [m]

% Calculate a PA0 based off initial guess for percent removal 
z = linspace(0,h,1000);
x0 = [PA0*(1-eta),CA0,CB0,CE0];
[z,states] = ode45(@countercurrent,z,x0);
PA = states(:,1);
PA0_calc = PA(end);

% Want to minimize squared error between calculated and actual PA0
% When this value is close to zero, boundary conditions satisfied 
obj = (PA0 - PA0_calc)^2;
