%% Código de prueba
clear;
clc;

%% Configuración del Mapa
load("gridmap_20x30_scene1.mat");
map_size = size(grid_map);
G = 1;

%% Establecer inicio y fin del mapa Y, X

start = [3, 2];
goal = [18, 29];
    % while true
    %     % Generar coordenadas aleatorias dentro de un mapa de 20x30
    %     start = [randi([1, 20]), randi([1, 30])];
    %     goal = [randi([1, 20]), randi([1, 30])];
    % 
    %     distance = sqrt((start(1) - goal(1))^2 + (start(2) - goal(2))^2);
    %     if grid_map(start(1), start(2)) ~= 2 && grid_map(goal(1), goal(2)) ~= 2 && distance >= 6
    %         break;
    %     end
    % end
    % start
    % goal

%% Establecer modo de simulación
mode = "dynamic";

%% Entrenamiento inicial de la tabla Q (esto se hace una vez)
tic                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
%entrenamiento_q_opt(grid_map, start, goal, 'q_table.mat');
[path, flag, cost, expand]=qLearning_path(grid_map, start, goal);
%entrenamiento_q_adaptativo(grid_map, start, goal, 'q_table.mat');
toc

%% Visualización según el modo de funcionamiento
if mode == "dynamic"
    while (1)
        clf; hold on

        % plot grid map
        plot_grid(grid_map);
        
       % plot expand zone
        plot_expand(expand, map_size, G, "ql");
        
        %tic
        %[path, flag, cost] = qLearning(grid_map, start, goal, 'q_table.mat');
        %toc
        plot_path(path, G);

        % plot start and goal
        plot_square(start, map_size, G, "#f00");
        plot_square(goal, map_size, G, "#15c");

        % title
        title("Q-learning costo:" + num2str(cost), 'Interpreter','none');
%         title([planner_name, "cost:" + num2str(cost)], 'Interpreter','none');

        hold off

        % Tomar entrada del cursor
        p = ginput(1);
        if size(p, 1) == 0
            break;
        else
            c = floor(p);
            grid_map(c(2), c(1)) = 3 - grid_map(c(2), c(1));
            % Reentrenar la tabla Q después de cambiar el mapa
            tic
            %entrenamiento_q_adaptativo(grid_map, start, goal, 'q_table.mat');
            [path, flag, cost, expand]=qLearning_path(grid_map, start, goal);
            %entrenamiento_q_opt(grid_map, start, goal, 'q_table.mat');
            toc
        end
    end
end
