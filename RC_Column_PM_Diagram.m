% RC Columns P-M Diagram.
% Solution Code for SE151A_WI25_HW8.
% Author: Ruipu Ji.

% Initialization and default plot settings. -------------------------------
clc; clear; close all;

set(0, 'DefaultTextInterpreter', 'latex');
set(0, 'DefaultLegendInterpreter', 'latex');
set(0, 'DefaultAxesTickLabelInterpreter', 'latex');

set(0, 'DefaultAxesFontSize', 15);
set(0, 'DefaultTextFontSize', 15);

% Enter input information. ------------------------------------------------
% Section dimension.
b = 16; % Section width (unit = inch).
h = 16; % Section height (unit = inch).

% Material properties.
fc_1 = 5; % Concrete compressive strength for Problem 1 (unit = ksi).
fc_2 = 8; % Concrete compressive strength for Problem 2 (unit = ksi).
beta_1 = 0.85 - 0.05*(fc_1-4000)/1000;
beta_2 = 0.85 - 0.05*(fc_2-4000)/1000;

fy = 60; % Steel reinforcement yield strength (unit = ksi).
Es = 29000; % Elastic modulus of steel reinforcement (unit = ksi).
eps_cu = -0.003; % Strain of the most compressive fiber at the peak capacity.

% Reinforcement layout.
d = [3 3 13 13]; % Distance between the center of each reinforcement and the top of the section (unit = inch).
As = [1.56 1.56 1.56 1.56]; % Area of each reinforcement (unit = inch^2).

% Calculate P-M interaction. ----------------------------------------------
% Initialize an 101x9 array for result output.
% (100 rows for P-M interaction and the last row for pure axial load P0).
Results = zeros(101, 9);

for i = 1:100
    % Calculate the neutral axis distance c.
    c = 0.01*i*h;

    % Calculate strain of each reinforcement based on strain profile.
    % Sign convention: Compression is negative (-); Tension is positive (+).
    eps_s = eps_cu*(c-d)/c; 

    % Calculate stress of each reinforcement based on stress-strain relationship.
    % Sign convention: Compression is negative (-); Tension is positive (+).
    fs = Es*eps_s; 
    fs = max(min(fs, fy), -fy); % Limit stress values between -fy and fy.

    % Calculate the axial load capacity Pn (unit = kips).
    % Sign convention: Compression is positive (+); Tension is negative (-).
    Pn_1 = 0.85*fc_1*b*beta_1*c - sum(As.*fs); % Pn for fc = 5 ksi.
    Pn_2 = 0.85*fc_2*b*beta_2*c - sum(As.*fs); % Pn for fc = 8 ksi.

    % Calculate the moment capacity Mn (unit = kip*ft).
    Mn_1 = (0.85*fc_1*b*beta_1*c*(h/2-beta_1*c/2) - sum(As.*fs.*(h/2-d))) / 12; % Mn for fc = 5 ksi.
    Mn_2 = (0.85*fc_2*b*beta_2*c*(h/2-beta_2*c/2) - sum(As.*fs.*(h/2-d))) / 12; % Mn for fc = 8 ksi.
    
    % Result output.
    Results(i,:) = [c, eps_s(1), fs(1), eps_s(end), fs(end), Pn_1, Mn_1, Pn_2, Mn_2];
end

% Caclulate P0 (pure axial load capacity). --------------------------------
Ag = b*h; % Gross cross section area.
Ast = sum(As); % Total area of all the steel reinforcement.

% Calculate P0.
P0_1 = 0.85*fc_1*(Ag-Ast) + Ast*fy; % P0 for fc = 5 ksi.
P0_2 = 0.85*fc_2*(Ag-Ast) + Ast*fy; % P0 for fc = 8 ksi.

% Result output.
Results(end,:) = [0, -fy/Es, -fy, -fy/Es, -fy, P0_1, 0, P0_2, 0];

% Plot P-M interaction diagram. -------------------------------------------
Results = array2table(Results, 'VariableNames', {'c [inch]', 'Epsilon''', 'fs'' [ksi]', 'Epsilon', 'fs [ksi]', 'Pn_1 [kips]', 'Mn_1 [kip*ft]', 'Pn_2 [kips]', 'Mn_2 [kip*ft]'});

figure('Position', [0, 0, 600, 500]);
hold on;

plot(Results{:,7}, Results{:,6}, 'Color', 'b', 'LineWidth', 2);
plot(Results{:,9}, Results{:,8}, 'Color', 'r', 'LineWidth', 2);
grid on;
box on;
xlim([0 500]);
xticks(0:100:500);
ylim([0 2500]);
yticks(0:500:2500);
xlabel('$M_n$ [kip$\cdot$ft]');
ylabel('$P_n$ [kips]');
legend('$f''_c = 5000$ psi', '$f''_c = 8000$ psi', 'Location', 'northeast');
title('$P$-$M$ Interaction Diagram');