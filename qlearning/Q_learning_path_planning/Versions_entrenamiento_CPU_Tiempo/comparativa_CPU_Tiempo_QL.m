%% Código de prueba
clear all;
clc;

%% Configuración del Mapa
load("gridmap_20x30_scene1.mat");
map_size = size(grid_map);
G = 1;

%% Establecer inicio y fin del mapa Y, X
start = [3, 2];
goal = [18, 29];

%% Inicializar variables para almacenar resultados
algorithms = {'entrenamiento_q', 'entrenamiento_q_adaptativo', 'entrenamiento_q_opt'};
num_tests = 10;
execution_times = zeros(num_tests, length(algorithms));
cpu_usages = zeros(num_tests, length(algorithms));

%% Ejecutar y medir cada algoritmo
for i = 1:length(algorithms)
    algorithm = algorithms{i};
    fprintf('Ejecutando %s...\n', algorithm);
    
    for j = 1:num_tests
        fprintf('Prueba %d de %s...\n', j, algorithm);
        
        % Medir tiempo de ejecución
        tic;
        profile on; % Iniciar el perfilado
        feval(algorithm, grid_map, start, goal, 'q_table.mat');
        profile_info = profile('info'); % Obtener información del perfilado
        profile off; % Detener el perfilado
        execution_times(j, i) = toc;
        
        % Calcular el uso de CPU
        cpu_usages(j, i) = sum([profile_info.FunctionTable.TotalTime]); % Tiempo total de CPU usado
        
        % Reentrenar la tabla Q después de cambiar el mapa
        if j < num_tests
            clear Q;
        end
    end
end

%% Calcular promedio e intervalo de confianza
mean_execution_times = mean(execution_times);
ci_execution_times = 1.96 * std(execution_times) / sqrt(num_tests);

mean_cpu_usages = mean(cpu_usages);
ci_cpu_usages = 1.96 * std(cpu_usages) / sqrt(num_tests);

%% Graficar resultados
figure(1);

% Gráfico de tiempos de ejecución
bar(mean_execution_times);
hold on;
errorbar(1:length(algorithms), mean_execution_times, ci_execution_times, 'k', 'linestyle', 'none');
set(gca, 'xticklabel', algorithms);
ylabel('Tiempo de Ejecución (s)');
title('Comparación de Tiempos de Ejecución');
% Añadir los valores encima de cada barra
for i = 1:length(mean_execution_times)
    text(i, mean_execution_times(i), num2str(mean_execution_times(i), '%.2f'), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
end
hold off;

% Gráfico de uso de CPU
figure(2);
bar(mean_cpu_usages);
hold on;
errorbar(1:length(algorithms), mean_cpu_usages, ci_cpu_usages, 'k', 'linestyle', 'none');
set(gca, 'xticklabel', algorithms);
ylabel('Uso de CPU (s)');
title('Comparación de Uso de CPU');
% Añadir los valores encima de cada barra
for i = 1:length(mean_cpu_usages)
    text(i, mean_cpu_usages(i), num2str(mean_cpu_usages(i), '%.2f'), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
end
hold off;
