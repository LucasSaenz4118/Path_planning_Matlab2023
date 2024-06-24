function [path, flag, cost] = qLearning(map, start, goal, filename)
% ************************************************************** %
% Función que encuentra la ruta basada en la tabla Q del script  %
% entrenamiento_q.m, desde un punto de inicio a uno objetivo     %
%                                                                %   
% Recibe:                                                        %
%   - map: El mapa                                               %
%   - start: El punto de inicio [x, y]                           %
%   - goal: El punto objetivo [x, y]                             %
%   - filename: Nombre de la tabla Q                             %
%                                                                %
% Regresa:                                                       %
%   - path: La ruta encontrada del punto de inicio al objetivo   %
%   - flag: Indica si se encontró el objetivo (true/false)       %
%   - cost: El costo total de la ruta                            %
% ************************************************************** %

    % Carga la tabla Q desde el archivo especificado
    %load(filename, 'Q');
    Q = filename;
    % Define los posibles movimientos del agente
    % Se pueden usar movimientos básicos (verticales y horizontales) o
    % movimientos adicionales (diagonales)
    acciones = [-1, 0; 1, 0; 0, -1; 0, 1; -1, -1; -1, 1; 1, -1; 1, 1];

    % Inicializa el estado actual con el estado de inicio
    state_act = start;
    % Inicializa el camino recorrido por el agente con el estado de inicio
    path = start;
    % Inicializa el costo total del camino recorrido
    cost = 0;
    % Inicializa una matriz de visitados del mismo tamaño que el mapa
    visited = zeros(size(map));
    % Inicializa la bandera que indica si se encontró el objetivo
    flag = true;
    
    % Bucle que se ejecuta hasta que el agente alcanza el objetivo
    while ~isequal(state_act, goal)
        % Selecciona la acción con el valor Q más alto en el estado actual
        [~, accion] = max(Q(state_act(1), state_act(2), :));
        % Calcula la nueva posición basada en la acción seleccionada
        nueva_pos = state_act + acciones(accion, :);
        
        % Verifica si la nueva posición es válida
        if isValidMove(map, nueva_pos, visited)
            % Actualiza el estado actual a la nueva posición
            state_act = nueva_pos;
            % Añade la nueva posición al camino recorrido
            path = [path; state_act];
            % Calcula la distancia recorrida y actualiza el costo
            if size(path, 1) > 1
                dist = sqrt(sum((path(end, :) - path(end-1, :)) .^ 2));
                cost = cost + dist;
            end
            % Marca la nueva posición como visitada
            visited(state_act(1), state_act(2)) = 1;
        else
            % Si la nueva posición no es válida, establece la bandera en false
            % y termina el bucle
            flag = false;
            break;
        end
    end
    
    % Si el agente no alcanzó el objetivo, establece la bandera en false
    if ~isequal(state_act, goal)
        flag = false;
    end
end

function isValid = isValidMove(map, pos, visited)
    % Verifica si la posición es válida (dentro del mapa, es transitable y no ha sido visitada)
    isValid = pos(1) >= 1 && pos(1) <= size(map,1) && ...
              pos(2) >= 1 && pos(2) <= size(map,2) && ...
              map(pos(1), pos(2)) == 1 && ...
              ~visited(pos(1), pos(2));
end

