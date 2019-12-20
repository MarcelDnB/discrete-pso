;--------------------------------- Load PSO Module ---------------------------------------------
__includes ["SBPSO.nls"]

globals [
weight-knapsack ;to represent the weight of the knapsack in the interface
]

breed [elements element] ;elements to fill the knapsack
elements-own
[
  weight ;weight of the element
  price ;price
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
  create-particles particulas
  set-random-solution ; set initial solution of turtles in order to start the search

  set U elements ;the set of all elements we have

  ask particles [
    set posi personal-best-pos ;put the personal best position in the actual position of the turtle
  ]

  ask one-of particles [ ;asign the global best to a random turtle
    set global-best-pos personal-best-pos ;personal best is assigned to global best (for initialization)
    set global-best-value evalPosition personal-best-pos
    set-global-solution who
    set weight-knapsack calculateWeight global-best-pos
  ]
end


to set-basic-values-elements ;for the graphic representation of elements
    ask elements [
    move-to one-of patches with [ not any? elements-here ] ;to disperse elements in the interface graphic output
    set color blue
    set shape "square"
    set size patch-size * 2
    set weight random max-weight-elements
    set price random max-price-elements
    output-print word "Element Num: " who
    output-print word "Weight: " weight
    output-print word "Price: " price
    output-print "------"
  ]
end


to go
run-SBPSO
end


to-report calculateWeight [sol] ;calculates the total weight of a set of elements
  let totalWeight 0
  foreach sol [x ->
    ask x [
      set totalWeight (totalWeight + weight)]
    ]
  report totalWeight
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
  ifelse weightSol <= weight-constraint [
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

BUTTON
10
295
70
328
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
85
295
155
328
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
10
225
43
poblacion
poblacion
1
1000
401.0
1
1
NIL
HORIZONTAL

SLIDER
10
50
225
83
#atraction-best-personal
#atraction-best-personal
0
1
0.8
0.1
1
NIL
HORIZONTAL

SLIDER
10
90
225
123
#atraction-best-global
#atraction-best-global
0
1
0.8
0.1
1
NIL
HORIZONTAL

BUTTON
170
295
225
330
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
650
170
850
215
Mejor valor encontrado
global-best-value
4
1
11

SLIDER
10
130
225
163
weight-constraint
weight-constraint
100
1000
100.0
1
1
NIL
HORIZONTAL

OUTPUT
865
10
1030
550
11

MONITOR
650
225
850
270
Peso actual
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
170
225
203
max-weight-elements
max-weight-elements
10
100
30.0
1
1
NIL
HORIZONTAL

SLIDER
10
210
225
243
max-price-elements
max-price-elements
0
100
45.0
1
1
NIL
HORIZONTAL

TEXTBOX
250
430
645
506
ROJO - FORMA PARTE DE LA SOLUCIÓN GLOBAL\nAZUL - NO FORMA PARTE DE LA SOLUCIÓN GLOBAL
16
0.0
0

SLIDER
10
250
225
283
particulas
particulas
1
1000
51.0
10
1
NIL
HORIZONTAL

@#$#@#$#@
# Ver mejor en el repositorio
# Optimización con PSO basado en conjuntos SBPSO

La implementación del algoritmo SBPSO que se verá a continuación esta basada en el trabajo de fin de Máster de Joost Langeveld, por lo que en esta descripción de nuestra implementación vamos a hacer numerosas referencias a este trabajo aunque hemos hecho ciertos cambios.

##### Vamos a describir a continuación los conceptos del SBPSO:

1.  En primer lugar tenemos que definir un espacio de búsqueda al igual que en PSO, solo que en este caso nuestro espacio de búsqueda en vez de ser un espacio continuo vamos a tener un espacio discreto y por lo tanto con un número finito de elementos. Lo vamos a representar con U, donde U es un conjunto de elementos.
2. Vamos a necesitar una variable posición de las partículas, a diferencia de PSO donde la posición es una coordenada, en SBPSO estará formada por un conjunto de elementos del espacio de búsqueda (U).    La vamos a representar con Xi, donde Xi es un conjunto de ciertos elementos.
3. Vamos a tener al igual que en PSO una velocidad de las partículas, en PSO la velocidad es una magnitud que se representa numéricamente, mientras que en SBPSO tendremos un conjunto de expresiones que nos indicaran si tenemos que añadir o eliminar elementos de una posición dada.           La vamos a representar con Vi, donde Vi es una lista de sub-listas que contendrán elementos que tenemos que modificar.
4. Necesitaremos una función objetivo que habrá que optimizar. La vamos a representar con f.
5. Cada una de las partículas va a tener una variable local donde guarde su mejor valor personal encontrado hasta el momento. La vamos a representar con Yi, donde Yi es un conjunto de elementos.
6. Hay también una variable global en la que se guardará el mejor valor encontrado por las partículas. La vamos a representar como ^Yi, donde ^Yi es un conjunto de elementos



## Explicación simple del algoritmo

Para explicar el funcionamiento del algoritmo vamos a suponer que solo tenemos una sola partícula buscando, para que sea mas fácil de ver el funcionamiento global.

La posición de la partícula estará formada por ciertos elementos Xi={e1,e2...,en} de nuestro espacio de búsqueda U, esta posición tendrá cierto valor que se calculara en cada iteración mediante la función objetivo y de esta manera sabremos si la posición en la que esta es buena o mala. En las distintas iteraciones la posición de la partícula deberá cambiar y esto es posible gracias a la velocidad. La velocidad es con conjunto de ciertas expresiones que nos indicaran como cambiar la posición de la partícula, es decir, nos indicará que elementos tenemos que añadir y cuales eliminar de forma que en cada iteración la posición de la partícula vaya variando y por supuesto para cada una de estas diferentes posiciones se calculara su valor.

![](images/particula-u.jpg)

Como vemos en la imagen a) tenemos representada una partícula conteniendo 5 elementos del espacio de búsqueda. Es muy importante tener en cuenta que los elementos del espacio no tienen orden, es decir, que para los elementos de la partícula no podemos decir que uno esté mas cerca del otro ya que es un conjunto y todos los elementos están igual de cerca unos de otros. En la imagen b) tenemos representado el mejor personal de la partícula, donde los rombos indican que esos elementos están dentro de su posición y los asteriscos indican que están fuera.

Si encontramos un valor mejor que el mejor personal habrá que sustituirlo por el valor encontrado, y por otro lado si encontramos uno mejor que el mejor global se cambiará también.

![](images/particula-ex.jpg)

Para ponernos mas en contexto podemos ver en la figura a) una posición en el tiempo t y la misma posición en el siguiente instante de tiempo. Como podemos observar la velocidad ha indicado que había que eliminar los elementos representados con un rombo y añadir los que están representados por asteriscos. Y en la figura b) podemos ver la posición actual junto a la mejor local y global.

## Definición de los operadores

- La unión/adición de dos velocidades, vamos a tomar 2 velocidades, donde cada velocidad es un conjunto, y los vamos a unir. Lo vamos a representar mediante el símbolo ⊕.
- La diferencia entre 2 posiciones (X1 y X2), tomamos 2 posiciones y vamos a devolver una velocidad. Para ello vamos a considerar los elementos que están en X1 y no en X2 como elementos a añadir y los elementos que están en X2 y no en X1 como elementos a eliminar, y con estos formamos la velocidad que devolveremos. Lo vamos a representar mediante ⊖.
- La multiplicación de una velocidad por un escalar, tomamos un escalar (eta) cuyo valor esta comprendido entre [0,1]  y una velocidad (V), vamos a devolver una sub-lista al azar de V donde eta será un porcentaje de elementos a seleccionar de V para dicha sub-lista. Lo vamos a representar mediante ⊗.
- La adición de una velocidad y posición, con este operador vamos a aplicar una velocidad a una posición. Vamos a hacer los cambios que se nos indica la velocidad al conjunto posición. La vamos a representar mediante ⊞.
- La eliminación de elementos en X(t) ∩ Y(t) ∩ ^Y(t) de una posición X(t) va a utilizar el operador ⊙−.
- La adición de elementos fuera de X(t) ∪ Y(t) ∪ ^Y(t) a X(t) va a utilizar el operador ⊙+



# Funcionamiento de la librería SBPSO

## Explicación general

En primer lugar, tenemos 3 variables globales, `global-best-pos`, `global-best-value` y `U`, donde se indica la mejor posición global, el mejor valor global (de dicha posición), y el espacio de búsqueda U respectivamente.

En segundo lugar definimos la raza `particulas` donde los valores locales de cada `particula` son `personal-best-pos`, `personal-best-val`,  `posi` y `velocity`, donde se indica la mejor posición personal, el mejor valor personal (de dicha posición), la posición y la velocidad respectivamente.

La velocidad la hemos considerado como  una lista de 2 sub-listas donde cada sub-lista es formada por ciertos elementos, la primera sub-lista nos indica los elementos que debemos añadir y la segunda los elementos que debemos eliminar (de cierta posición).

##### La librería cuenta con dos funciones fundamentales que son:

`updateVelocity:`Función encargada de actualizar la velocidad en cada iteración de todas las partículas que hayamos creado.  Para ello hemos aplicado la fórmula con unos pequeños cambios:

![](images/formula.jpg)

El cambio que hay en la implementación comparado con la fórmula anterior es en la ultima parte    (c3r3⊙+Ai(t))⊕(c4r4)⊙−Si(t)) donde en nuestra implementación le hemos hecho algunos cambios al operador ⊙+ para que no necesite c3 y r3 y en la siguiente expresión seleccionamos al azar elementos de Si(t) sin necesitar c3 y r4.

`applyVel:` Función que se encarga de aplicar una velocidad a una posición.

![](images\formula-pos.jpg)

Para poder hacer las dos funciones descritas anteriormente es necesario definir los operadores necesarios que se encontraran en la parte de OPERATORS (delimitada por comentario en el código) dentro de la librería. Además la librería contendrá otras funciones para inicialización y auxiliares para actualizar el output con el mejor conjunto global encontrado.

Además de las funciones vistas anteriormente necesitamos saber si nos encontramos un valor mejor en cada una de las iteraciones y actualizar los valores que teníamos hasta entonces, para ello está la función `run-SBPSO`, con la cual vamos a buscar el máximo, pero además de eso estamos actualizando tanto la velocidad como la posición de cada una de las partículas (si tenemos varias trabajando).



## Explicación de las funciones en detalle

`updateVelocity:`Aplicamos la formula anteriormente vista con la ayuda de los operadores que tenemos definidos.



`applyVel:`Dada una velocidad ->{ (elementos a añadir), (elementos a eliminar) }  y una posición ->{e1,e2,e3..en}, aplicamos los cambios que nos indica la velocidad a la posición. Para ello mediante un filtro eliminamos de la posición los elementos que nos indica la velocidad en su segunda sub-lista y mediante un `sentence` unificamos la posición con la primera sub-lista de la velocidad.



`run-SBPSO:`Esta función se encarga de la actualización global de todas las variables. Preguntamos a todas las partículas la posición en la que está actualmente y comprobamos si es mayor que el mejor personal de la partícula y si es así le asignamos al mejor personal el nuevo mejor valor, lo mismo ocurre con la variable mejor global, si encontramos una mejor que el mejor global cambiamos este con el nuevo mejor valor, eso si, el valor global es compartido por todas las partículas. En esta función también llamamos a dos funciones que se van a encargar de actualizar la velocidad de cada partícula y actualizar su posición.



`union:`Mediante un `sentence` unificamos las dos listas que se nos pasa y eliminamos los duplicados.



`difference:`Tomamos 2 posiciones y vamos a devolver una velocidad. Para ello vamos a considerar los elementos que están en set1 y no en set2 como elementos a añadir y los elementos que están en set2 y no en set1 como elementos a eliminar, y con estos formamos la velocidad que devolveremos que es una lista de sub-listas de las dos operaciones descritas anteriormente.



`prodVel:`Se nos pasa una variable eta y una velocidad, como eta tiene un valor comprendido entre [0,1] si multiplicamos ese valor por el tamaño de las dos sub-listas de la velocidad obtenemos un valor diferente según la probabilidad varíe, posteriormente vamos a coger un número de elementos según nos indique el valor calculado anteriormente.



`k-tournamentSelection:` Es una función que como su nombre indica se trata de un tournamentSelection, que selecciona aleatoriamente elementos y los añade a la posición para posteriormente evaluar la nueva posición con el elemento aleatorio añadido aleatoriamente. Esto lo hace un número N de veces y finalmente devolvemos la posición con los elementos añadidos que haya tenido mas valor.



`set-random-solution:` Esta función esta solamente para inicializar. Le decimos a todas las partículas que tomen unos elementos aleatorios del espacio de búsqueda básicamente para que tengan un conjunto inicial como posición, además también inicializamos su mejor personal con un elemento aleatorio.



`set-global-solution:` Sirve para actualizar el mejor global gráficamente, primero para el conjunto anterior de mejor global ponemos todos los elementos en azul, lo que indica que no están en el conjunto y posteriormente cogemos el nuevo mejor global y cada elemento perteneciente lo ponemos en rojo, lo que indica que sí están en el mejor global.



# Problema de la mochila con SBPSO

## ¿Cómo se ha implementado?

Para poner a prueba la librería descrita anteriormente vamos a implementar el problema de la mochila con SBPSO. 

Para ello vamos a necesitar una raza para los elementos/objetos con los que vamos a trabajar, y cada uno de estos elementos tendrá un peso y un precio. Vamos a necesitar inicializar bastantes variables y crear la población de las partículas y la de los elementos, para ello tenemos la función `setup`.  Aparte de esto vamos a necesitar implementar una función de evaluación que nos diga cuando una posición de una partícula es mejor o peor, luego como necesitamos el máximo valor vamos a devolver siempre el valor que tenga una posición viendo el valor que tiene cada uno de los elementos contenidos en esta, pero necesitamos no pasarnos del límite de peso, por lo que cuando exista una posición que se pase de ese límite devolveremos un valor negativo absurdamente grande para asegurar que nunca nos pasaremos de dicho límite.

## Uso de la interfaz gráfica

En la interfaz gráfica tenemos varias variables globales que podemos ir modificando:

1. `poblacion:`Será la cantidad de elementos/objetos dentro del espacio de búsqueda.
2. `#atraction-best-personal:`Su valor está comprendido entre [0,1], y corresponde a la variable de atracción a la mejor posición personal encontrada. (Valor propio de la librería)
3. `#atraction-best-global:`Su valor está comprendido entre [0,1], y corresponde a la variable de atracción a la mejor posición global encontrada. (Valor propio de la librería)
4. `weight-constraint:`Es el límite de peso que nosotros queramos poner, es decir, no será valida ninguna posición que se pase de este valor y esto es posible gracias a la función de evaluación vista anteriormente.
5. `max-weight-elements y max-price-elements:`Estas variables determinan el peso y valor máximo de los elementos que generamos aleatoriamente para el ejemplo.
6. `particulas:`Determina el número de partículas que estarán activas cuando ejecutemos el programa.

Para comenzar con el problema necesitamos presionar el botón 'setup' para inicializar variables, numero de partículas, etc. Podemos ejecutarlo paso a paso mediante el botón 'Un paso' o ejecutar continuamente los pasos hasta que nosotros decidamos mediante 'go'.

La interfaz gráfica también dispone de una grafica que nos muestra el conjunto de todos los elementos que tenemos en nuestro espacio de búsqueda, cuando el algoritmo se esté ejecutando iremos viendo que algunos de los elementos de color azul cambiarán su color a rojo. Estamos considerando que los elementos de color azul no pertenecen a la mejor posición global encontrada hasta el momento mientras que los de color rojo si, luego a medida que el algoritmo vaya avanzando iremos viendo como cambian los elementos de la mejor posición global. También podremos ver los elementos de dicha mejor posición global en la terminal. 

Existe también una grafica que nos va mostrando la mejora del valor total de la mejor posición global hasta el momento, e iremos viendo como sube a medida que avanza el algoritmo. Junto a ella tenemos dos monitores que nos indicarán el valor de la mejor posición encontrada hasta el momento y el peso de esa posición global.

Para ver todos elementos hay un cuadro de salida que nos muestra todos los elementos aleatorios que se han creado, el número correspondiente al elemento junto al peso y el valor.



# Bibliografía

1. http://www.cs.us.es/~fsancho/ficheros/IA2019/Set-BasedPSO.pdf (Trabajo de Máster)
2. https://github.com/fsancho/IA/tree/master/09.%20Optimization
3. https://ccl.northwestern.edu/netlogo/docs/programming.html
4. https://www.youtube.com/watch?v=JhgDMAm-imI
5. http://netlogo-users.18673.x6.nabble.com/
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
NetLogo 6.1.0
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
