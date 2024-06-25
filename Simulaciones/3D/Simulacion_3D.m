clear all;
clc;

%% Configuración del Mapa

% Cargar el mapa
% El mapa tiene medidas de 20 x 30
load("gridmap_20x20_scene1.mat");

% Tamaño del mapa
map_size = size(grid_map);
G = 1;

%% Establecer inicio y fin del mapa
% start and goal
start = [3, 2];
goal = [18, 29];

%% Establecer modo de simulación
% Definir el modo de simulación como variable global
global mode;
mode = "dynamic";

%% Crear la figura y el menú
fig = figure('Name', '3D Path Planning Simulation', 'NumberTitle', 'off');
setappdata(fig, 'grid_map', grid_map);
setappdata(fig, 'goal', goal);
setappdata(fig, 'start', start);
setappdata(fig, 'G', G);

% Crear el menú desplegable para seleccionar el algoritmo de planificación
algorithms = {'a_star', 'dijkstra', 'voronoi_plan', 'rrt_star', 'aco', 'd_star', 'ql', 'rrt', 'dstar_lite'};
uicontrol('Style', 'popupmenu', ...
          'String', algorithms, ...
          'Position', [20 340 100 50], ...
          'Callback', @setAlgorithm);

% Botón para iniciar la planificación
uicontrol('Style', 'pushbutton', 'String', 'Iniciar', ...
          'Position', [20 300 100 30], ...
          'Callback', @startPlanning);

% Variable global para el nombre del algoritmo seleccionado
global planner_name;
planner_name = algorithms{1}; % Valor por defecto

function setAlgorithm(src, ~)
    % Obtener el algoritmo seleccionado del menú desplegable
    global planner_name;
    val = src.Value;
    items = src.String;
    planner_name = items{val};
end

function startPlanning(~, ~)
    % Obtener el nombre del algoritmo seleccionado
    global planner_name;
    global mode;

    % Convertir el nombre del algoritmo a una función
    planner = str2func(planner_name);

    % Guardar el planificador en la figura
    setappdata(gcf, 'planner', planner);

    % Planifica la ruta, tomando como dato, mapa, punto inicial y objetivo
    grid_map = getappdata(gcf, 'grid_map');
    start = getappdata(gcf, 'start');
    goal = getappdata(gcf, 'goal');
    G = getappdata(gcf, 'G');

    [path, flag, cost, expand] = planner(grid_map, start, goal);

    setappdata(gcf, 'path', path);
    setappdata(gcf, 'cost', cost);
    setappdata(gcf, 'expand', expand);

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
    title([planner_name, " cost:" + num2str(cost)], 'Interpreter', 'none');

    hold off

    % Crear el carrito
    car = draw_cube(0, 0, 0.3, 'blue'); % Inicializamos el carrito pero lo actualizaremos en la posición correcta más adelante

    set(gcf, 'WindowButtonDownFcn', @mouseClick);

    if mode == "dynamic"
        current_position = start;
        keep_running = true;
        while keep_running
            path = getappdata(gcf, 'path');
            for i = 1:size(path, 1)
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

                % Re-planificación si se ha añadido un obstáculo
                if getappdata(gcf, 'obstacle_added')
                    grid_map = getappdata(gcf, 'grid_map');
                    planner = getappdata(gcf, 'planner');
                    goal = getappdata(gcf, 'goal');

                    % Re-planificación del mapa desde la posición actual del carrito
                    [path, flag, cost, expand] = planner(grid_map, current_position, goal);

                    % Guardar la nueva ruta y los datos de expansión
                    setappdata(gcf, 'path', path);
                    setappdata(gcf, 'cost', cost);
                    setappdata(gcf, 'expand', expand);

                    % Redibujar el mapa y la ruta
                    clf;
                    hold on
                    plot_grid_3d(grid_map);
                    plot_expand_3d(expand, G);
                    plot_path_3d(path, G);
                    draw_cube(start(2), start(1), 0.5, 'red');
                    draw_cube(goal(2), goal(1), 0.5, 'blue');
                    title([planner_name, " cost:" + num2str(cost)], 'Interpreter', 'none');
                    hold off

                    % Crear el carrito
                    car = draw_cube(path(1,2), path(1,1), 0.3, 'blue');

                    % Resetear el flag de obstáculo añadido
                    setappdata(gcf, 'obstacle_added', false);
                    break;
                end
            end

            if isequal(current_position, goal)
                keep_running = false;
            end
        end
    end
end

function mouseClick(~, ~)
    fig = gcf;
    [cx, cy, button] = ginput(1);
    if ~isempty(cx) && ~isempty(cy) && button == 1 % Solo responder al clic izquierdo
        % Obtener los datos necesarios desde la figura
        grid_map = getappdata(fig, 'grid_map');

        % Se redondea al valor entero más cercano para colocar su ubicación
        c = round([cy, cx]);

        % Cambiar el estado en el mapa si es una celda válida
        if c(1) > 0 && c(1) <= size(grid_map, 1) && c(2) > 0 && c(2) <= size(grid_map, 2)
            grid_map(c(1), c(2)) = 3 - grid_map(c(1), c(2));

            % Actualizar el mapa en la figura
            setappdata(fig, 'grid_map', grid_map);

            % Marcar que se ha añadido un obstáculo
            setappdata(fig, 'obstacle_added', true);
        end
    end
end

function plot_grid_3d(grid_map)
    [rows, cols] = size(grid_map);
    [X, Y] = meshgrid(1:cols, 1:rows);
    Z = zeros(size(X));
    
    % Crear una superficie para el suelo
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



