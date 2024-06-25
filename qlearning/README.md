# Algoritmo principal y archivos de prueba

La carpeta cuenta con el siguiente contenido:

```
├─Q_learning_path_planning
│   ├─benchmark_algorithms.m
│   ├─Comprobar_alpha_gamma.m
│   └─Pruebas.m
```

## Q_learning_path_planning 
Directorio en donde se encuentra el algoritmo principal de Q-learning

## benchmark_algorithms.m
Se realiza una comparación entre algoritmos de planificación de ruta, se ocupan A*, D*, D* Lite, Q-learning, Dijkstra y RRT.
<p align="center">
  <img src="https://github.com/LucasSaenz4118/Path_planning_Matlab2024/blob/bd0c89e39a51e70d356132a829e1d2923d7373bc/qlearning/Imagenes/benchmark.png" alt="Benchmark" width="30%" />
</p>
  
## Comprobar_alpha_gamma.m
Programa para encontrar los mejores valores para alpha y gamma, donde alpha y gamma se ingresan como parámetro al script de entrenamiento_Q.m.
<p align="center">
  <img src="https://github.com/LucasSaenz4118/Path_planning_Matlab2024/blob/bd0c89e39a51e70d356132a829e1d2923d7373bc/qlearning/Imagenes/Comparativa_Costos_20240607T183440072.png" alt="Comparativa de Costos 1" width="30%" />
  <img src="https://github.com/LucasSaenz4118/Path_planning_Matlab2024/blob/bd0c89e39a51e70d356132a829e1d2923d7373bc/qlearning/Imagenes/Comparativa_Costos_20240612T190918252_1000episodios.png" alt="Comparativa de Costos 2" width="30%" />
</p>

## Pruebas.m
Script que sirve para hacer pruebas con el algoritmo de Q-learning y un mapa de referencia.
