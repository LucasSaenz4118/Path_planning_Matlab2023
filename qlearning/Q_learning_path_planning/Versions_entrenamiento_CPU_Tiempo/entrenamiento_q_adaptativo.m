% function entrenamiento_q_adaptativo(map, start, goal, filename)
%     % Define actions, parameters, and initialize Q-table
%     acciones = [-1, 0; 1, 0; 0, -1; 0, 1; -1, -1; -1, 1; 1, -1; 1, 1];
%     alpha = 0.2;
%     gamma = 0.8;
%     min_epsilon = 0.01;
%     max_epsilon = 1.0;
%     decay_rate = 0.995; % Tasa de decaimiento exponencial
%     performance_threshold = 50; % Umbral de rendimiento para ajustar epsilon
%     performance_window = 100; % Ventana de episodios para evaluar el rendimiento
%     episodios = 10000; % Número de episodios de entrenamiento
%     Q = zeros(size(map,1), size(map,2), size(acciones,1));
%     rewards_history = zeros(1, episodios);
% 
%     % Iniciar pool de trabajadores si no está activo
%     if isempty(gcp('nocreate'))
%         parpool;
%     end
% 
%     % Prealocar celdas para las actualizaciones locales de Q y recompensas
%     local_Q_cells = cell(1, episodios);
%     local_rewards = zeros(1, episodios);
% 
%     parfor episodio = 1:episodios
%         local_Q = zeros(size(Q)); % Matriz local para almacenar las actualizaciones de Q
%         state_act = start;
%         total_reward = 0;
%         local_epsilon = max(min_epsilon, max_epsilon * decay_rate^episodio); % Ajuste local de epsilon
% 
%         while ~isequal(state_act, goal)
%             if rand() < local_epsilon
%                 accion = randi(size(acciones,1));
%             else
%                 [~, accion] = max(Q(state_act(1),state_act(2),:));
%             end
%             nueva_pos = state_act + acciones(accion,:);
%             if nueva_pos(1) >= 1 && nueva_pos(1) <= size(map,1) && ...
%                nueva_pos(2) >= 1 && nueva_pos(2) <= size(map,2) && ...
%                map(nueva_pos(1), nueva_pos(2)) == 1 
%                 new_state = nueva_pos;
%                 recompensa = -1; % Penalización por movimiento
%                 % Recompensa por acercarse al objetivo
%                 dist_actual = sqrt(sum((goal - state_act) .^ 2));
%                 dist_nueva = sqrt(sum((goal - new_state) .^ 2));
%                 if dist_nueva < dist_actual
%                     recompensa = recompensa + 1;
%                 else
%                     recompensa = recompensa - 2; % Penalizar alejarse del objetivo
%                 end
%                 % Penalización adicional por cambio brusco de dirección
%                 if size(state_act, 1) > 1
%                     dist = sqrt(sum((new_state - state_act) .^ 2));
%                     if dist > sqrt(2) % Si la distancia es mayor que la diagonal
%                         recompensa = recompensa - 5;
%                     end
%                 end
%             else
%                 new_state = state_act;
%                 recompensa = -10; % Penalización por movimiento inválido
%             end
%             if isequal(new_state, goal)
%                 recompensa = 100; % Recompensa por alcanzar el objetivo
%             end
%             local_Q(state_act(1),state_act(2),accion) = local_Q(state_act(1),state_act(2),accion) ...
%                 + alpha*(recompensa + gamma*(max(Q(new_state(1),new_state(2), :)) - Q(state_act(1),state_act(2),accion)));
%             state_act = new_state;
%             total_reward = total_reward + recompensa;
%         end
% 
%         % Guardar la recompensa total del episodio
%         local_rewards(episodio) = total_reward;
%         local_Q_cells{episodio} = local_Q;
%     end
% 
%     % Combinar las actualizaciones locales de Q en la matriz Q global
%     for episodio = 1:episodios
%         Q = Q + local_Q_cells{episodio};
%         rewards_history(episodio) = local_rewards(episodio);
%     end
% 
%     % Ajustar epsilon adaptativamente basado en rendimiento
%     for episodio = 1:episodios
%         if episodio > performance_window
%             average_reward = mean(rewards_history((episodio-performance_window):episodio));
%             if average_reward > performance_threshold
%                 epsilon = max(min_epsilon, epsilon * decay_rate); % Reducir epsilon si el rendimiento es bueno
%             else
%                 epsilon = min(max_epsilon, epsilon * (1/decay_rate)); % Aumentar epsilon si el rendimiento es bajo
%             end
%         else
%             % Aplicar decaimiento exponencial estándar
%             epsilon = max(min_epsilon, epsilon * decay_rate);
%         end
%     end
% 
%     save(filename, 'Q');    % Almacenamiento de tabla Q
% 
%     % Visualización de la convergencia del aprendizaje (opcional)
%     figure;
%     plot(1:episodios, rewards_history);
%     xlabel('Episodios');
%     ylabel('Recompensa Total');
%     title('Convergencia del Aprendizaje adaptativo');
%     grid on;
%     % Guardar la gráfica en un archivo PNG
%     graph_filename = fullfile('Graphs', sprintf('Convergencia_Aprendizaje_%s.eps', datestr(now, 'yyyymmddTHHMMSSFFF')));
%     saveas(gcf, graph_filename, 'epsc');
% end


%function entrenamiento_q_adaptativo(map, start, goal, filename, alpha, gamma)
% function entrenamiento_q_adaptativo(map, start, goal, filename)
%     % Define actions, parameters, and initialize Q-table
%     %acciones = [-1, 0; 1, 0; 0, -1; 0, 1; -1, -1; -1, 1; 1, -1; 1, 1];
%     %epsilon = 0.2;
%     acciones = [-1, 0; 1, 0; 0, -1; 0, 1];
%     alpha = 0.2;
%     gamma = 0.8;
%     min_epsilon = 0.01;
%     max_epsilon = 1.0;
%     decay_rate = 0.995; % Tasa de decaimiento exponencial
%     performance_threshold = 50; % Umbral de rendimiento para ajustar epsilon
%     performance_window = 100; % Ventana de episodios para evaluar el rendimiento
%     epsilon = 1.0;
%     episodios = 20000; % Número de episodios de entrenamiento
%     Q = zeros(size(map,1), size(map,2), size(acciones,1));
%     rewards_history = zeros(1, episodios);
% 
%     for episodio = 1:episodios
%         state_act = start;
%         total_reward = 0;
% 
%         while ~isequal(state_act, goal)
%             if rand() < epsilon
%                 accion = randi(size(acciones,1));
%             else
%                 [~, accion] = max(Q(state_act(1),state_act(2),:));
%             end
%             nueva_pos = state_act + acciones(accion,:);
%             if nueva_pos(1) >= 1 && nueva_pos(1) <= size(map,1) && ...
%                nueva_pos(2) >= 1 && nueva_pos(2) <= size(map,2) && ...
%                map(nueva_pos(1), nueva_pos(2)) == 1 
%                 new_state = nueva_pos;
%                 recompensa = -1; % Penalización por movimiento
%                 % Recompensa por acercarse al objetivo
%                 dist_actual = sqrt(sum((goal - state_act) .^ 2));
%                 dist_nueva = sqrt(sum((goal - new_state) .^ 2));
%                 if dist_nueva < dist_actual
%                     recompensa = recompensa + 1;
%                 else
%                     recompensa = recompensa - 2; % Penalizar alejarse del objetivo
%                 end
%                 % Penalización adicional por cambio brusco de dirección
%                 if size(state_act, 1) > 1
%                     dist = sqrt(sum((new_state - state_act) .^ 2));
%                     if dist > sqrt(2) % Si la distancia es mayor que la diagonal
%                         recompensa = recompensa - 5;
%                     end
%                 end
%             else
%                 new_state = state_act;
%                 recompensa = -10; % Penalización por movimiento inválido
%             end
%             if isequal(new_state, goal)
%                 recompensa = 100; % Recompensa por alcanzar el objetivo
%             end
%             Q(state_act(1),state_act(2),accion) = Q(state_act(1),state_act(2),accion) ...
%                 + alpha*(recompensa + gamma*(max(Q(new_state(1),new_state(2), :)) - Q(state_act(1),state_act(2),accion)));
%             state_act = new_state;
%             total_reward = total_reward + recompensa;
%         end
% 
%         % Guardar la recompensa total del episodio
%         rewards_history(episodio) = total_reward;
% 
%         % Ajustar epsilon adaptativamente basado en rendimiento
%         if episodio > performance_window
%             average_reward = mean(rewards_history((episodio-performance_window):episodio));
%             if average_reward > performance_threshold
%                 epsilon = max(min_epsilon, epsilon * decay_rate); % Reducir epsilon si el rendimiento es bueno
%             else
%                 epsilon = min(max_epsilon, epsilon * (1/decay_rate)); % Aumentar epsilon si el rendimiento es bajo
%             end
%         else
%             % Aplicar decaimiento exponencial estándar
%             epsilon = max(min_epsilon, epsilon * decay_rate);
%         end
%     end
% 
%     save(filename, 'Q');    % Almacenamiento de tabla Q
% 
%     % Visualización de la convergencia del aprendizaje (opcional)
%     figure;
%     plot(1:episodios, rewards_history);
%     xlabel('Episodios');
%     ylabel('Recompensa Total');
%     title('Convergencia del Aprendizaje adaptativo');
%     grid on;
%     % Guardar la gráfica en un archivo PNG
%     graph_filename = fullfile('Graphs', sprintf('Convergencia_Aprendizaje_%s.eps', datestr(now, 'yyyymmddTHHMMSSFFF')));
%     saveas(gcf, graph_filename, 'epsc');
% end
%% ESTE LUIS
% function entrenamiento_q_adaptativo(map, start, goal, filename)
%     % Define actions, parameters, and initialize Q-table
%     acciones = [-1, 0; 1, 0; 0, -1; 0, 1; -1, -1; -1, 1; 1, -1; 1, 1];
%     epsilon = 0.8;
%     %alpha = 0.2;
%     gamma = 0.8;
%     min_epsilon = 0.01;
%     max_epsilon = 1.0;
%     alpha_max = 0.5;
%     alpha_min = 0.1;
%     performance_threshold = 50; % Umbral de rendimiento para ajustar epsilon
%     performance_window = 100; % Ventana de episodios para evaluar el rendimiento
%     episodios = 3000; %probar con 1000
%     Q = zeros(size(map,1), size(map,2), size(acciones,1));
%     rewards_history = zeros(1, episodios);
% 
%     for episodio = 1:episodios
%         state_act = start;
%         total_reward = 0;
%         alpha = alpha_max - (alpha_max - alpha_min) * (episodio / episodios); 
% 
% 
%         while ~isequal(state_act, goal)
%             if rand() < epsilon
%                 accion = randi(size(acciones,1));
%             else
%                 [~, accion] = max(Q(state_act(1),state_act(2),:));
%             end
%             nueva_pos = state_act + acciones(accion,:);
%             if nueva_pos(1) >= 1 && nueva_pos(1) <= size(map,1) && ...
%                nueva_pos(2) >= 1 && nueva_pos(2) <= size(map,2) && ...
%                map(nueva_pos(1), nueva_pos(2)) == 1 
%                 new_state = nueva_pos;
%                 recompensa = -1; % Penalización por movimiento
%             else
%                 new_state = state_act;
%                 recompensa = -10; % Penalización por movimiento inválido
%             end
%             if isequal(new_state, goal)
%                 recompensa = 100; % Recompensa por alcanzar el objetivo
%             end
%             Q(state_act(1),state_act(2),accion) = Q(state_act(1),state_act(2),accion) ...
%                 + alpha*(recompensa + gamma*(max(Q(new_state(1),new_state(2), :))- Q(state_act(1),state_act(2),accion)));
%             state_act = new_state;
%             total_reward = total_reward + recompensa;
%         end
% 
%         % Guardar la recompensa total del episodio
%         rewards_history(episodio) = total_reward;
% 
%         %Ajustar epsilon adaptativamente
%         % if episodio > performance_window
%         %     average_reward = mean(rewards_history((episodio-performance_window):episodio));
%         %     if average_reward > performance_threshold
%         %         epsilon = max(min_epsilon, epsilon * 0.99); % Reducir epsilon si el rendimiento es bueno
%         %     else
%         %         epsilon = min(max_epsilon, epsilon * 1.01); % Aumentar epsilon si el rendimiento es bajo
%         %     end
%         % end
%     end
% 
%     save(filename, 'Q');    %Almacenamiento de tabla Q
% 
%     %Visualización de la convergencia del aprendizaje (opcional)
%     %figure;
%     %plot(1:episodios, rewards_history);
%     %xlabel('Episodios');
%     %ylabel('Recompensa Total');
%     %title('Convergencia del Aprendizaje adaptativo');
%     %grid on;
%     % Guardar la gráfica en un archivo PNG
%     %graph_filename = fullfile('Graphs', sprintf('Convergencia_Aprendizaje_%s.eps', datestr(now, 'yyyymmddTHHMMSSFFF')));
%     %saveas(gcf, graph_filename, 'epsc');
% end
% function entrenamiento_q_adaptativo(map, start, goal, filename)
%     % Define actions, parameters, and initialize Q-table
%     acciones = [-1, 0; 1, 0; 0, -1; 0, 1; -1, -1; -1, 1; 1, -1; 1, 1];
%     epsilon = 1.0;
%     min_epsilon = 0.01;
%     max_epsilon = 1.0;
%     gamma = 0.8;
%     alpha_max = 0.5;
%     alpha_min = 0.1;
%     performance_threshold = 50; % Umbral de rendimiento para ajustar epsilon
%     performance_window = 100; % Ventana de episodios para evaluar el rendimiento
%     episodios = 4000; % Aumentar el número de episodios para mejor aprendizaje
%     Q = zeros(size(map,1), size(map,2), size(acciones,1));
%     rewards_history = zeros(1, episodios);
% 
%     for episodio = 1:episodios
%         state_act = start;
%         total_reward = 0;
%         alpha = alpha_max - (alpha_max - alpha_min) * (episodio / episodios); 
% 
%         while ~isequal(state_act, goal)
%             % Selección de acción basada en epsilon-greedy
%             if rand() < epsilon
%                 accion = randi(size(acciones,1));
%             else
%                 [~, accion] = max(Q(state_act(1),state_act(2),:));
%             end
% 
%             nueva_pos = state_act + acciones(accion,:);
%             recompensa = -1; % Penalización básica por movimiento
% 
%             % Validar si la nueva posición es válida
%             if nueva_pos(1) >= 1 && nueva_pos(1) <= size(map,1) && ...
%                nueva_pos(2) >= 1 && nueva_pos(2) <= size(map,2) && ...
%                map(nueva_pos(1), nueva_pos(2)) == 1 
%                 new_state = nueva_pos;
% 
%                 % Recompensa por acercarse al objetivo
%                 dist_actual = sum(abs(goal - state_act));
%                 dist_nueva = sum(abs(goal - new_state));
%                 if dist_nueva < dist_actual
%                     recompensa = recompensa + 1;
%                 else
%                     recompensa = recompensa - 2; % Penalizar alejarse del objetivo
%                 end
%             else
%                 new_state = state_act;
%                 recompensa = recompensa - 10; % Penalización por movimiento inválido
%             end
% 
%             % Recompensa por alcanzar el objetivo
%             if isequal(new_state, goal)
%                 recompensa = recompensa + 100; 
%             end
% 
%             % Actualizar tabla Q
%             Q(state_act(1),state_act(2),accion) = Q(state_act(1),state_act(2),accion) ...
%                 + alpha * (recompensa + gamma * max(Q(new_state(1),new_state(2), :)) - Q(state_act(1),state_act(2),accion));
% 
%             state_act = new_state;
%             total_reward = total_reward + recompensa;
%         end
% 
%         % Guardar la recompensa total del episodio
%         rewards_history(episodio) = total_reward;
% 
%         % Ajustar epsilon adaptativamente
%         if episodio > performance_window
%             average_reward = mean(rewards_history((episodio-performance_window):episodio));
%             if average_reward > performance_threshold
%                 epsilon = max(min_epsilon, epsilon * 0.99); % Reducir epsilon si el rendimiento es bueno
%             else
%                 epsilon = min(max_epsilon, epsilon * 1.01); % Aumentar epsilon si el rendimiento es bajo
%             end
%         end
%     end
% 
%     save(filename, 'Q');    % Almacenamiento de tabla Q
% 
%     % Visualización de la convergencia del aprendizaje (opcional)
%     figure;
%     plot(1:episodios, rewards_history);
%     xlabel('Episodios');
%     ylabel('Recompensa Total');
%     title('Convergencia del Aprendizaje');
%     grid on;
%     % Guardar la gráfica en un archivo PNG
%     graph_filename = fullfile('Graphs', sprintf('Convergencia_Aprendizaje_%s.eps', datestr(now, 'yyyymmddTHHMMSSFFF')));
%     saveas(gcf, graph_filename, 'epsc');
% end



% %function entrenamiento_q_adaptativo(map, start, goal, filename, alpha, gamma)
% function entrenamiento_q_adaptativo(map, start, goal, filename)
%     % Define actions, parameters, and initialize Q-table
%     %acciones = [-1, 0; 1, 0; 0, -1; 0, 1; -1, -1; -1, 1; 1, -1; 1, 1];
%     acciones = [-1, 0; 1, 0; 0, -1; 0, 1];
%     epsilon = 1.0;
%     alpha = 0.2;
%     gamma = 0.8;
%     min_epsilon = 0.01;
%     max_epsilon = 1.0;
%     performance_threshold = 50; % Umbral de rendimiento para ajustar epsilon
%     performance_window = 100; % Ventana de episodios para evaluar el rendimiento
%     episodios = 3000; %probar con 1000
%     Q = zeros(size(map,1), size(map,2), size(acciones,1));
%     rewards_history = zeros(1, episodios);
% 
%     for episodio = 1:episodios
%         state_act = start;
%         total_reward = 0;
% 
%         while ~isequal(state_act, goal)
%             if rand() < epsilon
%                 accion = randi(size(acciones,1));
%             else
%                 [~, accion] = max(Q(state_act(1),state_act(2),:));
%             end
%             nueva_pos = state_act + acciones(accion,:);
%             if nueva_pos(1) >= 1 && nueva_pos(1) <= size(map,1) && ...
%                nueva_pos(2) >= 1 && nueva_pos(2) <= size(map,2) && ...
%                map(nueva_pos(1), nueva_pos(2)) == 1 
%                 new_state = nueva_pos;
%                 recompensa = -1; % Penalización por movimiento
%             else
%                 new_state = state_act;
%                 recompensa = -10; % Penalización por movimiento inválido
%             end
%             if isequal(new_state, goal)
%                 recompensa = 100; % Recompensa por alcanzar el objetivo
%             end
%             Q(state_act(1),state_act(2),accion) = Q(state_act(1),state_act(2),accion) ...
%                 + alpha*(recompensa + gamma*(max(Q(new_state(1),new_state(2), :))- Q(state_act(1),state_act(2),accion)));
%             state_act = new_state;
%             total_reward = total_reward + recompensa;
%         end
% 
%         % Guardar la recompensa total del episodio
%         rewards_history(episodio) = total_reward;
% 
%         %Ajustar epsilon adaptativamente
%         if episodio > performance_window
%             average_reward = mean(rewards_history((episodio-performance_window):episodio));
%             if average_reward > performance_threshold
%                 epsilon = max(min_epsilon, epsilon * 0.99); % Reducir epsilon si el rendimiento es bueno
%             else
%                 epsilon = min(max_epsilon, epsilon * 1.01); % Aumentar epsilon si el rendimiento es bajo
%             end
%         end
%     end
% 
%     save(filename, 'Q');    %Almacenamiento de tabla Q
% 
%     %Visualización de la convergencia del aprendizaje (opcional)
%     %figure;
%     %plot(1:episodios, rewards_history);
%     %xlabel('Episodios');
%     %ylabel('Recompensa Total');
%     %title('Convergencia del Aprendizaje adaptativo');
%     %grid on;
%     % Guardar la gráfica en un archivo PNG
%     %graph_filename = fullfile('Graphs', sprintf('Convergencia_Aprendizaje_%s.eps', datestr(now, 'yyyymmddTHHMMSSFFF')));
%     %saveas(gcf, graph_filename, 'epsc');
% end

% function entrenamiento_q_adaptativo(map, start, goal, filename)
%     % Define actions, parameters, and initialize Q-table
%     acciones = [-1, 0; 1, 0; 0, -1; 0, 1];
%     %acciones = [-1, 0; 1, 0; 0, -1; 0, 1; -1, -1; -1, 1; 1, -1; 1, 1];
% 
%     epsilon = 1.0;
%     alpha = 0.2;
%     gamma = 0.8;
%     min_epsilon = 0.01;
%     episodios = 35000;
%     epsilon_decay = 0.995; % Factor de decaimiento de epsilon
%     Q = zeros(size(map,1), size(map,2), size(acciones,1));
% 
%     for episodio = 1:episodios
%         state_act = start;
%         while ~isequal(state_act, goal)
%             if rand() < epsilon
%                 accion = randi(size(acciones,1));
%             else
%                 [~, accion] = max(Q(state_act(1),state_act(2),:));
%             end
%             nueva_pos = state_act + acciones(accion,:);
%             if nueva_pos(1) >= 1 && nueva_pos(1) <= size(map,1) && ...
%                nueva_pos(2) >= 1 && nueva_pos(2) <= size(map,2) && ...
%                map(nueva_pos(1), nueva_pos(2)) == 1 
%                 new_state = nueva_pos;
%                 recompensa = -1;
%             else
%                 new_state = state_act;
%                 recompensa = -10;
%             end
%             if isequal(new_state, goal)
%                 recompensa = 100;
%             end
%             Q(state_act(1),state_act(2),accion) = Q(state_act(1),state_act(2),accion) ...
%                 + alpha*(recompensa + gamma*(max(Q(new_state(1),new_state(2), :))- Q(state_act(1),state_act(2),accion)));
%             state_act = new_state;
%         end
% 
%         % Decaimiento de epsilon al final de cada episodio
%         epsilon = max(min_epsilon, epsilon * epsilon_decay);
%     end
% 
%     save(filename, 'Q'); % Almacenamiento de tabla Q
% end

function entrenamiento_q_adaptativo(map, start, goal, filename)
    % Define actions, parameters, and initialize Q-table
    acciones = [-1, 0; 1, 0; 0, -1; 0, 1; -1, -1; -1, 1; 1, -1; 1, 1];
    epsilon = 0.8;
    gamma = 0.8;
    min_epsilon = 0.01;
    max_epsilon = 1.0;
    alpha_max = 0.5;
    alpha_min = 0.1;
    performance_threshold = 50; % Umbral de rendimiento para ajustar epsilon
    performance_window = 100; % Ventana de episodios para evaluar el rendimiento
    episodios = 3000; % probar con 1000
    Q = zeros(size(map,1), size(map,2), size(acciones,1));
    rewards_history = zeros(1, episodios);

    for episodio = 1:episodios
        state_act = start;
        total_reward = 0;
        alpha = alpha_max - (alpha_max - alpha_min) * (episodio / episodios); 

        while ~isequal(state_act, goal)
            if rand() < epsilon
                accion = randi(size(acciones,1));
            else
                [~, accion] = max(Q(state_act(1),state_act(2),:));
            end
            nueva_pos = state_act + acciones(accion,:);
            recompensa = -1; % Penalización por movimiento
            
            if nueva_pos(1) >= 1 && nueva_pos(1) <= size(map,1) && ...
               nueva_pos(2) >= 1 && nueva_pos(2) <= size(map,2) && ...
               map(nueva_pos(1), nueva_pos(2)) == 1 
                new_state = nueva_pos;

                % Recompensa por acercarse al objetivo
                dist_actual = abs(goal(1) - state_act(1)) + abs(goal(2) - state_act(2));
                dist_nueva = abs(goal(1) - new_state(1)) + abs(goal(2) - new_state(2));
                if dist_nueva < dist_actual
                    recompensa = recompensa + 1; % Recompensa por acercarse al objetivo
                else
                    recompensa = recompensa - 2; % Penalizar alejarse del objetivo
                end
            else
                new_state = state_act;
                recompensa = -10; % Penalización por movimiento inválido
            end
            if isequal(new_state, goal)
                recompensa = 100; % Recompensa por alcanzar el objetivo
            end
            
            % Actualizar tabla Q
            Q(state_act(1),state_act(2),accion) = Q(state_act(1),state_act(2),accion) ...
                + alpha * (recompensa + gamma * max(Q(new_state(1),new_state(2), :)) - Q(state_act(1),state_act(2),accion));
            
            state_act = new_state;
            total_reward = total_reward + recompensa;
        end

        % Guardar la recompensa total del episodio
        rewards_history(episodio) = total_reward;

        % Ajustar epsilon adaptativamente cada 'performance_window' episodios
        if mod(episodio, performance_window) == 0
            average_reward = mean(rewards_history((episodio-performance_window+1):episodio));
            if average_reward > performance_threshold
                epsilon = max(min_epsilon, epsilon * 0.99); % Reducir epsilon si el rendimiento es bueno
            else
                epsilon = min(max_epsilon, epsilon * 1.01); % Aumentar epsilon si el rendimiento es bajo
            end
        end
    end

    save(filename, 'Q');    % Almacenamiento de tabla Q

    % Visualización de la convergencia del aprendizaje (opcional)
    % figure;
    % plot(1:episodios, rewards_history);
    % xlabel('Episodios');
    % ylabel('Recompensa Total');
    % title('Convergencia del Aprendizaje');
    % grid on;
    % % Guardar la gráfica en un archivo PNG
    % graph_filename = fullfile('Graphs', sprintf('Convergencia_Aprendizaje_%s.eps', datestr(now, 'yyyymmddTHHMMSSFFF')));
    % saveas(gcf, graph_filename, 'epsc');
end

