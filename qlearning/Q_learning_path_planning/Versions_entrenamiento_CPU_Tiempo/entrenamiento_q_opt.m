% function entrenamiento_q_opt(map, start, goal, filename)
%     % ************************************************************** %
%     % Función que aplica el método de Q-learning para encontrar la   %
%     %   mejor ruta de un punto de inicio al objetivo                 %
%     %                                                                %   
%     % Recibe:                                                        %
%     %   - map: El mapa                                               %
%     %   - start: El punto de inicio [x,y]                            %
%     %   - goal: El punto objetivo [x,y]                              %
%     %   - filename: Nombre de la tabla Q                             %
%     % ***************************************************************%
% 
%     % Define los posibles movimientos del agente en una cuadrícula.
%     % Incluye movimientos verticales, horizontales y diagonales.
%     acciones = [-1, 0; 1, 0; 0, -1; 0, 1; -1, -1; -1, 1; 1, -1; 1, 1];
% 
%     % Parámetros del algoritmo Q-learning.
%     gamma = 0.9;        % Factor de descuento para las recompensas futuras.
%     epsilon = 0.9;      % Tasa de exploración inicial.
%     epsilon_min = 0.1;  % Valor mínimo de epsilon.
%     alpha_max = 0.5;    % Valor máximo de la tasa de aprendizaje.
%     alpha_min = 0.1;    % Valor mínimo de la tasa de aprendizaje.
%     episodios = 5000;   % Número total de episodios de entrenamiento.
% 
%     % Inicializa la tabla Q con ceros.
%     Q = zeros(size(map, 1), size(map, 2), size(acciones, 1));
% 
%     % Bucle de entrenamiento para cada episodio.
%     for episodio = 1:episodios
%         state_act = start; % Estado inicial del agente al comienzo de cada episodio.
%         epsilon = max(epsilon_min, epsilon * 0.995); % Reducción progresiva de epsilon.
%         alpha = alpha_max - (alpha_max - alpha_min) * (episodio / episodios); % Ajuste lineal de alpha.
% 
%         % Bucle interno para moverse en el entorno hasta alcanzar el objetivo.
%         while ~isequal(state_act, goal)
%             % Selección de acción basada en epsilon-greedy.
%             if rand() < epsilon
%                 accion = randi(size(acciones, 1)); % Selecciona una acción aleatoria (exploración).
%             else
%                 [~, accion] = max(Q(state_act(1), state_act(2), :)); % Selecciona la mejor acción conocida (explotación).
%             end
% 
%             % Calcula la nueva posición en función de la acción seleccionada.
%             nueva_pos = state_act + acciones(accion, :);
% 
%             % Verifica si la nueva posición es válida (dentro del mapa y no es un obstáculo).
%             if nueva_pos(1) >= 1 && nueva_pos(1) <= size(map, 1) && ...
%                nueva_pos(2) >= 1 && nueva_pos(2) <= size(map, 2) && ...
%                map(nueva_pos(1), nueva_pos(2)) == 1
%                 if abs(acciones(accion, 1)) == 1 && abs(acciones(accion, 2)) == 1
%                     % Verificación adicional para movimientos diagonales
%                     if map(state_act(1), state_act(2) + acciones(accion, 2)) == 1 && ...
%                        map(state_act(1) + acciones(accion, 1), state_act(2)) == 1
%                         new_state = nueva_pos; % Actualiza el estado.
%                         recompensa = -1;       % Penalización básica por movimiento.
%                     else
%                         new_state = state_act; % Mantiene el estado actual.
%                         recompensa = -10;      % Penalización por movimiento inválido.
%                     end
%                 else
%                     new_state = nueva_pos; % Actualiza el estado.
%                     recompensa = -1;       % Penalización básica por movimiento.
%                 end
%             else
%                 new_state = state_act; % Mantiene el estado actual.
%                 recompensa = -10;      % Penalización por movimiento inválido.
%             end
% 
%             % Penalización adicional por curvas innecesarias
%             if abs(state_act(1) - goal(1)) < abs(new_state(1) - goal(1)) || ...
%                abs(state_act(2) - goal(2)) < abs(new_state(2) - goal(2))
%                 recompensa = recompensa - 5; % Penalización por alejarse del objetivo.
%             end
% 
%             % Recompensa positiva por acercarse al objetivo
%             if abs(new_state(1) - goal(1)) < abs(state_act(1) - goal(1)) || ...
%                abs(new_state(2) - goal(2)) < abs(state_act(2) - goal(2))
%                 recompensa = recompensa + 10; % Recompensa por acercarse al objetivo.
%             end
% 
%             % Actualización de la tabla Q usando la fórmula de Q-learning.
%             Q(state_act(1), state_act(2), accion) = Q(state_act(1), state_act(2), accion) ...
%                 + alpha * (recompensa + gamma * max(Q(new_state(1), new_state(2), :)) - Q(state_act(1), state_act(2), accion));
% 
%             % Actualiza el estado actual.
%             state_act = new_state;
%         end 
%     end
% 
%     % Guarda la tabla Q en un archivo.
%     save(filename, 'Q');
% end


function entrenamiento_q_opt(map, start, goal, filename)
    % ************************************************************** %
    % Función que aplica el método de Q-learning para encontrar la   %
    %   mejor ruta de un punto de inicio al objetivo                 %
    %                                                                %   
    % Recibe:                                                        %
    %   - map: El mapa                                               %
    %   - start: El punto de inicio [x,y]                            %
    %   - goal: El punto objetivo [x,y]                              %
    %   - filename: Nombre de la tabla Q                             %
    % ***************************************************************%

    % Define los posibles movimientos del agente en una cuadrícula.
    % Incluye movimientos verticales, horizontales y diagonales.
    acciones = [-1, 0; 1, 0; 0, -1; 0, 1; -1, -1; -1, 1; 1, -1; 1, 1];
    %acciones = [-1, 0; 1, 0; 0, -1; 0, 1]; % Movimientos básicos

    % Parámetros del algoritmo Q-learning.
    gamma = 0.8;        % Factor de descuento para las recompensas futuras.
    epsilon = 0.9;      % Tasa de exploración inicial.
    epsilon_min = 0.1;  % Valor mínimo de epsilon.
    alpha_max = 0.5;    % Valor máximo de la tasa de aprendizaje.
    alpha_min = 0.1;    % Valor mínimo de la tasa de aprendizaje.
    episodios = 3000;   % Número total de episodios de entrenamiento.

    % Inicializa la tabla Q con ceros.
    Q = zeros(size(map, 1), size(map, 2), size(acciones, 1));

    % Bucle de entrenamiento para cada episodio.
    for episodio = 1:episodios
        state_act = start; % Estado inicial del agente al comienzo de cada episodio.
        epsilon = max(epsilon_min, epsilon * 0.995); % Reducción progresiva de epsilon.
        alpha = alpha_max - (alpha_max - alpha_min) * (episodio / episodios); % Ajuste lineal de alpha.

        % Bucle interno para moverse en el entorno hasta alcanzar el objetivo.
        while ~isequal(state_act, goal)
            % Selección de acción basada en epsilon-greedy.
            if rand() < epsilon
                accion = randi(size(acciones, 1)); % Selecciona una acción aleatoria (exploración).
            else
                [~, accion] = max(Q(state_act(1), state_act(2), :)); % Selecciona la mejor acción conocida (explotación).
            end

            % Calcula la nueva posición en función de la acción seleccionada.
            nueva_pos = state_act + acciones(accion, :);

            % Verifica si la nueva posición es válida (dentro del mapa y no es un obstáculo).
            if nueva_pos(1) >= 1 && nueva_pos(1) <= size(map, 1) && ...
               nueva_pos(2) >= 1 && nueva_pos(2) <= size(map, 2) && ...
               map(nueva_pos(1), nueva_pos(2)) == 1
                if abs(acciones(accion, 1)) == 1 && abs(acciones(accion, 2)) == 1
                    % Verificación adicional para movimientos diagonales
                    if map(state_act(1), state_act(2) + acciones(accion, 2)) == 1 && ...
                       map(state_act(1) + acciones(accion, 1), state_act(2)) == 1
                        new_state = nueva_pos; % Actualiza el estado.
                        recompensa = -1;       % Penalización básica por movimiento.
                    else
                        new_state = state_act; % Mantiene el estado actual.
                        recompensa = -10;      % Penalización por movimiento inválido.
                    end
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

    % Guarda la tabla Q en un archivo.
    save(filename, 'Q');
end

% function entrenamiento_q_opt(map, start, goal, filename)
%     % ************************************************************** %
%     % Función que aplica el método de Q-learning para encontrar la   %
%     %   mejor ruta de un punto de inicio al objetivo                 %
%     %                                                                %   
%     % Recibe:                                                        %
%     %   - map: El mapa                                               %
%     %   - start: El punto de inicio [x,y]                            %
%     %   - goal: El punto objetivo [x,y]                              %
%     %   - filename: Nombre de la tabla Q                             %
%     % ***************************************************************%
% 
%     % Define los posibles movimientos del agente en una cuadrícula.
%     % Incluye movimientos verticales, horizontales y diagonales.
%     acciones = [-1, 0; 1, 0; 0, -1; 0, 1; -1, -1; -1, 1; 1, -1; 1, 1];
%     %acciones = [-1, 0; 1, 0; 0, -1; 0, 1]; % Movimientos básicos
% 
%     % Parámetros del algoritmo Q-learning.
%     gamma = 0.8;        % Factor de descuento para las recompensas futuras.
%     epsilon = 0.9;      % Tasa de exploración inicial.
%     epsilon_min = 0.1;  % Valor mínimo de epsilon.
%     alpha_max = 0.5;    % Valor máximo de la tasa de aprendizaje.
%     alpha_min = 0.1;    % Valor mínimo de la tasa de aprendizaje.
%     episodios = 3000;   % Número total de episodios de entrenamiento.
% 
%     % Inicializa la tabla Q con ceros.
%     Q = zeros(size(map, 1), size(map, 2), size(acciones, 1));
% 
%     % Bucle de entrenamiento para cada episodio.
%     for episodio = 1:episodios
%         state_act = start; % Estado inicial del agente al comienzo de cada episodio.
%         epsilon = max(epsilon_min, epsilon * 0.995); % Reducción progresiva de epsilon.
%         alpha = alpha_max - (alpha_max - alpha_min) * (episodio / episodios); % Ajuste lineal de alpha.
% 
%         % Bucle interno para moverse en el entorno hasta alcanzar el objetivo.
%         while ~isequal(state_act, goal)
%             % Selección de acción basada en epsilon-greedy.
%             if rand() < epsilon
%                 accion = randi(size(acciones, 1)); % Selecciona una acción aleatoria (exploración).
%             else
%                 [~, accion] = max(Q(state_act(1), state_act(2), :)); % Selecciona la mejor acción conocida (explotación).
%             end
% 
%             % Calcula la nueva posición en función de la acción seleccionada.
%             nueva_pos = state_act + acciones(accion, :);
% 
%             % Verifica si la nueva posición es válida (dentro del mapa y no es un obstáculo).
%             if nueva_pos(1) >= 1 && nueva_pos(1) <= size(map, 1) && ...
%                nueva_pos(2) >= 1 && nueva_pos(2) <= size(map, 2) && ...
%                map(nueva_pos(1), nueva_pos(2)) == 1
%                 new_state = nueva_pos; % Actualiza el estado.
%                 recompensa = -1;       % Penalización básica por movimiento.
%             else
%                 new_state = state_act; % Mantiene el estado actual.
%                 recompensa = -10;      % Penalización por movimiento inválido.
%             end
% 
%             % Actualización de la tabla Q usando la fórmula de Q-learning.
%             Q(state_act(1), state_act(2), accion) = Q(state_act(1), state_act(2), accion) ...
%                 + alpha * (recompensa + gamma * max(Q(new_state(1), new_state(2), :)) - Q(state_act(1), state_act(2), accion));
% 
%             % Actualiza el estado actual.
%             state_act = new_state;
%         end 
%     end
% 
%     % Guarda la tabla Q en un archivo.
%     save(filename, 'Q');
% end
