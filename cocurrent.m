function dxdz = cocurrent(z,x)

%% Physical Property Data

R = 8.2057338e-5;   % Gas constant                     [m^3 atm / mol K]
H = 1260;           % Henry's Law Constant for SO2     [mol / m^3 atm]
K1 = 17.4;          % 1st equilibrium constant         [mol / m^3]
K2 = 6.24e-5;       % 2nd equilibrium constant         [mol / m^3]
k = 26.7;           % Reaction rate coefficient        [m^3 / mol s]
kl = 7e-4;          % Liquid side mass transfer        [m/s] 
kg = 3.217e-3;      % Gas side mass transfer           [m/s] 
KL = 1/(1/kl+1/kg); % Overall mass transfer coeff      [m/s] 

%% Initial Conditions 

T = 25 + 273.15;         % Temperature                          [K]
yA = 700/1e6;            % SO2 fraction in flue gas (700 ppm)   [ ]
P = 1;                   % System Pressure                      [atm]
PA0 = yA*P;              % Partial pressure of SO2 in flue gas  [atm]
CA0 = 0;                 % Concentration of SO2(aq) in liquid   [mol]
pH = 8.0;                % pH of seawater                       [ ]
CB0 = 1000*10^(-pH);     % Initial concentration of H+          [mol / m^3]
CE0 = 2.3783;            % Total Alkalinity of Seawater         [mol / m^3]

%% Absorption tower parameters

beta = 0.05; % Liquid holdup                       [ ]
QG = 1;      % Gas flow rate                       [m^3 / s]
LG = 0.1;    % L/G ratio                           [ ]
QL = QG*LG;  % Liquid flow rate                    [m^3 / s]
h = 5;       % Height                              [m]
Acs = 0.25;  % Cross sectional area                [m^2]
dp = 1e-3;   % Average droplet radius              [m]
a = 3/dp;    % Interfacial area per liquid volume  [m^-1]

%% Define Rate laws 

% Current Concentrations 

PA = x(1); % Partial Pressure SO2 in gas           [mol / m^3]
CA = x(2); % Concentration of SO2(aq) in liquid    [mol / m^3]
CB = x(3); % Concentration of H+ in liquid         [mol / m^3]
CE = x(4); % Concentration of HCO3- in liquid      [mol / m^3]

% Derivative of CA w.r.t CB (fast equilibrium)   
dCAdCB = 2*CB^2*(CB + 3*K2)/(K1*(CB + 2*K2)^2);
dCBdCA = 1/dCAdCB;

% Derivative of concentrations w.r.t. position in tower
dPAdz = beta*Acs/QG*(R*T*KL*a*(CA - H*PA));
dCAdz = beta*Acs/QL*(-KL*a*(CA - H*PA) - (k*(CB - CB0)*CE)*dCAdCB);
dCBdz = beta*Acs/QL*(-KL*a*(CA - H*PA)*dCBdCA - (k*(CB - CB0)*CE));
dCEdz = beta*Acs/QL*(-k*(CB - CB0)*CE);

dxdz = [dPAdz;dCAdz;dCBdz;dCEdz];

