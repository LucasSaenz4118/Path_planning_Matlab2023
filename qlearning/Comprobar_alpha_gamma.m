%% Script desarrollado para validar cuáles son los mejores valores de alpha y gamma para q-learning
% Nota: Para probar con entrenamiento_q.m se debe cambiar los parámetros de
%ingreso que recibe este script
clear;
clc;

%% Configuración del Mapa
load("gridmap_20x20_scene1.mat");
map_size = size(grid_map);

%% Establecer inicio y fin del mapa

start = [3, 2];
goal = [18, 29];
% Ingreso de puntos de inicio y fin del mapa aleatorios
% while true
%     start = randi([1, 20], 1, 2);
%     goal = randi([1, 20], 1, 2);
%     distance = sqrt((start(1) - goal(1))^2 + (start(2) - goal(2))^2);
%     if grid_map(start(1), start(2)) ~= 2 && grid_map(goal(1), goal(2)) ~= 2 && distance >= 6
%         break;
%     end
% end

%% Parámetros para la prueba de alpha y gamma con pasos ajustados
alpha_values = 0.1:0.1:1.0;  % Paso ajustado para alpha
gamma_values = 0.5:0.05:0.99;  % Paso ajustado para gamma

%% Crear la carpeta para almacenar los archivos temporales
output_folder = 'Q_tables';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

%% Crear la carpeta para almacenar las gráficas
output_graphs_folder = 'Graphs';
if ~exist(output_graphs_folder, 'dir')
    mkdir(output_graphs_folder);
end

%% Matriz para almacenar los resultados
results = cell(length(alpha_values), length(gamma_values));

%% Bucle para probar cada combinación de alpha y gamma
for i = 1:length(alpha_values)
    local_results = cell(1, length(gamma_values));
    for j = 1:length(gamma_values)
        alpha = alpha_values(i);
        gamma = gamma_values(j);

        % Crear un archivo temporal para almacenar la tabla Q en la carpeta especificada
        timestamp = datestr(now, 'yyyymmddTHHMMSSFFF'); % Timestamp para evitar superposición
        temp_filename = fullfile(output_folder, sprintf('Q_table_alpha_%0.2f_gamma_%0.2f_%s.mat', alpha, gamma, timestamp));

        % Ejecutar el entrenamiento con los valores actuales de alpha y gamma
        tic
        entrenamiento_q_adaptativo_wrapper(grid_map, start, goal, temp_filename, alpha, gamma);
        toc
        % Evaluar el rendimiento del agente
        tic
        [path, flag, cost] = qLearning_wrapper(grid_map, start, goal, temp_filename);
        toc
        % Almacenar los resultados locales en una celda
        local_results{j} = [alpha, gamma, cost, flag];
    end
    results(i, :) = local_results;
end

% Convertir la matriz de celdas en una matriz numérica
results_matrix = cell2mat(results(:));

% Encontrar los mejores valores de alpha y gamma
[~, idx] = min(results_matrix(:, 3));
best_alpha = results_matrix(idx, 1);
best_gamma = results_matrix(idx, 2);
best_performance = results_matrix(idx, 3);
best_flag = results_matrix(idx, 4);

% Imprimir los mejores valores encontrados
%fprintf('Mejores valores encontrados: Alpha = %f, Gamma = %f con un costo de %f y flag = %d\n', best_alpha, best_gamma, best_performance, best_flag);

% Contabilizar cuántas veces cada combinación de alpha y gamma produce cada costo
unique_costs = unique(results_matrix(:, 3));
cost_counts = zeros(length(unique_costs), 1);
alpha_gamma_combinations = cell(length(unique_costs), 1);
flags = cell(length(unique_costs), 1);

for k = 1:length(unique_costs)
    idxs = results_matrix(:, 3) == unique_costs(k);
    cost_counts(k) = sum(idxs);
    alpha_gamma_combinations{k} = results_matrix(idxs, 1:2);
    flags{k} = results_matrix(idxs, 4);
end

% Imprimir el resumen de los resultados
fprintf('\nResumen de Costos:\n');
for k = 1:length(unique_costs)
    fprintf('Costo: %f, Frecuencia: %d\n', unique_costs(k), cost_counts(k));
    combinations = alpha_gamma_combinations{k};
    combination_flags = flags{k};
    for m = 1:size(combinations, 1)
        fprintf('  Alpha: %0.2f, Gamma: %0.2f, Flag: %d\n', combinations(m, 1), combinations(m, 2), combination_flags(m));
    end
end

% Crear gráfico de barras para comparar los resultados
figure;
bar(results_matrix(:, 3));
xlabel('Combinación (Alpha, Gamma)');
ylabel('Costo');
title('Comparativa de Costos para diferentes valores de Alpha y Gamma');

% Etiquetar las combinaciones en el eje X
xticks(1:length(results_matrix));
xticklabels(arrayfun(@(x) sprintf('(%0.2f, %0.2f)', results_matrix(x, 1), results_matrix(x, 2)), 1:length(results_matrix), 'UniformOutput', false));
xtickangle(45);

% Guardar la gráfica en un archivo EPS
graph_filename = fullfile(output_graphs_folder, sprintf('Comparativa_Costos_%s_8000EP.eps', datestr(now, 'yyyymmddTHHMMSSFFF')));
saveas(gcf, graph_filename, 'epsc');

% Guardar los resultados en un archivo para referencia futura
results_filename = fullfile(output_folder, 'resultados_alpha_gamma_adaptativo.mat');
save(results_filename, 'results_matrix');
writematrix(results_matrix,'resultados.xlsx');

%% Función Wrapper para entrenamiento_q_adaptativo
function entrenamiento_q_adaptativo_wrapper(map, start, goal, filename, alpha, gamma)
    %entrenamiento_q_adaptativo(map, start, goal, filename, alpha, gamma);
    entrenamiento_q(map, start, goal, filename, alpha, gamma);
end

%% Función Wrapper para qLearning
function [path, flag, cost] = qLearning_wrapper(map, start, goal, filename)
    [path, flag, cost] = qLearning(map, start, goal, filename);
end
    