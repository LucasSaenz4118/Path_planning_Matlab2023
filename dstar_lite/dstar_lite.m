function [path, flag, cost, EXPAND] = dstar_lite(map, start, goal)
    % ************************************************************** %
    % Función que aplica el método D* Lite para encontrar la         %
    %   mejor ruta de un punto de inicio al objetivo                 %
    %                                                                %   
    % Recibe:                                                        %
    %   - map: El mapa (0 para obstáculos, 1 para espacio libre)     %
    %   - start: El punto de inicio [x,y]                            %
    %   - goal: El punto objetivo [x,y]                              %
    %                                                                %
    % Retorna:                                                       %
    %   - path : camino                                              %
    %   - flag: Bandera para saber si se encontró el camino o no     %
    %   - cost: Costo del camino                                     %
    %   - EXPAND: Puntos visitados por el algoritmo                  %
    % ************************************************************** %

    % Inicialización de variables
    sstart = start; % Nodo de inicio
    sgoal = goal; % Nodo objetivo

    [rows, cols] = size(map); % Tamaño del mapa
    rhs = inf(rows, cols); % Inicialización de rhs con infinito
    g = inf(rows, cols); % Inicialización de g con infinito
    h = calcularHeuristicas(map, sstart); % Calcular la heurística desde el objetivo

    rhs(sgoal(1), sgoal(2)) = 0; % El nodo objetivo tiene rhs de 0
    U = [sgoal,  calcularKey(sgoal, g, rhs, sstart, h)]; % Inicializar la lista de nodos abiertos (frontera)
     k_mat = inf(rows, cols, 2);

    EXPAND = []; % Inicializar la lista de nodos EXPANDidos

    while ~isempty(U) % Mientras la lista de nodos abiertos no esté vacía
        [~, idx] = min(U(:, 3)); % Encontrar el nodo con la clave más pequeña
        actual = U(idx, 1:2); % Nodo actual
        k_old = U(idx, 3:4); % Clave antigua del nodo actual
        U(idx, :) = []; % Remover el nodo actual de la lista de nodos abiertos
        k_new =  calcularKey(actual, g, rhs, sstart, h); % Calcular la nueva clave para el nodo actual
        k_mat(actual(1), actual(2),:)=k_new;
        if any(k_old < k_new) % Si la clave antigua es menor que la nueva
           % U = [U; actual, k_new]; % Reinsertar el nodo con la nueva clave
        elseif g(actual(1), actual(2)) > rhs(actual(1), actual(2)) % Si g es mayor que rhs
            g(actual(1), actual(2)) = rhs(actual(1), actual(2)); % Actualizar g
            vecinos = getvecinos(actual, rows, cols); % Obtener los vecinos del nodo actual
            for i = 1:size(vecinos, 1)
                vecino = vecinos(i, :);
                if map(vecino(1), vecino(2)) == 1 && ~isequal(vecino, sgoal)
                    rhs(vecino(1), vecino(2)) = min(rhs(vecino(1), vecino(2)), g(actual(1), actual(2)) + 1);
                    U = updateNode(U, vecino, g, rhs, sstart, h); % Actualizar el vecino en la lista de nodos abiertos
                end
            end
        else
            if g(actual(1), actual(2)) ~= inf
                g(actual(1), actual(2)) = inf; % Establecer g como infinito
                vecinos = getvecinos(actual, rows, cols); % Obtener los vecinos del nodo actual
                for i = 1:size(vecinos, 1)
                    vecino = vecinos(i, :);
                    if map(vecino(1), vecino(2)) == 1 && rhs(vecino(1), vecino(2)) == g(actual(1), actual(2)) + 1
                        if ~isequal(vecino, sgoal)
                            rhs(vecino(1), vecino(2)) = inf; % Establecer rhs como infinito
                        end
                    end
                    U = updateNode(U, vecino, g, rhs, sstart, h); % Actualizar el vecino en la lista de nodos abiertos
                end
                U = updateNode(U, actual, g, rhs, sstart, h); % Actualizar el nodo actual en la lista de nodos abiertos
            end
        end

        EXPAND = [EXPAND; actual]; % Agregar el nodo actual a la lista de nodos EXPANDidos

        if isequal(actual, sstart) && g(sstart(1), sstart(2)) == rhs(sstart(1), sstart(2))
            break; % Si el nodo actual es el inicio y g es igual a rhs, terminar el ciclo
        end
    end

    g(sstart(1), sstart(2)) = rhs(sstart(1), sstart(2)); % Actualizar g del nodo de inicio
    [path, cost, flag] = reconstruirPath(g, rhs, start, goal); % Reconstruir el camino desde el inicio hasta el objetivo

    if isempty(path) % Si no se encontró un camino
        flag = false; % Establecer la bandera como falsa
    else
        flag = true; % Establecer la bandera como verdadera
    end
end

function [path, cost, flag] = reconstruirPath(g, rhs, start, goal)
    path = start; % Inicializar el camino con el nodo de inicio
    actual = start; % Nodo actual es el nodo de inicio
    cost = 0; % Inicializar el costo del camino

    while ~isequal(actual, goal) % Mientras el nodo actual no sea el objetivo
        vecinos = getvecinos(actual, size(g, 1), size(g, 2)); % Obtener los vecinos del nodo actual
        valid_vecinos = vecinos(~isinf(g(sub2ind(size(g), vecinos(:, 1), vecinos(:, 2)))), :); % Vecinos válidos con rhs no infinito
        if isempty(valid_vecinos) % Si no hay vecinos válidos
            path = [];
            cost = inf;
            flag = false;
            return; % Terminar la función
        end
        [~, idx] = min(g(sub2ind(size(g), valid_vecinos(:, 1), valid_vecinos(:, 2)))); % Encontrar el vecino con el menor g
        next = valid_vecinos(idx, :); % Siguiente nodo en el camino
        path = [path; next]; % Agregar el siguiente nodo al camino
        cost = cost + 1; % Incrementar el costo del camino
        actual = next; % Actualizar el nodo actual
    end
    flag = true; % Establecer la bandera como verdadera
end

function U = updateNode(U, node, g, rhs, sstart, h)
    idx = find(U(:, 1) == node(1) & U(:, 2) == node(2)); % Encontrar el índice del nodo en la lista de nodos abiertos
    if ~isempty(idx)
        U(idx, :) = []; % Eliminar el nodo de la lista de nodos abiertos
    end
    if g(node(1), node(2)) ~= rhs(node(1), node(2)) % Si g no es igual a rhs
        key =  calcularKey(node, g, rhs, sstart, h); % Calcular la clave para el nodo
        U = [U; node, key]; % Agregar el nodo a la lista de nodos abiertos con la nueva clave
    end
end

function h = calcularHeuristicas(map, nodo)
    [rows, cols] = size(map); % Tamaño del mapa
    h = inf(rows, cols); % Inicializar la heurística con infinito
    cola = [nodo, 0]; % Inicializar la cola con el nodo objetivo y costo 0
    
    while ~isempty(cola) % Mientras la cola no esté vacía
        node = cola(1, 1:2); % Nodo actual
        cost = cola(1, 3); % Costo del nodo actual
        cola(1, :) = []; % Eliminar el nodo actual de la cola
        
        if node(1) >= 1 && node(1) <= rows && node(2) >= 1 && node(2) <= cols % Si el nodo está dentro del mapa y esta vacio
            if h(node(1), node(2)) > cost % Si la heurística del nodo actual es mayor que el costo
                h(node(1), node(2)) = cost; % Actualizar la heurística del nodo actual
                vecinos = getvecinos(node, rows, cols); % Obtener los vecinos del nodo actual
                for k = 1:size(vecinos, 1)
                    vecino = vecinos(k, :);
                    if map(vecino(1), vecino(2)) == 1 && h(vecino(1), vecino(2)) > cost + 1
                        cola = [cola; vecino, cost + 1]; % Agregar el vecino a la cola con el nuevo costo
                    end
                end
            end
        end
    end
end

function vecinos = getvecinos(node, rows, cols)
    i = node(1);
    j = node(2);
    vecinos = [];
    if i > 1, vecinos = [vecinos; i-1, j]; end % Agregar el vecino de arriba
    if i < rows, vecinos = [vecinos; i+1, j]; end % Agregar el vecino de abajo
    if j > 1, vecinos = [vecinos; i, j-1]; end % Agregar el vecino de la izquierda
    if j < cols, vecinos = [vecinos; i, j+1]; end % Agregar el vecino de la derecha
end



function k =  calcularKey(node, g, rhs, sstart, h)
    k1 = min(g(node(1), node(2)), rhs(node(1), node(2))) + h(node(1), node(2)) ; % Primera parte de la clave
    k2 = min(g(node(1), node(2)), rhs(node(1), node(2))); % Segunda parte de la clave
    k = [k1 k2]; % Clave completa
end




