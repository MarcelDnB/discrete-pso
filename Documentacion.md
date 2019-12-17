# Optimización con PSO basado en conjuntos (SBPSO)

La implementación del algoritmo SBPSO que se verá a continuación esta basada en el trabajo de fin de Máster de Joost Langeveld, por lo que en esta descripción de nuestra implementación vamos a hacer numerosas referencias a este trabajo aunque hemos hecho ciertos cambios.

##### Vamos a describir a continuación los conceptos del SBPSO:

1.  En primer lugar tenemos que definir un espacio de búsqueda al igual que en PSO, solo que en este caso nuestro espacio de búsqueda en vez de ser un espacio continuo vamos a tener un espacio discreto y por lo tanto con un número finito de elementos. Lo vamos a representar con U, donde U es un conjunto de elementos.
2. Vamos a necesitar una variable posición de las partículas, a diferencia de PSO donde la posición es una coordenada, en SBPSO estará formada por un conjunto de elementos del espacio de búsqueda (U).    La vamos a representar con Xi, donde Xi es un conjunto de ciertos elementos.
3. Vamos a tener al igual que en PSO una velocidad de las partículas, en PSO la velocidad es una magnitud que se representa numéricamente, mientras que en SBPSO tendremos un conjunto de expresiones que nos indicaran si tenemos que añadir o eliminar elementos de una posición dada.           La vamos a representar con Vi, donde Vi es una lista de sub-listas que contendrán elementos que tenemos que modificar.
4. Necesitaremos una función objetivo que habrá que optimizar. La vamos a representar con f.
5. Cada una de las partículas va a tener una variable local donde guarde su mejor valor personal encontrado hasta el momento. La vamos a representar con Yi, donde Yi es un conjunto de elementos.
6. Hay también una variable global en la que se guardará el mejor valor encontrado por las partículas. La vamos a representar como ^Yi, donde ^Yi es un conjunto de elementos



## Explicación simple del algoritmo

Para explicar el funcionamiento del algoritmo voy a suponer que solo tenemos una sola partícula buscando, para que sea mas fácil de ver el funcionamiento global.

La posición de la partícula estará formada por ciertos elementos Xi={e1,e2...,en} de nuestro espacio de búsqueda U, esta posición tendrá cierto valor que se calculara en cada iteración mediante la función objetivo y de esta manera sabremos si la posición en la que esta es buena o mala. En las distintas iteraciones la posición de la partícula deberá cambiar y esto es posible gracias a la velocidad. La velocidad es con conjunto de ciertas expresiones que nos indicaran como cambiar la posición de la partícula, es decir, nos indicará que elementos tenemos que añadir y cuales eliminar de forma que en cada iteración la posición de la partícula vaya variando y por supuesto para cada una de estas diferentes posiciones se calculara su valor.

![](C:\Users\Marcel\OneDrive - UNIVERSIDAD DE SEVILLA\GitHub\discrete-pso\particula-u.jpg)

Como vemos en la imagen a) tenemos representada una partícula conteniendo 5 elementos del espacio de búsqueda. Es muy importante tener en cuenta que los elementos del espacio no tienen orden, es decir, que para los elementos de la partícula no podemos decir que uno esté mas cerca del otro ya que es un conjunto y todos los elementos están igual de cerca unos de otros. En la imagen b) tenemos representado el mejor personal de la partícula, donde los rombos indican que esos elementos están dentro de su posición y los asteriscos indican que están fuera.

Si encontramos un valor mejor que el mejor personal habrá que sustituirlo por el valor encontrado, y por otro lado si encontramos uno mejor que el mejor global se cambiará también por el encontrado.



## Definición de los operadores

- La unión/adición de dos velocidades, vamos a tomar 2 velocidades, donde cada velocidad es un conjunto, y los vamos a unir. Lo vamos a representar mediante el símbolo ⊕.
- La diferencia entre 2 posiciones (X1 y X2), tomamos 2 posiciones y vamos a devolver una velocidad. Para ello vamos a considerar los elementos que están en X1 y no en X2 como elementos a añadir y los elementos que están en X2 y no en X1 como elementos a eliminar, y con estos formamos la velocidad que devolveremos. Lo vamos a representar mediante ⊖.
- La multiplicación de una velocidad por un escalar, tomamos un escalar (eta) cuyo valor esta comprendido entre [0,1]  y una velocidad (V), vamos a devolver una sub-lista al azar de V donde eta será un porcentaje de elementos a seleccionar de V para dicha sub-lista. Lo vamos a representar mediante ⊗.
- La adición de una velocidad y posición, con este operador vamos a aplicar una velocidad a una posición. Vamos a hacer los cambios que se nos indica la velocidad al conjunto posición. La vamos a representar mediante ⊞.
- La eliminación de elementos en X(t) ∩ Y(t) ∩ ^Y(t) de una posición X(t) va a utilizar el operador ⊙−.
- La adición de elementos fuera de X(t) ∪ Y(t) ∪ ^Y(t) a X(t) va a utilizar el operador ⊙+



## ¿Cómo funciona la librería SBPSO?

En primer lugar, tenemos 3 variables globales, `global-best-pos`, `global-best-value` y `U`, donde se indica la mejor posición global, el mejor valor global (de dicha posición), y el espacio de búsqueda U respectivamente.

En segundo lugar definimos la raza `particulas` donde los valores locales de cada `particula` son `personal-best-pos`, `personal-best-val`,  `posi` y `velocity`, donde se indica la mejor posición personal, el mejor valor personal (de dicha posición), la posición y la velocidad respectivamente.

La velocidad la hemos considerado como  una lista de 2 sub-listas donde cada sub-lista es formada por ciertos elementos, la primera sub-lista nos indica los elementos que debemos añadir y la segunda los elementos que debemos eliminar (de cierta posición).

##### La librería cuenta con dos funciones fundamentales que son:

`updateVelocity:`Función encargada de actualizar la velocidad en cada iteración de todas las partículas que hayamos creado.  Para ello hemos aplicado la fórmula con unos pequeños cambios:

![](C:\Users\Marcel\OneDrive - UNIVERSIDAD DE SEVILLA\GitHub\discrete-pso\formula.jpg)

El cambio que hay en la implementación comparado con la fórmula anterior es en la ultima parte    (c4r4)⊙−Si(t)) donde en nuestra implementación seleccionamos al azar elementos de Si(t).

`applyVel:` Función que se encarga de aplicar una velocidad a una posición.



Para poder hacer las dos funciones descritas anteriormente es necesario definir los operadores necesarios que se encontraran en la parte de OPERATORS (delimitada por comentario) dentro de la librería. Además la librería contendrá otras funciones para inicialización y auxiliares para actualizar el output con el mejor conjunto global encontrado.

Hemos decidido mantener fuera la función general que controla las iteraciones para dejar mas libertad a la hora de utilizar la librería para un problema, aunque podría ir perfectamente dentro de la librería, *función `go` *









