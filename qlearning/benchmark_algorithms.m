% clc;
% clear;
% close all;
% 
% % Parámetros del entorno y puntos de inicio y objetivo
% load("gridmap_20x30_scene1.mat");
% map_size = size(grid_map);
% original_map = grid_map; % Guardar el mapa original
% G = 1;
% 
% %% Establecer inicio y fin del mapa Y, X
% start = [3, 2];
% goal = [18, 29];
% 
% % Lista de algoritmos a comparar
% algorithms = {'Q_Learning', 'A_Star', 'Dijkstra', 'D_Star', 'RRT', 'D_StarLite'};
% numAlgorithms = length(algorithms);
% 
% % Parámetros para añadir obstáculos
% numIterations = 5; % Número de iteraciones para añadir obstáculos
% obstaclesPerIteration = 8; % Número de obstáculos a añadir en cada iteración
% 
% % Inicialización de resultados
% results = struct();
% maps = cell(numIterations, 1); % Para almacenar mapas de cada iteración
% 
% % Generar posiciones de obstáculos evitando start y goal
% obstacle_positions = [];
% while size(obstacle_positions, 1) < numIterations * obstaclesPerIteration
%     pos = randi([1, min(map_size)], 1, 2);
%     if ~ismember(pos, [start; goal], 'rows')
%         obstacle_positions = [obstacle_positions; pos];
%     end
% end
% 
% % Ejecución de cada iteración
% for iter = 1:numIterations
%     % Crear una copia del mapa original y añadir obstáculos acumulativos
%     map = original_map;
% 
%     % Añadir obstáculos adicionales acumulativos hasta esta iteración
%     obstacle_end_index = iter * obstaclesPerIteration;
%     current_obstacles = obstacle_positions(1:obstacle_end_index, :);
% 
%     for i = 1:size(current_obstacles, 1)
%         map(current_obstacles(i, 1), current_obstacles(i, 2)) = 2;
%     end
% 
%     % Almacenar el mapa de la iteración actual
%     maps{iter} = map;
% 
%     % Ejecución de cada algoritmo
%     for j = 1:numAlgorithms
%         alg = algorithms{j};
%          % Iniciar el temporizador
%         tic;
%          switch alg
%             case 'Q_Learning'
%                 %entrenamiento_q_opt(map, start, goal, 'q_table.mat');
%                 [path, flag, cost, expand] = qLearning_path(map, start, goal);
%                 %[path, flag, cost] = qLearning(map, start, goal, 'q_table.mat');
%             case 'A_Star'
% 
%                 [path, flag, cost, EXPAND] = a_star(map, start, goal);
%             case 'Dijkstra'
% 
%                 [path, flag, cost, EXPAND] = dijkstra(map, start, goal);
%             case 'D_StarLite'
% 
%                 [path, flag, cost, EXPAND] = dstar_lite(map, start, goal);
%             case 'D_Star'
%                 clear d_star;
% 
%                 [path, flag, cost, EXPAND] = d_star(map, start, goal);
%             case 'RRT'
% 
%                 [path, flag, cost, EXPAND] = rrt(map, start, goal);
%             otherwise
%                 error('Algoritmo desconocido');
%         end
% 
%         % Guardar resultados
%         results(iter).(alg).cost = cost;
%         results(iter).(alg).flag = flag;
%         results(iter).(alg).path = path;
%         results(iter).(alg).pathLength = size(path, 1); % Longitud del camino
%         results(iter).(alg).executionTime = toc; % Tiempo de ejecución
%     end
% end
% 
% % Comparación de resultados
% fprintf('Comparación de Algoritmos por Iteración:\n');
% fprintf('Iteración\tAlgoritmo\tCosto\tÉxito\tLongitud\tTiempo\n');
% for iter = 1:numIterations
%     for j = 1:numAlgorithms
%         alg = algorithms{j};
%         fprintf('%d\t\t%s\t\t%.2f\t%d\t%d\t\t%.2f\n', ...
%             iter, alg, results(iter).(alg).cost, results(iter).(alg).flag, ...
%             results(iter).(alg).pathLength, results(iter).(alg).executionTime);
%     end
% end
% 
% % Visualización de resultados
% for iter = 1:numIterations
%     figure;
%     sgtitle(sprintf('Comparación de Algoritmos de Planificación de Rutas - Iteración %d', iter));
%     for j = 1:numAlgorithms
%         alg = algorithms{j};
%         subplot(3, 2, j);
%         imagesc(maps{iter}); hold on;
%         plot(start(2), start(1), 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
%         plot(goal(2), goal(1), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
%         plot(results(iter).(alg).path(:,2), results(iter).(alg).path(:,1), 'b', 'LineWidth', 2);
%         title(sprintf('%s (Costo: %.2f, Longitud: %d)', ...
%             alg, results(iter).(alg).cost, results(iter).(alg).pathLength));
%     end
% end
% 
% % Guardar resultados en un archivo
% save('benchmark_results.mat', 'results', 'maps');
% 
% % Cálculo de medias y intervalos de confianza
% means = struct();
% conf_intervals = struct();
% 
% for j = 1:numAlgorithms
%     alg = algorithms{j};
%     costs = [];
%     pathLengths = [];
%     executionTimes = [];
%     for iter = 1:numIterations
%         costs = [costs, results(iter).(alg).cost];
%         pathLengths = [pathLengths, results(iter).(alg).pathLength];
%         executionTimes = [executionTimes, results(iter).(alg).executionTime];
%     end
%     means.(alg).cost = mean(costs);
%     means.(alg).pathLength = mean(pathLengths);
%     means.(alg).executionTime = mean(executionTimes);
% 
%     % Cálculo del intervalo de confianza del 95%
%     conf_intervals.(alg).cost = 1.96 * (std(costs) / sqrt(numIterations));
%     conf_intervals.(alg).pathLength = 1.96 * (std(pathLengths) / sqrt(numIterations));
%     conf_intervals.(alg).executionTime = 1.96 * (std(executionTimes) / sqrt(numIterations));
% end
% 
% % Visualización de medias y intervalos de confianza con gráfico de barras
% figure;
% 
% % Definir colores
% colors = repmat([0, 0.5, 1], numAlgorithms, 1); % Azul marino por defecto
% colors(1, :) = [1, 0, 0]; % Rojo para Q_Learning
% colors(6, :) = [1, 0, 0]; % Rojo para D_StarLite
% 
% % Costo
% subplot(3, 1, 1);
% bar_data = [means.Q_Learning.cost, means.A_Star.cost, means.Dijkstra.cost, means.D_Star.cost, means.RRT.cost, means.D_StarLite.cost];
% b = bar(bar_data, 'FaceColor', 'flat');
% for k = 1:numAlgorithms
%     b.CData(k, :) = colors(k, :);
% end
% hold on;
% errorbar(1:numAlgorithms, bar_data, [conf_intervals.Q_Learning.cost, conf_intervals.A_Star.cost, conf_intervals.Dijkstra.cost, conf_intervals.D_Star.cost, conf_intervals.RRT.cost, conf_intervals.D_StarLite.cost], '.k');
% ylabel('Costo');
% xticks(1:numAlgorithms);
% xticklabels(algorithms);
% 
% % Longitud del Camino
% subplot(3, 1, 2);
% bar_data = [means.Q_Learning.pathLength, means.A_Star.pathLength, means.Dijkstra.pathLength, means.D_Star.pathLength, means.RRT.pathLength, means.D_StarLite.pathLength];
% b = bar(bar_data, 'FaceColor', 'flat');
% for k = 1:numAlgorithms
%     b.CData(k, :) = colors(k, :);
% end
% hold on;
% errorbar(1:numAlgorithms, bar_data, [conf_intervals.Q_Learning.pathLength, conf_intervals.A_Star.pathLength, conf_intervals.Dijkstra.pathLength, conf_intervals.D_Star.pathLength, conf_intervals.RRT.pathLength, conf_intervals.D_StarLite.pathLength], '.k');
% ylabel('Longitud del Camino');
% xticks(1:numAlgorithms);
% xticklabels(algorithms);
% 
% % Tiempo de Ejecución
% subplot(3, 1, 3);
% bar_data = [means.Q_Learning.executionTime, means.A_Star.executionTime, means.Dijkstra.executionTime, means.D_Star.executionTime, means.RRT.executionTime, means.D_StarLite.executionTime];
% b = bar(bar_data, 'FaceColor', 'flat');
% for k = 1:numAlgorithms
%     b.CData(k, :) = colors(k, :);
% end
% hold on;
% errorbar(1:numAlgorithms, bar_data, [conf_intervals.Q_Learning.executionTime, conf_intervals.A_Star.executionTime, conf_intervals.Dijkstra.executionTime, conf_intervals.D_Star.executionTime, conf_intervals.RRT.executionTime, conf_intervals.D_StarLite.executionTime], '.k');
% ylabel('Tiempo de Ejecución');
% xticks(1:numAlgorithms);
% xticklabels(algorithms);
% 
% sgtitle('Rendimiento Medio y Variabilidad de Algoritmos de Planificación de Rutas');
% 
% 
% % Comparación adicional: Desviación estándar
% figure;
% 
% % Definir colores
% colors = repmat([0, 0.5, 1], numAlgorithms, 1); % Azul claro por defecto
% colors(1, :) = [1, 0, 0]; % Rojo para Q_Learning
% colors(6, :) = [1, 0, 0]; % Rojo para D_StarLite
% 
% % Desviación estándar del costo
% subplot(3, 1, 1);
% std_data = [std_devs.Q_Learning.cost, std_devs.A_Star.cost, std_devs.Dijkstra.cost, std_devs.D_Star.cost, std_devs.RRT.cost, std_devs.D_StarLite.cost];
% b = bar(std_data, 'FaceColor', 'flat');
% for k = 1:numAlgorithms
%     b.CData(k, :) = colors(k, :);
% end
% ylabel('Desviación Estándar del Costo');
% xticks(1:numAlgorithms);
% xticklabels(algorithms);
% 
% % Desviación estándar de la longitud del camino
% subplot(3, 1, 2);
% std_data = [std_devs.Q_Learning.pathLength, std_devs.A_Star.pathLength, std_devs.Dijkstra.pathLength, std_devs.D_Star.pathLength, std_devs.RRT.pathLength, std_devs.D_StarLite.pathLength];
% b = bar(std_data, 'FaceColor', 'flat');
% for k = 1:numAlgorithms
%     b.CData(k, :) = colors(k, :);
% end
% ylabel('Desviación Estándar de la Longitud del Camino');
% xticks(1:numAlgorithms);
% xticklabels(algorithms);
% 
% % Desviación estándar del tiempo de ejecución
% subplot(3, 1, 3);
% std_data = [std_devs.Q_Learning.executionTime, std_devs.A_Star.executionTime, std_devs.Dijkstra.executionTime, std_devs.D_Star.executionTime, std_devs.RRT.executionTime, std_devs.D_StarLite.executionTime];
% b = bar(std_data, 'FaceColor', 'flat');
% for k = 1:numAlgorithms
%     b.CData(k, :) = colors(k, :);
% end
% ylabel('Desviación Estándar del Tiempo de Ejecución');
% xticks(1:numAlgorithms);
% xticklabels(algorithms);
% 
% sgtitle('Desviaciones Estándar de los Algoritmos');

clc;
clear;
close all;

% Parámetros del entorno y puntos de inicio y objetivo
load("gridmap_20x20_save5.mat");
map_size = size(grid_map);
original_map = grid_map; % Guardar el mapa original
G = 1;

%% Establecer inicio y fin del mapa Y, X
start = [3, 2];
goal = [18, 19];

% Lista de algoritmos a comparar
algorithms = {'Q_Learning', 'A_Star', 'Dijkstra', 'D_Star', 'RRT', 'D_StarLite'};
numAlgorithms = length(algorithms);

% Parámetros para añadir obstáculos
numIterations = 50; % Número de iteraciones para añadir obstáculos
obstaclesPerIteration = 1; % Número de obstáculos a añadir en cada iteración

% Inicialización de resultados
results = struct();
maps = cell(numIterations, 1); % Para almacenar mapas de cada iteración

% Generar posiciones de obstáculos evitando start y goal
obstacle_positions = [];
while size(obstacle_positions, 1) < numIterations * obstaclesPerIteration
    pos = randi([1, min(map_size)], 1, 2);
    if ~ismember(pos, [start; goal], 'rows')
        obstacle_positions = [obstacle_positions; pos];
    end
end

% Ejecución de cada iteración
for iter = 1:numIterations
    % Crear una copia del mapa original y añadir obstáculos acumulativos
    map = original_map;
    
    % Añadir obstáculos adicionales acumulativos hasta esta iteración
    obstacle_end_index = iter * obstaclesPerIteration;
    current_obstacles = obstacle_positions(1:obstacle_end_index, :);
    
    for i = 1:size(current_obstacles, 1)
        map(current_obstacles(i, 1), current_obstacles(i, 2)) = 2;
    end
    
    % Almacenar el mapa de la iteración actual
    maps{iter} = map;
    
    % Ejecución de cada algoritmo
    for j = 1:numAlgorithms
        alg = algorithms{j};
         % Iniciar el temporizador
        tic;
         switch alg
            case 'Q_Learning'
                %entrenamiento_q_opt(map, start, goal, 'q_table.mat');
                [path, flag, cost, expand] = qLearning_path(map, start, goal);
                %[path, flag, cost] = qLearning(map, start, goal, 'q_table.mat');
            case 'A_Star'
              
                [path, flag, cost, EXPAND] = a_star(map, start, goal);
            case 'Dijkstra'
                
                [path, flag, cost, EXPAND] = dijkstra(map, start, goal);
            case 'D_StarLite'
               
                [path, flag, cost, EXPAND] = dstar_lite(map, start, goal);
            case 'D_Star'
                clear d_star;
               
                [path, flag, cost, EXPAND] = d_star(map, start, goal);
            case 'RRT'
               
                [path, flag, cost, EXPAND] = rrt(map, start, goal);
            otherwise
                error('Algoritmo desconocido');
        end
        
        % Guardar resultados
        results(iter).(alg).cost = cost;
        results(iter).(alg).flag = flag;
        results(iter).(alg).path = path;
        results(iter).(alg).pathLength = size(path, 1); % Longitud del camino
        results(iter).(alg).executionTime = toc; % Tiempo de ejecución
    end
    fprintf("Simulación %d\n", iter);
end

% Comparación de resultados
fprintf('Comparación de Algoritmos por Iteración:\n');
fprintf('Iteración\tAlgoritmo\tCosto\tÉxito\tLongitud\tTiempo\n');
for iter = 1:numIterations
    for j = 1:numAlgorithms
        alg = algorithms{j};
        fprintf('%d\t\t%s\t\t%.2f\t%d\t%d\t\t%.2f\n', ...
            iter, alg, results(iter).(alg).cost, results(iter).(alg).flag, ...
            results(iter).(alg).pathLength, results(iter).(alg).executionTime);
    end
end

% Visualización de resultados
for iter = 1:numIterations
    figure;
    sgtitle(sprintf('Comparación de Algoritmos de Planificación de Rutas - Iteración %d', iter));
    for j = 1:numAlgorithms
        alg = algorithms{j};
        subplot(3, 2, j);
        imagesc(maps{iter}); hold on;
        % Definir un colormap personalizado
        customColormap = [1 1 1; % Blanco para el espacio libre
                          0 0 0]; % Negro para los obstáculos
        colormap(customColormap);
        clim([1 2]); % Ajustar el rango de valores del mapa a [0, 1]
        plot(start(2), start(1), 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
        plot(goal(2), goal(1), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
        plot(results(iter).(alg).path(:,2), results(iter).(alg).path(:,1), 'c', 'LineWidth', 2);
        title(sprintf('%s (Costo: %.2f, Longitud: %d)', ...
            alg, results(iter).(alg).cost, results(iter).(alg).pathLength));
    end
end

% Guardar resultados en un archivo
save('benchmark_results.mat', 'results', 'maps');

% Cálculo de medias y intervalos de confianza
means = struct();
conf_intervals = struct();

for j = 1:numAlgorithms
    alg = algorithms{j};
    costs = [];
    pathLengths = [];
    executionTimes = [];
    for iter = 1:numIterations
        costs = [costs, results(iter).(alg).cost];
        pathLengths = [pathLengths, results(iter).(alg).pathLength];
        executionTimes = [executionTimes, results(iter).(alg).executionTime];
    end
    means.(alg).cost = mean(costs);
    means.(alg).pathLength = mean(pathLengths);
    means.(alg).executionTime = mean(executionTimes);
    
    % Cálculo del intervalo de confianza del 95%
    conf_intervals.(alg).cost = 1.96 * (std(costs) / sqrt(numIterations));
    conf_intervals.(alg).pathLength = 1.96 * (std(pathLengths) / sqrt(numIterations));
    conf_intervals.(alg).executionTime = 1.96 * (std(executionTimes) / sqrt(numIterations));
end

% Visualización de medias y intervalos de confianza con gráfico de barras
figure(numIterations+1);

% Definir colores
colors = repmat([0, 0.5, 1], numAlgorithms, 1); % Azul claro por defecto
colors(1, :) = [1, 0, 0]; % Rojo para Q_Learning
colors(6, :) = [1, 0, 0]; % Rojo para D_StarLite

% Costo
%subplot(3, 1, 1);
bar_data = [means.Q_Learning.cost, means.A_Star.cost, means.Dijkstra.cost, means.D_Star.cost, means.RRT.cost, means.D_StarLite.cost];
b = bar(bar_data, 'FaceColor', 'flat');
for k = 1:numAlgorithms
    b.CData(k, :) = colors(k, :);
end
hold on;
errorbar(1:numAlgorithms, bar_data, [conf_intervals.Q_Learning.cost, conf_intervals.A_Star.cost, conf_intervals.Dijkstra.cost, conf_intervals.D_Star.cost, conf_intervals.RRT.cost, conf_intervals.D_StarLite.cost], '.k');
ylabel('Costo');
xticks(1:numAlgorithms);
xticklabels(algorithms);
title("Benchmark de Costos de Ruta");
% Longitud del Camino
%subplot(3, 1, 2);


figure(numIterations+2);
bar_data = [means.Q_Learning.pathLength, means.A_Star.pathLength, means.Dijkstra.pathLength, means.D_Star.pathLength, means.RRT.pathLength, means.D_StarLite.pathLength];
b = bar(bar_data, 'FaceColor', 'flat');
for k = 1:numAlgorithms
    b.CData(k, :) = colors(k, :);
end
hold on;
errorbar(1:numAlgorithms, bar_data, [conf_intervals.Q_Learning.pathLength, conf_intervals.A_Star.pathLength, conf_intervals.Dijkstra.pathLength, conf_intervals.D_Star.pathLength, conf_intervals.RRT.pathLength, conf_intervals.D_StarLite.pathLength], '.k');
ylabel('Longitud del Camino');
xticks(1:numAlgorithms);
xticklabels(algorithms);
title("Benchmark de Longitud de Ruta");

% Tiempo de Ejecución
figure(numIterations+3);
%subplot(3, 1, 3);
bar_data = [means.Q_Learning.executionTime, means.A_Star.executionTime, means.Dijkstra.executionTime, means.D_Star.executionTime, means.RRT.executionTime, means.D_StarLite.executionTime];
b = bar(bar_data, 'FaceColor', 'flat');
for k = 1:numAlgorithms
    b.CData(k, :) = colors(k, :);
end
hold on;
errorbar(1:numAlgorithms, bar_data, [conf_intervals.Q_Learning.executionTime, conf_intervals.A_Star.executionTime, conf_intervals.Dijkstra.executionTime, conf_intervals.D_Star.executionTime, conf_intervals.RRT.executionTime, conf_intervals.D_StarLite.executionTime], '.k');
ylabel('Tiempo de Ejecución');
xticks(1:numAlgorithms);
xticklabels(algorithms);
title("Benchmark de Tiempos de Ejecución");
%sgtitle('Rendimiento Medio y Variabilidad de Algoritmos de Planificación de Rutas');