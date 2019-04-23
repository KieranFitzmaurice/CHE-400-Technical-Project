% This program models flue-gas desulfurization using seawater as an
% absorbent for SO2. Calculates concentration profiles of key species for
% both co-current and counter-current configurations.

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

%% Solve for co-current configuration 
[z,PA_co,CA_co,CB_co,CE_co] = solve_cocurrent(h,PA0,CA0,CB0,CE0);
eta_co = 1 - PA_co/PA0;
pH_co = -log10(CB_co/1000);
rxn_co = k*(CB_co - CB0).*CE_co;
flux_co = -KL*(CA_co - H*PA_co);

%% Solve for counter-current configuration 
[z,PA_cc,CA_cc,CB_cc,CE_cc] = solve_countercurrent(h,PA0,CA0,CB0,CE0);
eta_cc = 1 - PA_cc/PA0;
pH_cc = -log10(CB_cc/1000);
rxn_cc = k*(CB_cc - CB0).*CE_cc;
flux_cc = -KL*(CA_cc - H*PA_cc);

%% Make pretty graphs

 % Trajectories of state variables 
 figure(1);
 linesize = 1.5;
 subplot(2,2,1)
 plot(z,PA_co,'LineWidth',linesize)
 hold on;
 plot(flipud(z),PA_cc,'LineWidth',linesize);
 xlim([0,h]);
 xlabel('Distance from gas inlet (m)')
 ylabel('(atm)')
 title('Partial Pressure SO_2(g)')
 legend('co-current','countercurrent');
 
 subplot(2,2,2)
 plot(z,CA_co,'LineWidth',linesize);
 hold on;
 plot(z,CA_cc,'LineWidth',linesize);
 xlim([0,h]);
 xlabel('Distance from liquid inlet (m)')
 ylabel('(mol / m^3)')
 title('Concentration of SO_2(aq)')
 
 subplot(2,2,3)
 plot(z,CB_co,'LineWidth',linesize);
 hold on;
 plot(z,CB_cc,'LineWidth',linesize);
 xlim([0,h]);
 xlabel('Distance from liquid inlet (m)')
 ylabel('(mol / m^3)')
 title('Concentration of H^+')
 
 subplot(2,2,4)
 plot(z,CE_co,'LineWidth',linesize);
 hold on;
 plot(z,CE_cc,'LineWidth',linesize);
 xlim([0,h]);
 xlabel('Distance from liquid inlet (m)')
 ylabel('(mol / m^3)')
 title('Concentration of HCO_3^-')
 
figure(2);
subplot(1,2,1);
plot(z,rxn_co,z,rxn_cc,'LineWidth',linesize);
title('Liquid Phase Reaction Rate')
txt_co = strcat(['co-current (mean = ',num2str(mean(rxn_co),'%.3f'),' mol / m^3 s)']);
txt_cc = strcat(['countercurrent (mean = ',num2str(mean(rxn_cc),'%.3f'),' mol / m^3 s)']);
xlabel('Distance from liquid inlet (m)');
ylabel('H^+ neutralization (mol / m^3 s)');
legend(txt_co,txt_cc);
subplot(1,2,2);
plot(z,flux_co,z,flux_cc,'LineWidth',linesize);
title('Gas-Liquid Mass Transfer Rate');
txt_co = strcat(['co-current (mean = ',num2str(mean(flux_co),'%.3e'),' mol / m^2 s)']);
txt_cc = strcat(['countercurrent (mean = ',num2str(mean(flux_cc),'%.3e'),' mol / m^2 s)']);
xlabel('Distance from liquid inlet (m)');
ylabel('SO_2 flux (mol / m^2 s)');
legend(txt_co,txt_cc);

figure(3);
subplot(2,1,1);
title('Co-current')
xlabel('Distance from liquid inlet (m)');
hold on;
yyaxis left
plot(z,eta_co,'-','LineWidth',linesize);
plot(z(100:100:900),eta_co(100:100:900),'>','LineWidth',linesize);
ylim([0 1]);
ylabel('Percent removal SO_2');
yyaxis right
plot(z,pH_co,'-','LineWidth',linesize);
plot(z(100:100:900),pH_co(100:100:900),'>','LineWidth',linesize);
ylim([2 8])
ylabel('Liquid stream pH')
subplot(2,1,2);
title('Countercurrent')
xlabel('Distance from liquid inlet (m)');
hold on;
yyaxis left
plot(z,eta_cc,'-','LineWidth',linesize);
plot(z(100:100:900),eta_cc(100:100:900),'<','LineWidth',linesize);
ylim([0 1])
ylabel('Percent removal SO_2');
yyaxis right
plot(z,pH_cc,'-','LineWidth',linesize);
plot(z(100:100:900),pH_cc(100:100:900),'>','LineWidth',linesize);
ylim([2 8])
ylabel('Liquid stream pH')
