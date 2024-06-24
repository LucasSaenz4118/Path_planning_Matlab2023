function [path, flag, cost, expand] = qLearning_path(map, start, goal)
    % ************************************************************** %
    % Función que aplica el método de Q-learning para encontrar la   %
    %   mejor ruta de un punto de inicio al objetivo                 %
    %                                                                %   
    % Recibe:                                                        %
    %   - map: El mapa                                               %
    %   - start: El punto de inicio [x,y]                            %
    %   - goal: El punto objetivo [x,y]                              %
    % ***************************************************************%
    
    % Define los posibles movimientos del agente en una cuadrícula.
    acciones = [-1, 0; 1, 0; 0, -1; 0, 1; -1, -1; -1, 1; 1, -1; 1, 1];
    num_acciones = size(acciones, 1);
    
    % Parámetros del algoritmo Q-learning.
    gamma = 0.8;        % Factor de descuento para las recompensas futuras.
    epsilon = 0.9;      % Tasa de exploración inicial.
    epsilon_min = 0.1;  % Valor mínimo de epsilon.
    alpha_max = 0.5;    % Valor máximo de la tasa de aprendizaje.
    alpha_min = 0.1;    % Valor mínimo de la tasa de aprendizaje.
    episodios = 3000;   % Número total de episodios de entrenamiento.

    % Inicializa la tabla Q con ceros.
    [map_rows, map_cols] = size(map);
    Q = zeros(map_rows, map_cols, num_acciones);

    % Inicializa la lista de expansión.
    expand = zeros(map_rows * map_cols, 2);
    expand_count = 0;
    visited = false(map_rows, map_cols); % Matriz de seguimiento de posiciones visitadas.

    % Bucle de entrenamiento para cada episodio.
    for episodio = 1:episodios
        state_act = start; % Estado inicial del agente al comienzo de cada episodio.
        epsilon = max(epsilon_min, epsilon * 0.995); % Reducción progresiva de epsilon.
        alpha = alpha_max - (alpha_max - alpha_min) * (episodio / episodios); % Ajuste lineal de alpha.

        % Bucle interno para moverse en el entorno hasta alcanzar el objetivo.
        while ~isequal(state_act, goal)
            % Almacena las coordenadas del estado actual si no han sido visitadas.
            % if ~visited(state_act(1), state_act(2))
            %     expand_count = expand_count + 1;
            %     expand(expand_count, :) = state_act;
            %     visited(state_act(1), state_act(2)) = true;
            % end

            % Selección de acción basada en epsilon-greedy.
            if rand() < epsilon
                accion = randi(num_acciones); % Selecciona una acción aleatoria (exploración).
            else
                [~, accion] = max(Q(state_act(1), state_act(2), :)); % Selecciona la mejor acción conocida (explotación).
            end

            % Calcula la nueva posición en función de la acción seleccionada.
            nueva_pos = state_act + acciones(accion, :);

            % Verifica si la nueva posición es válida.
            if nueva_pos(1) >= 1 && nueva_pos(1) <= map_rows && ...
               nueva_pos(2) >= 1 && nueva_pos(2) <= map_cols && ...
               map(nueva_pos(1), nueva_pos(2)) == 1
                if all(acciones(accion, :) ~= 0) && ...
                   (map(state_act(1), state_act(2) + acciones(accion, 2)) ~= 1 || ...
                    map(state_act(1) + acciones(accion, 1), state_act(2)) ~= 1)
                    new_state = state_act; % Mantiene el estado actual.
                    recompensa = -10;      % Penalización por movimiento inválido.
                else
                    new_state = nueva_pos; % Actualiza el estado.
                    recompensa = -1;       % Penalización básica por movimiento.
                end
            else
                new_state = state_act; % Mantiene el estado actual.
                recompensa = -10;      % Penalización por movimiento inválido.
            end

            % Actualización de la tabla Q usando la fórmula de Q-learning.
            Q(state_act(1), state_act(2), accion) = Q(state_act(1), state_act(2), accion) ...
                + alpha * (recompensa + gamma * max(Q(new_state(1), new_state(2), :)) - Q(state_act(1), state_act(2), accion));

            % Actualiza el estado actual.
            state_act = new_state;
        end 
    end

    % Ajusta el tamaño de expand a la cantidad real de pasos registrados.
    %expand = expand(1:expand_count, :);
    %expand = 0;
    % Llama a la función que determina la ruta utilizando la tabla Q.
    [path, flag, cost] = qLearning(map, start, goal, Q);
end

