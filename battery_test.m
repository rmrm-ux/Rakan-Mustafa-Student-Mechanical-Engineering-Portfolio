%% EV Battery Module 1D Transient Thermal Solver
clear; clc; close all;

%% 1. Simulation Controls
t_end = 1200;          % Total simulation time (seconds)
dt = 0.1;              % Time step (seconds)
time = 0:dt:t_end;
N_cells = 10;          % Number of cells in the 1D array

%% 2. Battery and Cooling Properties
m_cell = 0.070;        % Mass of one cell (kg)
Cp_cell = 800;         % Specific heat (J/kg*K)
R_cc = 0.25;           % Thermal resistance between adjacent cells (K/W)
R_cool = 0.08;         % Thermal resistance from Cell 10 to the chill plate (K/W)

T_amb = 25;            % Ambient temperature (°C)
T_cool = 20;           % Coolant temperature (°C)

R0 = 0.018;            % Internal resistance at ambient temp, 21700 cell (Ohms)
alpha = 0.0001;        % Resistance drop per degree above ambient (1/°C)

%% 3. Load Profile
I_profile = zeros(size(time));
I_profile(time <= 600) = 35;               % 35A fast-charge for first 10 min
I_profile(time > 600 & time <= 1200) = 10; % taper to 10A for remaining 10 min

%% 4. Memory Allocation with Initial Conditions
T = zeros(N_cells, length(time));
T(:, 1) = T_amb;

%% 5. Time Stepping Solver (Explicit Finite Difference)
for k = 1:(length(time)-1)
    I = I_profile(k);
    for i = 1:N_cells
        R_int = R0 - alpha * (T(i, k) - T_amb);
        Q_gen = (I^2) * R_int;

        if i == 1
            Q_left = 0; % insulated end
        else
            Q_left = (T(i, k) - T(i-1, k)) / R_cc;
        end

        if i == N_cells
            Q_right = (T(i, k) - T_cool) / R_cool; % only Cell 10 touches the chill plate
        else
            Q_right = (T(i, k) - T(i+1, k)) / R_cc;
        end

        dTdt = (Q_gen - Q_left - Q_right) / (m_cell * Cp_cell);
        T(i, k+1) = T(i, k) + dTdt * dt;
    end
end

%% 6. Visualizations
close all;

%Figure 1: Spatio temporal contour of temperature across the pack
fig1 = figure('Color', 'w', 'Position', [100, 100, 800, 500]);
[X, Y] = meshgrid(1:N_cells, time/60);
contourf(X, Y, T', 50, 'LineColor', 'none');
colormap(jet);

c = colorbar;
c.Label.String = 'Temperature (°C)';
c.Label.Color = 'k';
c.Color = 'k';
clim([20 135]); % covers the full range up to cell 1's peak

title('Module Thermal Gradient Profile Over Time', 'FontSize', 14, 'Color', 'k', 'FontWeight', 'bold');
xlabel('Cell Number (Cell 1: Insulated Base | Cell 10: End Cooled)', 'FontSize', 11, 'Color', 'k');
ylabel('Simulation Time (Minutes)', 'FontSize', 11, 'Color', 'k');

ax1 = gca;
ax1.Color = 'w';
ax1.XColor = 'k';
ax1.YColor = 'k';
set(ax1, 'XTick', 1:N_cells);
grid on;
ax1.GridColor = 'k';
ax1.GridAlpha = 0.15;

%Figure 2: Transient temperature at three representative cells
fig2 = figure('Color', 'w', 'Position', [150, 150, 800, 500]);
plot(time/60, T(1,:), 'r-', 'LineWidth', 2.5, 'DisplayName', 'Cell 1 (Worst Case - Far End)');
hold on;
plot(time/60, T(5,:), 'g-', 'LineWidth', 2.5, 'DisplayName', 'Cell 5 (Mid-Pack)');
plot(time/60, T(10,:), 'b-', 'LineWidth', 2.5, 'DisplayName', 'Cell 10 (Best Case - Near Coolant)');

yl = yline(45, '--k', 'Max Degradation Limit (45°C)', 'LineWidth', 1.5);
yl.Color = [0.2 0.2 0.2];

title('Transient Temperature Response — End-Cooled Architecture', 'FontSize', 14, 'Color', 'k', 'FontWeight', 'bold');
ylabel('Temperature (°C)', 'FontSize', 11, 'Color', 'k');
xlabel('Time (Minutes)', 'FontSize', 11, 'Color', 'k');

lgd = legend('Location', 'best');
lgd.TextColor = 'k';
lgd.Color = 'w';
lgd.EdgeColor = 'k';

ax2 = gca;
ax2.Color = 'w';
ax2.XColor = 'k';
ax2.YColor = 'k';
ylim([20 140]); % wide enough to show Cell 1's full peak
grid on;
ax2.GridColor = 'k';
ax2.GridAlpha = 0.15;
