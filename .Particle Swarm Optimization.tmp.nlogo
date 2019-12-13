;--------------------------------- Load PSO Module ---------------------------------------------

__includes ["SBPSO.nls"]


globals [
  global-best-pos ;gonna be a set which stores the global best set (position)
  global-best-value ;gonna be a set which stores the value of that position (fitness function return)
  U ;gonna be a set, basically our search space
  weight-knapsack
]


breed [elements element]
elements-own
[
  weight ;weight of the element
  price ;price
  part-of-global-best? ;boolean to see if it is part of the global solution
]


;setup function in order to initialize search space
to setup
  clear-all
  reset-ticks
  ask patches [
    set pcolor white ;pcolor white in order to see the elements better
  ]
  create-elements poblacion ;user adaptable variable
  set-basic-values-elements ; color, shape, random weight and price and position
  set-random-solution ; set initial solution of turtles in order to start the search

  set U elements

  ask turtles [
    set posi personal-best-pos
  ]

  ask one-of turtles [
    set global-best-pos personal-best-pos
    set global-best-value evalPosition personal-best-pos
    set-global-solution who
    set weight-knapsack calculateWeight global-best-pos
  ]

end

to-report AI:evaluation
  report evalPosition posi
end


to go
  ask turtles [
    let posPoints evalPosition posi
    if posPoints > personal-best-val [
      set personal-best-pos posi
      set personal-best-val posPoints
    ]
    if posPoints > global-best-value [
      set global-best-pos posi
      set global-best-value posPoints

      set-global-solution who
      set weight-knapsack calculateWeight global-best-pos
    ]
  ]
  ask turtles [
    set velocity updateVelocity who
       ;Update the position of the particle
    set posi applyVel posi velocity

  ]
  tick
end


to-report calculateWeight [sol]
  let totalWeight 0
  foreach sol [x ->
    ask x [
      set totalWeight (totalWeight + weight)]
    ]
  report totalWeight
end

to rand-xy-co
  move-to one-of patches with [ not any? elements-here ]
end



to set-basic-values-elements
    ask elements [
    rand-xy-co
    set color blue
    set shape "square"
    set size patch-size * 2
    set part-of-global-best? false
    set weight random max-weight-elements
    set price random max-price-elements
    output-print word "Element Num: " who
    output-print word "Weight: " weight
    output-print word "Price: " price
    output-print "------"
  ]
end



;function which evaluates the current solution
;adds all the weights and sees if it is smaller thant the weight constraint
;objective is to maximize the prize
to-report evalPosition [solution]
  let weightSol 0
  let priceSol 0
  foreach solution [x ->
    ask x [
      set weightSol (weightSol + weight)
      set priceSol (priceSol + price)
    ]
  ]
  ifelse weightSol < weight-constraint [
    report priceSol
  ][
    report -999999999999990
  ]
end






@#$#@#$#@
GRAPHICS-WINDOW
235
10
645
421
-1
-1
2.0
1
10
1
1
1
0
1
1
1
-100
100
-100
100
1
1
1
ticks
30.0

TEXTBOX
0
0
0
0
NIL
11
0.0
1

BUTTON
165
80
225
113
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
165
150
225
183
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
10
45
225
78
poblacion
poblacion
1
1000
510.0
1
1
NIL
HORIZONTAL

SLIDER
10
185
225
218
#atraction-best-personal
#atraction-best-personal
0
1
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
10
220
225
253
#atraction-best-global
#atraction-best-global
0
1
0.9
0.1
1
NIL
HORIZONTAL

BUTTON
165
115
225
148
Un paso
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
725
160
850
205
Mejor valor encontrado
global-best-value
4
1
11

MONITOR
650
160
707
205
Media:
mean [personal-best-val] of turtles
4
1
11

SLIDER
10
255
182
288
weight-constraint
weight-constraint
100
1000
736.0
1
1
NIL
HORIZONTAL

OUTPUT
880
25
1120
565
11

SLIDER
10
290
187
323
#atraction-ktor-random
#atraction-ktor-random
1
10
1.0
0.1
1
NIL
HORIZONTAL

MONITOR
650
210
707
255
WEIGHT
weight-knapsack
17
1
11

PLOT
650
10
850
160
BEST-GLOBAL-VALUE
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot global-best-value"

SLIDER
10
335
182
368
max-weight-elements
max-weight-elements
10
100
21.0
1
1
NIL
HORIZONTAL

SLIDER
10
370
182
403
max-price-elements
max-price-elements
0
100
45.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
¿QUÉ ES?
-----------
Particle swarm optimization (PSO, Optimización por Enjambres de Partículas) es una técnica de optimización/búsqueda en el campo del aprendizaje automático. Aunque normalmente el PSO se usa en espacios de búsqueda con muchas dimensiones, en este modelo se hará uso de un espacio bidimensional, con el fin de facilitar la visualización.

Formalmente hablando, dada una función desconocida, f(x,y), se intentan encontrar valores de x e y para los que la función f(x,y) es máxima.  A f(x,y) se le suele llamar función de fitness, ya que determina cómo de buena es la posición actual para cada partícula. La función de fitness es también llamada a veces "paisaje de fitness", ya que puede verse como un paisaje con valles y colinas.

Una aproximación a este problema podría ser la selección aleatoria de valores de x e y, y almacenar el mayor de los resultados encontrados (búsqueda aleatoria). Para muchos espacios de búsqueda este método es ineficiente, por lo que se deben usar otros métodos más "inteligentes". PSO es una de tales técnicas. Las partículas se sitúan en el espacio de búsqueda y se mueven a través del espacio de acuerdo con reglas que tienen en cuenta el conocimiento personal de cada partícula y el conocimiento global del enjambre.  A través de sus movimientos, las partículas descubren valores particularmente altos para f(x,y).

Este modelo está basado en el algoritmo descrito en el artículo original de Kennedy y Eberhart (ver referencia más abajo). Sin embargo, el modelo que aquí se presenta tiene solo un fin ilustrativo, y no pretende ser una réplica exacta del original. Fueron necesarias algunas modificaciones por el hecho de trabajar sobre un toro y para mejorar la visualización. Además, la función que se optimiza es discreta (basada en una malla de valores) y no definida sobre un continuo.


¿CÓMO FUNCIONA?
-------------
Cada partícula tiene una posición (xcor, ycor) en el espacio de búsqueda y una velocidad (vx, vy) con la que se mueve a través del espacio. Las partículas tienen una cantidad de inercia, que los mantiene en la misma dirección en la que se movían.
También tienen aceleración (cambio de velocidad), que depende principalmente de dos cosas:

1) Cada partícula es atraída hacia la mejor localización que ella, personalmente, ha encontrado en su historia (mejor personal).

2) Cada partícula es atraída  hacia la mejor localización que ha sido encontrada globalmente en el espacio de búsqueda (mejor global).

La fuerza con que las partículas son empujadas en cada una de estas direcciones depende de los parámetros ATRACCION-AL-MEJOR-PERSONAL Y ATRACCION-AL-GLOBAL-MEJOR. A medida que las partículas se alejan de estas localizaciones mejores, la fuerza de atracción es mayor. También hay un factor aleatorio que influye en cómo las partículas son empujadas hacia estas localizaciones.

En este modelo, el PS intenta optimizar  una función que viene determinada por los valores sobre una malla. El paisaje  se crea asignando aleatoriamente valores a cada uno de los puntos de la malla, posteriormente se aplica un proceso de difusión para suavizar los valores obtenidos, lo que proporciona un espacio con numerosos mínimos locales (valles) y máximos locales (colinas). Esta función ha sido creada así solo con fines ilustrativos. Habitualmente, en aplicaciones reales del PSO las variables (x,y,z,...) pueden corresponderse con parámetros de predicción de un mercado de valores, y la función f(x,y,z,...) podría evaluarse por medio de los datos históricos.

El modelo se ejecuta hasta que alguna partícula encuentra el verdadero óptimo real (cuyo valor es 1.00).


¿CÓMO SE USA?
-------------
Pulsa SETUP para crear la función de fitness y situar las partículas aleatoriamente en el espacio de búsqueda. Cada vez que se puse SETUP se creará un espacio aleatorio diferente.

El valor NUM-MAX-LOCALES determina cuántos máximos locales se crearán en la función. Si este valor se pone a 0, se crea un paisaje con un número no definido de máximos (y menos suave).

Pulsa UN PASO para avanzar un paso o GO para ejecutar el algoritmo PSO.

El slider SUAVIZAR-ESPACIO determina cuántos veces se suavizará la función aleatoria que se crea con el botón SETUP.

El slider POBLACION controla el número de partículas que se usarán.

El slider ATRACCION-A-MEJOR-PERSONAL determina la fuerza de atracción de cada partícula al punto que ella ha encontrado como el mejor de su historia, mientras que el slider ATRACCION-AL-GLOBAL-MEJOR determina la fuerza de atracción de cada partícula a la mejor localización descubierta por cualquier miembro del enjambre.

El slider INERCIA-PARTICULA controla la inercia que tiene cada partícula a seguir moviéndose en la dirección que va (normalmente, opuesta a las fuerzas de atracción causadas por las mejores localizaciones).

El slider LIMITE-VELOCIDAD-PARTICULA controla la máxima velocidad a la que puede moverse una partícula (e cualquiera de las direcciones).

El MODO-TRAZA permite seleccionar qué tipo de visualizaciónse usará para los caminos seguidos por las partículas.  "Trazas" significa que las partículas dejarán sus rastros indefinidamente en la vista. "Colas" significa que solo mostrarán el último paso ejecutado, mientras que "Ninguna" significa que no se mostrará ningún tipo de traza.  Obsérvese que la vista no se actualiza hasta que no se vuelve a pulsar GO o UN PASO.

El OBJETO-DESTACADO permite mostrar el óptimo de la función de fitness ("Mejor real") o el óptimo encontrado ("Mejor encontrado"). Obsérvese que la vista no se actualiza hasta que no se vuelve a pulsar GO o UN PASO.

El monitor MEJOR VALOR ENCONTRADO muestra el mejor global que se ha encontrado por el momento. Por la forma en que se ha construido la función, este máximo debe ser 1.0, y en el momento en que se encuentre, la simulación parará.


COSAS A TENER EN CUENTA
----------------
A menudo se ven partículas en recorriendo caminos (aproximadamente) elípticos. ¿Porqué crees que es así? (piensa en los principales factores que influyen en la velocidad de cada partícula.)

A veces el enjambre encuentra rápidamente el óptimo de la función (valor = 1.0) y otras se queda atascado en una zona errónea del espacio, y parece que nunca podrá salir de allí. Esta noción de quedar atrapado cerca de un "máximo local" que no es el óptimo global es un problema común que surge en muchas técnicas de optimización (método de la escalada, algoritmos genéticos, simulated annealing, etc). Una variación del algoritmo PSO usa una fuerza repulsiva entre las partículas para ayudar a mantenerlas separadas en el espacio de búsqueda y no favorecer ese proceso de atracción gravitatoria a valores suboptimales.


COSAS A INTENTAR
-------------
Sitúa el selector OBJETO-DESTACADO en "Mejor encontrado" y ejecuta la simulación varias veces. ¿Con qué frecuencia cambia la localización "Mejor global" de sitio?, ¿lo hace con más frecuencia al principio o al final de la simulación?

Intenta modificar el valor de INERCIA-PARTICULA. Cuando es 0.0 las partículas se mueven guiadas únicamente por los valores mejores (personal y global) encontrados, y no por su historia. Cuando es 1.0 la velocidad de las partículas nunca cambia, lo que resulta en un movimiento rectilíneo. ¿Puedes encontrar un valor óptimo de este parámetro entre estos dos casos extremos?, ¿crees que este valor óptmo depende de otros factores, tales como población, suavidad o atracción?


EXTENDIENDO EL MODELO
-------------------
Añade una fuerza repulsiva entre las partículas para intentar prevenr que todas ellas converjan prematuramente a una pequeña zona del espacio de búsqueda.

El espacio de búsqueda en este modelo es una función aleatoria sin más significado, intenta cambiarlo por un espacio que represente algo real.

¿Qué pasa si la función que intenta ser optimizada cambia en el tiempo? Modifica el modelo para que las partículas intenten encontrar la mejor solución en un entorno dinámico. Si el cambio en la función no es excesivamente rápido, ¿puede el enjambre seguir el movimiento del máximo a medida que se traslada por el espacio?

Hay muchas otras posibles variaciones en un modelo PSO, busca en la web más variantes y modifica el modelo para que se adpate a ellas, o bien inventa tus propias variantes.


CARACTERÍSTICAS NETLOGO
----------------
Usar combinaciones de primitivas del lenguaje de NetLogo puede evitar los comportamientos extraños en la frontera de lo mundos toroidales. Cuando se decide cómo debe modificarse la velocidad de cada partícula, necesitamos alguna forma de obtener un vector que vaya de la posición de cada partícula a algún otro punto del espacio (el mejor personal, o el mejor global). En un espacio 2D no acotado se puede calcular este vector por medio de la diferencia (X-GOAL - XCOR) y (Y-GOAL - YCOR).  Sin embargo, este truco no funciona en un mundo toroidal (¿porqué?). Por ello, se usa FACEXY para apuntar la tortuga en la dirección correcta, extraemos DX y DY como vector unitario en esa dirección, y multiplicamos el vector resultante por DISTANCEXY a esa localización objetivo para obtener un vector de la longitud correcta.


RELATED MODELS
--------------
Simple Genetic Algorithm, Artificial Neural Net, Perceptron, Hill Climbing Example (Code Example).


CREDITS AND REFERENCES
----------------------
Based on the algorithm presented in the following paper: Kennedy, J. & Eberhart, R. (1995), 'Particle swarm optimization', Neural Networks, 1995. Proceedings., IEEE International Conference on 4.


HOW TO CITE
-----------
If you mention this model in an academic publication, we ask that you include these citations for the model itself and for the NetLogo software:
- Stonedahl, F. and Wilensky, U. (2008).  NetLogo Particle Swarm Optimization model.  http://ccl.northwestern.edu/netlogo/models/ParticleSwarmOptimization.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
- Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

In other publications, please use:
- Copyright 2008 Uri Wilensky. All rights reserved. See http://ccl.northwestern.edu/netlogo/models/ParticleSwarmOptimization for terms of use.


COPYRIGHT NOTICE
----------------
Copyright 2008 Uri Wilensky. All rights reserved.

Permission to use, modify or redistribute this model is hereby granted, provided that both of the following requirements are followed:
a) this copyright notice is included.
b) this model will not be redistributed for profit without permission from Uri Wilensky. Contact Uri Wilensky for appropriate licenses for redistribution for profit.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
