clear all;
clc;

%% Crear una ventana para seleccionar el algoritmo de planificación
prompt = 'Seleccione el algoritmo de planificación:';
options = {'a_star', 'dijkstra', 'theta_star', 'voronoi_plan', 'rrt_star', 'aco', 'd_star', 'qLearning_path', 'rrt', 'dstar_lite'};
[selection, ok] = listdlg('PromptString', prompt, 'SelectionMode', 'single', 'ListString', options);

if ~ok
    error('No se seleccionó ningún algoritmo. La simulación se ha cancelado.');
end

planner_name = options{selection};

%% Configuración del Mapa

% Cargar el mapa
% El mapa tiene medidas de 20 x 30
load("gridmap_20x20_scene1.mat");

% Tamaño del mapa
map_size = size(grid_map);
G = 1;

%% Establecer inicio y fin del mapa
% start and goal
start = [2, 2];
goal = [18, 28];

%% Establecer modo de simulación
% simulation mode
mode = "dynamic";

%% Establecer el algoritmo de planeación
% planner
planner = str2func(planner_name);

% Guardar el mapa y otros datos en la figura
fig = figure('Name', '3D Path Planning Simulation', 'NumberTitle', 'off');
setappdata(fig, 'grid_map', grid_map);
setappdata(fig, 'planner', planner);
setappdata(fig, 'goal', goal);
setappdata(fig, 'start', start);
setappdata(fig, 'G', G);

% Planifica la ruta, tomando como dato, mapa, punto inicial y objetivo
[path, flag, cost, expand] = planner(grid_map, start, goal);
flag

setappdata(fig, 'path', path);
setappdata(fig, 'cost', cost);
setappdata(fig, 'expand', expand);

%% Visualización según el modo de funcionamiento
hold on

% plot grid map
plot_grid_3d(grid_map);

% plot expand zone
plot_expand_3d(expand, G);

% plot path
plot_path_3d(path, G);

% plot start and goal
draw_cube(start(2), start(1), 0.5, 'red');
draw_cube(goal(2), goal(1), 0.5, 'blue');

% title
title([planner_name, " cost:" + num2str(cost)], 'Interpreter','none');

% Crear el carrito en la posición inicial
car = draw_cube(start(2), start(1), 0.3, 'blue'); % Inicializamos el carrito en la posición inicial

hold off

set(fig, 'WindowButtonDownFcn', @mouseClick);

if mode == "dynamic"
    current_position = start;
    keep_running = true;
    while keep_running
        path = getappdata(fig, 'path');

        i = 1;
        while i <= size(path, 1)
            % Verificar si el siguiente paso tiene un obstáculo
            if i < size(path, 1) && grid_map(path(i + 1, 1), path(i + 1, 2)) == 2
                planner = getappdata(fig, 'planner');
                goal = getappdata(fig, 'goal');

                % Re-planificación del mapa desde la posición actual del carrito
                [path, flag, cost, expand] = planner(grid_map, current_position, goal);

                % Guardar la nueva ruta y los datos de expansión
                setappdata(fig, 'path', path);
                setappdata(fig, 'cost', cost);
                setappdata(fig, 'expand', expand);

                % Redibujar el mapa y la ruta
                clf;
                hold on
                plot_grid_3d(grid_map);
                plot_expand_3d(expand, G);
                plot_path_3d(path, G);
                draw_cube(start(2), start(1), 0.5, 'red');
                draw_cube(goal(2), goal(1), 0.5, 'blue');
                title([planner_name, " cost:" + num2str(cost)], 'Interpreter','none');
                hold off

                % Crear el carrito
                car = draw_cube(path(1, 2), path(1, 1), 0.3, 'blue');
                
                % Reiniciar el índice para seguir el nuevo camino
                i = 1;
                current_position = path(i, :);
                continue;
            end

            % Actualizar la posición del carrito
            current_position = path(i, :);
            x = current_position(2);
            y = current_position(1);
            z = 0; % Ajustamos la altura del carrito para que esté en la misma superficie que el mapa

            % Actualizar las coordenadas del carrito
            vertices = [x-0.3, y-0.3, z; x+0.3, y-0.3, z; x+0.3, y+0.3, z; x-0.3, y+0.3, z;
                        x-0.3, y-0.3, z+0.3; x+0.3, y-0.3, z+0.3; x+0.3, y+0.3, z+0.3; x-0.3, y+0.3, z+0.3];
            set(car, 'Vertices', vertices);
            
            pause(0.5); % Pausar para crear la animación

            % Añadir un obstáculo aleatorio
            grid_map = getappdata(fig, 'grid_map');
            [rows, cols] = size(grid_map);
            random_position = [randi([1, rows]), randi([1, cols])];

            % Asegurarse de que la posición aleatoria no sea un obstáculo ya existente
            while grid_map(random_position(1), random_position(2)) == 2 || ...
                  isequal(random_position, current_position) || ...
                  isequal(random_position, goal)
                random_position = [randi([1, rows]), randi([1, cols])];
            end
            grid_map(random_position(1), random_position(2)) = 2;

            % Guardar el mapa actualizado
            setappdata(fig, 'grid_map', grid_map);

            % Dibujar el nuevo obstáculo
            hold on
            draw_cube(random_position(2), random_position(1), 0.5, [0.3 0.3 0.3]); % Color gris oscuro para los obstáculos
            hold off
            
            i = i + 1;
        end

        if isequal(current_position, goal)
            keep_running = false;
        end
    end
end

function mouseClick(~, ~)
    % No se hace nada en la función de clic del ratón
end

function plot_grid_3d(grid_map)
    [rows, cols] = size(grid_map);
    [X, Y] = meshgrid(1:cols, 1:rows);
    Z = zeros(size(X));
    
    % Crear una superficie para el suelo
    surf(X+0.5, Y+0.5, Z, 'FaceColor', [0.9 0.9 0.9], 'EdgeColor', 'none'); % Color gris claro para el suelo
    surf(X-0.5, Y-0.5, Z, 'FaceColor', [0.9 0.9 0.9], 'EdgeColor', 'none'); % Color gris claro para el suelo
    hold on;
    
    for i = 1:rows
        for j = 1:cols
            if grid_map(i, j) == 2
                % Dibujar los obstáculos como cubos sólidos con altura
                draw_cube(j, i, 0.5, [0.3 0.3 0.3]); % Color gris oscuro para los obstáculos
            end
        end
    end
    
    % Ajustar la iluminación para mejor visualización
    camlight('headlight');
    lighting phong;
    view(3); % Vista en 3D
    axis equal;
    grid on;
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
end

function h = draw_cube(x, y, side, color)
    % Crear y dibujar un cubo centrado en (x, y) con un tamaño especificado y un color dado
    vertices = [x-side, y-side, 0; x+side, y-side, 0; x+side, y+side, 0; x-side, y+side, 0;
                x-side, y-side, side; x+side, y-side, side; x+side, y+side, side; x-side, y+side, side];
    faces = [1, 2, 3, 4; 5, 6, 7, 8; 1, 2, 6, 5; 2, 3, 7, 6; 3, 4, 8, 7; 4, 1, 5, 8];
    h = patch('Vertices', vertices, 'Faces', faces, 'FaceColor', color, 'EdgeColor', 'none');
end

function plot_expand_3d(expand, G)
    % Dibujar los nodos expandidos
    if ~isempty(expand)
        for i = 1:size(expand, 1)
            plot3(expand(i, 2), expand(i, 1), G, 'o', 'MarkerEdgeColor', 'k', ...
                'MarkerFaceColor', 'g', 'MarkerSize', 6);
        end
    end
end

function plot_path_3d(path, G)
    % Dibujar la ruta
    if ~isempty(path)
        plot3(path(:, 2), path(:, 1), zeros(size(path, 1), 1), '-r', 'LineWidth', 2);
    end
end


