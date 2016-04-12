;------------------------- Variables -------------------------

;Familia de agentes.
breed [vertices vertice]
breed [recorredores recorredor]
breed [fachadas fachada]
breed [observadores observador]
breed [individuos individuo]

;Propiedades de los vértices (esquinas que definen la fachada del modelo).
vertices-own[
  etiqueta
]

;Propiedades de los recorredores (recorren la fachada del modelo).
recorredores-own[
  origen
  angulo-incidencia
  patch-inicio
  patch-fin
]

;Propiedad de la fachada, agente tipo link que se definen entre dos agentes tipo vértice.
fachadas-own[
  longitud
  orientacion-cono
]

;Propiedades de los observadores.
observadores-own[
  numero-paramentos
  angulo-minimo
]

; Un individuo representa una solucion del problema, con un conjunto de posiciones correspondientes a los observadores, y una lista que indican si estan activados o no
individuos-own
[
  ; Genes
  lista-observadores
  lista-activaciones

  ; Propiedades
  fitness
]

;Propiedades tortugas.
turtles-own[
  tipo
  visitado
]

;Propiedades del suelo.
patches-own[
  interior
  vertice-encima
  valor-observado
  recorredorVisto
  recorredores-vistos
]

;Variables globales.
globals[
  pulsado
  etiqueta-global
  clock
  poder-mover
  grafo-finalizado
  contador-recorredores
  contador-recorredores-vistos

  ; El numero de observadores determina la longitud de los genes de cada individuo
  numero-observadores
]

;------------------------- Limpiar mundo -------------------------

;Método para limpiar el mundo.
to borrar-todo
 __clear-all-and-reset-ticks
 set contador-recorredores 0
 set contador-recorredores-vistos 0
 ask patches[
   set vertice-encima false
   ]
set grafo-finalizado false
reset-timer
end

;------------------------- Planta del edificio -------------------------

;------------------------- Modo manual -------------------------

;Método para dibujar los vértices con el ratón.
to dibuja-vertices

 if mouse-inside? and mouse-down? != pulsado
 [
  ifelse grafo-finalizado = false
  [

   let m-xcor mouse-xcor
   let m-ycor mouse-ycor

   ask patch m-xcor m-ycor
   [
     if vertice-encima = false
     [
       sprout-vertices 1
       [
         set shape "circle"
         set color green
         set label-color white
         set size 3
         set etiqueta who
         set etiqueta-global who
        ]
       crear-arista
       ver-etiquetas
       set vertice-encima true
     ]
   ]
 ][
 user-message( "No se puede modificar el grafo una vez finalizado." )
 ]
 ]
 set pulsado mouse-down?

end

;Método para crear aristas entre los distintos vértices pero siempre con el anterior.
to crear-arista

  if etiqueta-global != 0
  [
    ask vertices with[etiqueta = etiqueta-global]
    [
      create-link-with one-of other vertices with[etiqueta = etiqueta-global - 1]
    ]
  ]

end

;Método para mostrar las etiquetas de los nodos
to ver-etiquetas
 ask vertices
 [
  set label who
  set label-color white
 ]
end

;Método para calcular las etiquetas del vecino.
to-report calcular-etiqueta-vecino [etiq]
  report (etiq + 1) mod (etiqueta-global + 1)
end

;Método para cerrar el grafo, conecta el último vértice con el cero.
to cerrar-grafo
   ifelse grafo-finalizado = false
  [
  ask vertices[
       if etiqueta = 0[
         create-link-with one-of other vertices with[etiqueta = etiqueta-global]
         ]
       ]
  ][
  user-message( "No se puede modificar el grafo una vez finalizado." )
  ]
end

;Método para poder mover el grafo por el entorno.
to mover-grafo

 if mouse-down?
 [
   ifelse grafo-finalizado = false
  [
  let grabbed min-one-of vertices [distancexy mouse-xcor mouse-ycor]

  while [mouse-down?]
  [
   ask grabbed [ setxy mouse-xcor mouse-ycor ]
   display
  ]
  ][
  user-message( "No se puede modificar el grafo una vez finalizado." )
  ]
 ]

end

;Método para terminar el grafo y dejarlo definitivo y coloreado.
to finalizar-grafo
  ifelse grafo-finalizado = false
  [

 let angulo 0
  ask vertices
  [
    hatch 1
    [
      let etiqueta-vecino calcular-etiqueta-vecino etiqueta
      let vecino vertice etiqueta-vecino
      face vecino

      while [(distance vecino) > 0.5]
      [ ask patch xcor ycor
        [ if (pcolor != orange) [set pcolor orange ask neighbors [set pcolor orange]]
          sprout-recorredores 1
          [ setxy xcor ycor
            face vecino
            set contador-recorredores contador-recorredores + 1
            set color orange
            ask patch-right-and-ahead 90 1
            [
             if pcolor = black [set pcolor white]
            ]
;                        ask patch-right-and-ahead 45 1
;            [
;             if pcolor = black [set pcolor white]
;            ]
;
;                        ask patch-right-and-ahead 135 1
;            [
;             if pcolor = black [set pcolor white]
;            ]

            rt -90]]
         fd 0.5]
      die]]

  colorea-interior

set grafo-finalizado true
  ][
  user-message( "No se puede modificar el grafo una vez finalizado." )
  ]
end

;Método para colorear el interior del grafo.
to colorea-interior
  while [any? patches with [pcolor = white and any? neighbors4 with [pcolor = black]]]
  [
    ask patches with [pcolor = white and any? neighbors4 with [pcolor = black]]
    [
      ask neighbors4 with [pcolor = black] [set pcolor white]
    ]
  ]
end

;Método para conocer los recorredores del patch.
to recorredor-del-patch
 if mouse-inside? and mouse-down? != pulsado
 [

  ask patch mouse-xcor mouse-ycor[
    sprout-observadores 1 [setxy xcor ycor set color red set size 3 set shape "circle"]
    foreach recorredores-vistos [
       set contador-recorredores-vistos contador-recorredores-vistos + 1
     ask recorredor ? [
        set color blue - 1
        set shape "circle"
        set size 2

        ]
      ]
    output-show(word  " Coordenadas :"  mouse-xcor "," mouse-ycor)

  ]

 wait .2
 ]
 set pulsado mouse-down?
end

;Método para borrar los observadores.
to anula-recorredor-del-patch

    ask observadores [die]
    ask recorredores [set color orange]
    set contador-recorredores-vistos 0
    clear-output

end

;Método para dibujar los patches del foco.
to colorea-patches
  ask patches with [valor-observado > 0]  [
    set pcolor 89.9 - (valor-observado / 20)]

end

;------------------------- Modo automático -------------------------

;Método para generar el grafo el grafo.
to auto-genera-grafo
  __clear-all-and-reset-ticks
  set contador-recorredores 0
  set contador-recorredores-vistos 0
  reset-timer
   ask patches[
   set vertice-encima false
   ]
  set grafo-finalizado false

  repeat numero-vertices [
  let m-xcor random-xcor
  let m-ycor random-ycor

   ask patch m-xcor m-ycor
   [
     if vertice-encima = false
     [
       sprout-vertices 1
       [
         set shape "circle"
         set color green
         set label-color white
         set size 3
         set etiqueta who
         set etiqueta-global who
       ]
      crear-arista
      ver-etiquetas
      set vertice-encima true
    ]
   ]
  ]

  cerrar-grafo

 ;Controlamos la apertura y dispersión del grafo en la visualización.
 repeat 5 [ layout-spring vertices links 0.2 (sqrt numero-vertices) / numero-vertices 1 ]
 ask vertices [set label who]
end

;------------------------- Parámetros -------------------------

;Método para generar los observadores en el entorno.

to-report genera-posicion-aleatoria-correcta
  let lista-retorno []
  ask one-of patches with[pcolor != white and pcolor != orange]
  [
   set lista-retorno (list pxcor pycor)
  ]

  report lista-retorno
end
to crea-observadores

  selecciona-numero-observadores

  create-observadores numero-observadores
  [
    let coordenadas genera-posicion-aleatoria-correcta
    let xtemp item 0 coordenadas
    let ytemp item 1 coordenadas

    setxy xtemp ytemp
    set shape "square"
    set color red
    set label-color yellow
    set size 5
  ]




;  ask observadores
;  [ ask patches in-radius radio-maximo
;      [ set pcolor yellow
;        set valor-observado valor-observado + 1 ] ]
;
;
;  ask observadores
;  [ ask patches in-radius radio-minimo
;      [ set pcolor green
;        set valor-observado valor-observado + 1 ] ]




end

;Método para seleccionar el número de observadores.
to selecciona-numero-observadores

set numero-observadores (ceiling ((etiqueta-global + 1) / 2)) + 1
;set numero-observadores (etiqueta-global + 1)

end

;Método para activar los focos de los observadores.
to enciende-focos
    ask patches with [pcolor != orange and pcolor != white]
  [  set pcolor black
     set recorredores-vistos [] ]

  ask recorredores
  [
    let idrecorredor who
    ask patches in-cone radio-maximo 140 with [pcolor = black] [
      set valor-observado valor-observado + 1
      set recorredorVisto idrecorredor
      set recorredores-vistos lput recorredorVisto recorredores-vistos ]]

  colorea-patches

end

;Método para calcular las distancias de un nodo origen al resto.
to ver-distancias-de-n

 let distancia 0
 ask vertices
 [
  set label ""
 ]
 ask vertice vertice-origen-n
 [
  set label distancia
  set label-color pink
  set color yellow
 ]
 ask vertices with [ (count link-neighbors) = 0]
 [
  set label "Ninguna"
  set label-color red
 ]

 while [ any? vertices with [ label = ""]]
 [
 ask vertices with [ label = distancia ]
  [
   ask link-neighbors with [ label = ""]
   [
    set label ( distancia + 1)
    set label-color yellow
   ]
  ]
  set distancia distancia + 1
 ]

end

;to funcion-fitness
;
;  comprueba-parejos
;
;  let numero-fachadas-vigiladas
;  ask obervadores
;  [
;  numero-fachadas-vigiladas =
;  ]
;  let observadores-activos
;  let cantidad-observadores-parejos ;Que vea mínimo a dos observadores.
;  let cantidad-de-observadores-cumplen-angulos
;
;
;
;
;end
;
;to comprueba parejos
;
;
;
;end


;------------------------- Algoritmo genético -------------------------

; La funcion inicializa-genetico inicializa el algoritmo genetico, borrando todos los individuos y creando una poblacion aleatoria
to inicializar-genetico
  reset-ticks
  reset-timer
  ask individuos
  [
   die
  ]

  grabar-individuos-titulo

  selecciona-numero-observadores

  ; Genera la poblacion aleatoria
  create-individuos numero-individuos-poblacion
  [
    genera-individuo-aleatorio
    calcular-fitness
    hide-turtle
  ]

  ask observadores[die]

  ask recorredores
  [
    set color orange
  ]

end

; Ejecuta un paso del algoritmo genetico
to iteracion-genetica
  crea-nueva-generacion
  mata-individuos
  tick
  set clock timer
  grabar-individuos

  ask observadores[die]
  ask recorredores
  [
    set color orange
  ]


  let mejor min-one-of individuos [fitness]
  ask mejor
  [
    let observadores-activados map last filter [first ? = 1] (map list lista-activaciones lista-observadores)
    foreach observadores-activados
    [
      let posicion-x item 0 ?
      let posicion-y item 1 ?

      hatch-observadores 1
      [
       setxy posicion-x posicion-y
       set shape "square"
       set color red
       set label-color yellow
       set size 5
       show-turtle

 ;      sprout-observadores 1 [setxy xcor ycor set color red set size 3 set shape "circle"]
       foreach recorredores-vistos [
         set contador-recorredores-vistos contador-recorredores-vistos + 1
         ask recorredor ? [
           set color blue - 1
           set shape "circle"
           set size 2

         ]
       ]
      ]
    ]
]

end

; Genera un individuo aleatorio
to genera-individuo-aleatorio
  set lista-observadores n-values numero-observadores [genera-posicion-aleatoria-correcta]
  set lista-activaciones n-values numero-observadores [random 2]
end

; Calcula el fitness para un individuo
to calcular-fitness
  let observadores-activados map last filter [first ? = 1] (map list lista-activaciones lista-observadores)

  let todos-los-observadores []
  foreach observadores-activados
  [
    let posicion-x item 0 ?
    let posicion-y item 1 ?
    ask patch posicion-x posicion-y
    [
     set todos-los-observadores (sentence todos-los-observadores recorredores-vistos)
    ]
  ]

  let observadores-sin-repeticion (remove-duplicates todos-los-observadores)
  set fitness (99999 - (length observadores-sin-repeticion))
end

; Crea la siguiente generacion
to crea-nueva-generacion
  let generacion-anterior individuos with [true]
  let numero-cruces max list 2 (numero-individuos-poblacion * porcentaje-padres * 0.01 / 2)

  ; Realiza los cruces
  repeat numero-cruces
  [
    let padre-1 min-one-of (n-of 4 generacion-anterior) [fitness]
    let padre-2 min-one-of (n-of 4 generacion-anterior) [fitness]

    crea-hijos padre-1 padre-2
  ]
end

to crea-hijos [padre-1 padre-2]
  ; Selecciona un punto de corte aleatorio
  let punto-corte 1 + random (numero-observadores - 1)

  ; Crea los observadores y las activaciones de los hijos
  let hijo-1-observadores (sentence (sublist ([lista-observadores] of padre-1) 0 punto-corte) (sublist ([lista-observadores] of padre-2) punto-corte numero-observadores))
  let hijo-2-observadores (sentence (sublist ([lista-observadores] of padre-2) 0 punto-corte) (sublist ([lista-observadores] of padre-1) punto-corte numero-observadores))

  let hijo-1-activaciones (sentence (sublist ([lista-activaciones] of padre-1) 0 punto-corte) (sublist ([lista-activaciones] of padre-2) punto-corte numero-observadores))
  let hijo-2-activaciones (sentence (sublist ([lista-activaciones] of padre-2) 0 punto-corte) (sublist ([lista-activaciones] of padre-1) punto-corte numero-observadores))

  ; Mutacion
  set hijo-1-observadores (muta-observadores hijo-1-observadores)
  set hijo-2-observadores (muta-observadores hijo-2-observadores)

  set hijo-1-activaciones (muta-activaciones hijo-1-activaciones)
  set hijo-2-activaciones (muta-activaciones hijo-2-activaciones)

  ; Crear hijos
  create-individuos 1
  [
    hide-turtle
    set lista-observadores hijo-1-observadores
    set lista-activaciones hijo-1-activaciones
    calcular-fitness
  ]

  create-individuos 1
  [
    hide-turtle
    set lista-observadores hijo-2-observadores
    set lista-activaciones hijo-2-activaciones
    calcular-fitness
  ]
end


to-report muta-observadores [obs]
  let nuevas-observadores (map [ifelse-value (random-float 1 < probabilidad-mutacion-gen) [genera-posicion-aleatoria-correcta] [?]] obs)
  report nuevas-observadores
end

to-report muta-activaciones [act]
  let nuevas-activaciones (map [ifelse-value (random-float 1 < probabilidad-mutacion-gen) [1 - ?] [?]] act)
  report nuevas-activaciones
end

; Mata a los individuos con un fitness peor
to mata-individuos
  let numero-individuos (count individuos)
  let numero-muertes (numero-individuos - numero-individuos-poblacion)

  repeat numero-muertes
  [
    ask max-one-of (n-of 4 individuos) [fitness]
    [
     die
    ]
  ]
end


to muestra-mejor-individuo
  let mejor 0
end



;------------------------- Guarda logs -------------------------

to grabar-individuos-titulo

  let nombre-archivo "solucion.csv"

  if file-exists? nombre-archivo
  [
    file-delete nombre-archivo
  ]
  file-open nombre-archivo

  let titulo "FITNESS,ITERACIÓN,TIEMPO"

  foreach n-values numero-observadores [?]
  [
    set titulo (word titulo ",X" (? + 1) ",Y" (? + 1))
  ]

  file-print titulo
  file-close
end
;-------------------------------------------------------------------

to grabar-individuos
  let nombre-archivo "solucion.csv"
  file-open nombre-archivo

  let mejor min-one-of individuos [fitness]
  ask mejor
  [
    let observadores-activados map last filter [first ? = 1] (map list lista-activaciones lista-observadores)

    let texto-observadores ""

    foreach observadores-activados
    [
      set texto-observadores (word texto-observadores "," (item 0 ?) "," (item 1 ?))
    ]

    file-print (word fitness "," ticks "," clock texto-observadores)
  ]

  file-close
end
