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

%Tamaño del mapa
map_size = size(grid_map);
G = 1;

%% Establecer inicio y fin del mapa
% start and goal
start = [3, 2];
goal = [18,29];

%% Establecer modo de simulación
% simulation mode
mode = "dynamic";

%% Establecer el algoritmo de planeación
% planner  
%planner_name = "a_star";
%planner_name = "dijkstra";
% planner_name = "theta_star";
% planner_name = "voronoi_plan";
%planner_name = "rrt_star";
% planner_name = "aco";
%planner_name = "d_star";
%planner_name = "qLearning_path";
%planner_name = "rrt";
%planner_name = "dstar_lite";
%
%Almacena el  tipo de algoritmo a usar, hecho función
planner = str2func(planner_name);
% Planifica la ruta, tomando como dato, mapa, punto inicial y objetivo
[path, flag, cost, expand] = planner(grid_map, start, goal);


expand;

%% Visualizacion según el modo de funcionamiento
if mode == "dynamic"
    while (1)
        clf; hold on

        % plot grid map
        plot_grid(grid_map);

        % plot expand zone
        plot_expand(expand, map_size, G, planner_name);

        % plot path
        plot_path(path, G);

        % plot start and goal
        plot_square(start, map_size, G, "#f00");
        plot_square(goal, map_size, G, "#15c");

        % title
        title([planner_name, "cost:" + num2str(cost)], 'Interpreter','none');

        hold off

        % Tomar entrada del cursor
        p = ginput(1);
        if size(p, 1) == 0
            % ENTER significa que no se ha hecho algún cambio
            break;
        else
            % Se redondea al mínimo para colocar su ubicación
            c = floor(p);

            % Cambiar el estado en el mapa
            % Se resta del 3 ya que los estados del mapa son 2 o 1
            grid_map(c(2), c(1)) = 3 - grid_map(c(2), c(1));

            % Re-planificación del mapa
            [path, flag, cost, expand] = planner(grid_map, start, goal);
        end
    end
end
