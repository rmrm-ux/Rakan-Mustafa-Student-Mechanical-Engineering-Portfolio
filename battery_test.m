%% EV Battery Module 1D Transient Thermal Solver (Portfolio Edition)
clear; clc; close all;

%% 1. Simulation Controls
t_end = 1200;          % Total simulation time (seconds)
dt = 0.1;              % Time step (seconds)
time = 0:dt:t_end;
N_cells = 10;          % Number of cells in the 1D array

%% 2. Realistic Battery & Cooling Properties
m_cell = 0.070;        % Mass of one cell (kg)
Cp_cell = 800;         % Specific heat (J/kg*K)
R_cc = 0.25;           % Low thermal resistance between cells (Aluminum casing path)
R_cool = 0.08;         % High-performance thermal interface material to chill plate

T_amb = 25;            % Ambient temperature (°C)
T_cool = 20;           % Coolant temperature (°C)

R0 = 0.018;            % Modern 21700 cell internal resistance (Ohms)
alpha = 0.0001;        % Temperature coefficient

%% 3. Load Profile (Aggressive Fast-Charging)
I_profile = zeros(size(time));
I_profile(time <= 600) = 35;       % 35A Fast Charge for 10 mins
I_profile(time > 600 & time <= 1200) = 10; % Taper down to 10A

%% 4. Memory Allocation & Initial Conditions
T = zeros(N_cells, length(time));
T(:, 1) = T_amb;       

%% 5. Time-Stepping Matrix Solver (Explicit Finite Difference)
for k = 1:(length(time)-1)
    I = I_profile(k);
    for i = 1:N_cells
        R_int = R0 - alpha * (T(i, k) - T_amb);
        Q_gen = (I^2) * R_int;
        
        if i == 1
            Q_left = 0; % Insulated end
        else
            Q_left = (T(i, k) - T(i-1, k)) / R_cc;
        end
        
        if i == N_cells
            Q_right = (T(i, k) - T_cool) / R_cool; % Connected to Chill Plate
        else
            Q_right = (T(i, k) - T(i+1, k)) / R_cc;
        end
        
        dTdt = (Q_gen - Q_left - Q_right) / (m_cell * Cp_cell);
        T(i, k+1) = T(i, k) + dTdt * dt;
    end
end

%% 6. Portfolio-Grade Visualizations (High-Contrast Black Text Edition)
% Close any glitchy existing windows first
close all;

% -------------------------------------------------------------------------
% FIGURE 1: The Spatiotemporal Heatmap (Forced High-Contrast)
% -------------------------------------------------------------------------
fig1 = figure('Color', 'w', 'Position', [100, 100, 800, 500]);
[X, Y] = meshgrid(1:N_cells, time/60);
contourf(X, Y, T', 50, 'LineColor', 'none'); 
colormap(jet);

% Style the Colorbar
c = colorbar;
c.Label.String = 'Temperature (°C)';
c.Label.Color = 'k';         % Force colorbar label to black
c.Color = 'k';               % Force colorbar numbers to black
clim([20 135]); % Shows the actual temperature gradient colors up to 130°C 

title('Module Thermal Gradient Profile Over Time', 'FontSize', 14, 'Color', 'k', 'FontWeight', 'bold');
xlabel('Cell Number (Cell 1: Insulated Base | Cell 10: End Cooled)', 'FontSize', 11, 'Color', 'k');
ylabel('Simulation Time (Minutes)', 'FontSize', 11, 'Color', 'k');

% Force Axis Lines, Numbers, and Grid to Black
ax1 = gca;
ax1.Color = 'w';             % White plot background
ax1.XColor = 'k';            % Black X-axis line & numbers
ax1.YColor = 'k';            % Black Y-axis line & numbers
set(ax1, 'XTick', 1:N_cells);
grid on;
ax1.GridColor = 'k';         % Darker grid lines for readability
ax1.GridAlpha = 0.15;

% -------------------------------------------------------------------------
% FIGURE 2: Transient Lines (Forced Clean Presentation)
% -------------------------------------------------------------------------
fig2 = figure('Color', 'w', 'Position', [150, 150, 800, 500]);
plot(time/60, T(1,:), 'r-', 'LineWidth', 2.5, 'DisplayName', 'Cell 1 (Worst Case - Far End)');
hold on;
plot(time/60, T(5,:), 'g-', 'LineWidth', 2.5, 'DisplayName', 'Cell 5 (Mid-Pack)');
plot(time/60, T(10,:), 'b-', 'LineWidth', 2.5, 'DisplayName', 'Cell 10 (Best Case - Near Coolant)');

% Style the threshold line and its text safely
yl = yline(45, '--k', 'Max Degradation Limit (45°C)', 'LineWidth', 1.5);
yl.Color = [0.2 0.2 0.2];    % Dark gray dashed line

title('Transient Temperature Response (Realistic Cooling Parameters)', 'FontSize', 14, 'Color', 'k', 'FontWeight', 'bold');
ylabel('Temperature (°C)', 'FontSize', 11, 'Color', 'k');
xlabel('Time (Minutes)', 'FontSize', 11, 'Color', 'k');

% Style the Legend for high-contrast
lgd = legend('Location', 'best');
lgd.TextColor = 'k';         % Force legend text to black
lgd.Color = 'w';             % Force legend box background to white
lgd.EdgeColor = 'k';         % Black border around legend

% Force Axis Lines, Numbers, and Grid to Black
ax2 = gca;
ax2.Color = 'w';             % Converts the inside plot area from black to clean white
ax2.XColor = 'k';            % Black X-axis line & numbers
ax2.YColor = 'k';            % Black Y-axis line & numbers
ylim([20 140]); % Unlocks the Y-axis so we can see the full meltdown peak
grid on;
ax2.GridColor = 'k';         % Darker grid lines for readability
ax2.GridAlpha = 0.15;