# Algoritmo principal y archivos de prueba

La carpeta cuenta con el siguiente contenido:

```
├─Q_learning_path_planning
│   ├─benchmark_algorithms.m
│   ├─Comprobar_alpha_gamma.m
│   └─Pruebas.m
```

## Q_learning_path_planning 
Se encuentra el algoritmo principal de Q-learning

## benchmark_algorithms.m
Se realiza una comparación entre algoritmos de planificación de ruta, se ocupan A*, D*, D* Lite, Q-learning, Dijkstra y RRT.

## Comprobar_alpha_gamma.m
Programa para encontrar los mejores valores para alpha y gamma, donde alpha y gamma se ingresan como parámetro al script de entrenamiento_Q.m.

## Pruebas.m
Script que sirve para hacer pruebas con el algoritmo de Q-learning y un mapa de referencia.
