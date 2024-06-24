%function entrenamiento_q(map, start, goal, filename, alpha, gamma)
function entrenamiento_q(map, start, goal, filename)
    % Definición de acciones, parámetros y tabla Q
    acciones = [-1, 0; 1, 0; 0, -1; 0, 1; -1, -1; -1, 1; 1, -1; 1, 1];
    %acciones = [-1, 0; 1, 0; 0, -1; 0, 1];
    alpha = 0.2;        % Mejor valor encontrado
    gamma = 0.8;        % Mejor valor encontrado
    epsilon = 0.4;      % Probabilidad de exploración
    episodios = 8000;   % Número de episodios de entrenamiento (reducido para optimización)
    Q = zeros(size(map,1), size(map,2), size(acciones,1));  % Inicializar tabla Q

    for episodio = 1:episodios
        state_act = start;  % Estado actual
        while ~isequal(state_act, goal)
            % Selección de acción basada en epsilon-greedy
            if rand() < epsilon
                % Exploración: elegir una acción aleatoria
                accion = randi(size(acciones, 1));
            else
                % Explotación: elegir la mejor acción basada en Q actual
                [~, accion] = max(Q(state_act(1), state_act(2), :));
            end

            % Tomar una acción y retornar el nuevo estado y la recompensa
            nueva_pos = state_act + acciones(accion, :);  % Buscar una nueva posición
            if nueva_pos(1) >= 1 && nueva_pos(1) <= size(map, 1) && ...
               nueva_pos(2) >= 1 && nueva_pos(2) <= size(map, 2) && ...
               map(nueva_pos(1), nueva_pos(2)) == 1 
                new_state = nueva_pos;  % Se almacena la nueva posición encontrada
                recompensa = -1;        % La recompensa de un punto exitoso
            else
                new_state = state_act;  % Se mantiene el estado si el movimiento no es posible
                recompensa = -10;       % Castigo por un punto fallido
            end

            % Ecuación de Q-learning: Actualizar tabla Q
            Q(state_act(1), state_act(2), accion) = Q(state_act(1), state_act(2), accion) ...
                + alpha * (recompensa + gamma * max(Q(new_state(1), new_state(2), :)) - Q(state_act(1), state_act(2), accion));

            state_act = new_state;  % Actualizar el estado del agente
        end 
    end

    % Guardar la tabla Q en un archivo
    save(filename, 'Q');
end