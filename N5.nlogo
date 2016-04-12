extensions [ gis table]




globals [ temperatura dir tiempo islas myTicks marruecos]
patches-own [ temp direccion isla haplos]
turtles-own [ haplotipo t-vida densidad ]

breed [particulas particula]



to setup
  ca

  gis:load-coordinate-system (word "variables_netlogo/WGS84.prj")
  set islas gis:load-dataset "variables_netlogo/islas.asc"
  set dir gis:load-dataset "variables_netlogo/dir_completo.asc"
  set temperatura gis:load-dataset "variables_netlogo/bio1.asc"
  gis:set-world-envelope (gis:envelope-union-of (gis:envelope-of temperatura)
                                                (gis:envelope-of dir))

  reset-ticks


let min-dir gis:minimum-of dir
  let max-dir gis:maximum-of dir
  ask patches
  [ set direccion gis:raster-sample dir self
    if (direccion <= 0) or (direccion >= 0)
    [ set pcolor scale-color brown direccion min-dir max-dir ] ]


let min-temp gis:minimum-of temperatura
  let max-temp gis:maximum-of temperatura
  ask patches
  [ set temp gis:raster-sample temperatura self
    if (temp <= 0) or (temp >= 0)
    [ set pcolor scale-color brown temp  min-temp max-temp ] ]

ask patches
  [ set isla gis:raster-sample islas self]

ask patches with [pcolor = black] [set temp 0]

ask patches with [temp != 0][ set haplos table:make ]
 set myTicks 0 ;se incrementa con cada tick
 set marruecos true

ask patches with [  temp > 194 AND temp < 195 AND isla = 0]
 [set pcolor green
   iniciar-tablas pxcor pycor]



 reset-ticks
; movie-start "out.mov"
;movie-grab-view ;; show the initial state
;repeat 150
;[ go
;  movie-grab-view ]
;movie-close

end

to iniciar-tablas [x y]

    ;secuencia: TATTCCTAACAGCGCCGGTC

    ask patch x y [
      table:put haplos Sequence 50
      ]
end


to go

 ;CRECIMIENTO Y CRECIMIENTO VEGETATIVO
 crecimiento

 ;EMISION DE ESPORAS
 emitir-Esporas

 ;MUEVE
 repeat 50 [mover]
 ask turtles [if t-vida > 0 [set t-vida t-vida - 1]]

 ;COLONIZAR
 colonizar

 ;ACTUALIZACION COLORES
 ask patches with [ temp != 0 and table:length haplos > 0 ] [
   let dens 0
   foreach table:keys haplos[
     set dens dens + table:get haplos ?
     ]

   ifelse dens = 0
   [set pcolor red]
   [
     let c 65
     if dens < 40 [set c 67]
     if dens > 60 [set c 63]

     set pcolor c]
   ]

 ;MATANZA
 if count turtles > 20000 [
   ask n-of (count turtles * 0.3) turtles[
     die
     ]
   ask turtles [
     if isla = 0 [die] 
   ]
 ]


 
 tick
end

to crecimiento
  ask patches with [temp != 0 and table:length haplos > 0][ ;Selecciona todos los patches que sean tierra y que tenga algún individuo

    if temp < 170 or temp > 220 [ ;Si la temperatura es menos de 170 o mayor de 220
      let lista-Haplos table:keys haplos ;Obtengo haplotipos
      
      foreach lista-Haplos [ ;Por cada haplotipo
        let dens-actual (table:get haplos ?) ; obtengo la densidad del haplotipo actual
        table:put haplos ?  round (dens-actual / 2) ; la divido entre dos

        if table:get haplos ? = 0 [ ; si la densidad del haplotipo llega a cero
          table:remove haplos ? ; elimina el haplotipo de la lista
          table:put haplos "hayMuertos" 0 ; añade un nuevo haplotipo denominado "hayMuertos" con densidad 0
          ]
        ]

    ]

    if temp >= 190 and temp <= 200 [ ;Si la temperatura está entre 190 y 200
      
      let lista-Haplos table:keys haplos ;Obtengo haplotipos
      let dens-patch -100 ; declaramos una variable que va a ser el valor -100; si al final sobrepasa el '0', el patch estará "sobrepoblado"

        foreach lista-Haplos [  ;Por cada haplotipo
        let dens-nuevo (table:get haplos ?) * 1.1 ; obtén la nueva densidad de cada haplotipo multiplicando cada densidad por 1.1, ya que está creciendo
        table:put haplos ? dens-nuevo ; actualiza la tabla de haplotipos

        set dens-patch dens-patch + dens-nuevo ; toma la variable dens-patch que habíamos creado antes (que era -100) y le suma la nueva densidad
        ]

      if dens-patch > 0 [ ; si dens-patch es mayor que cero (es que está "sobrepoblado") y dens-patch es el porcentaje total de población que sobra en todo el patch
        foreach lista-Haplos [ ;para cada haplotipo
          let sobra (table:get haplos ?) / 100 * dens-patch ; crea una variable que va a ser el número de individuos que le sobra a cada haplotipo, en proporción a su densiadad
                                                            ; OJO!!! AQUÍ PARECE QUE HAY ALGO MAL, QUITA DEMASIADOS INDIVIDUOS

          table:put haplos ? ((table:get haplos ?) - sobra) ; elimina a cada haplotipo la densidad que le sobra.
        ]
      ]

      ;crecimiento vegetativo
      crecimiento-vegetativo pxcor pycor
    ]

  ]
end

to crecimiento-vegetativo [x y]

  ask patch x y [

    let tabla-aux haplos ; creo una variable con las densidades de cada haplotipo
    let lista-aux table:keys haplos ; creo una variable con los nombres de cada haplotipo

    ask neighbors with [temp != 0][ ; selecciona los 8 vecinos con temperatura que no sea igual a 0

     let nuevos-haplos lista-aux ; crea una nueva variable con los nombres de los haplotipos del vecino del que va a recibir los haplotipos
     let haplo-vecino table:keys haplos ; crea una variable con los nombres de los haplotipos que él mismo ya tenía
     foreach haplo-vecino [ ;mira dentro de los haplotipos que él tiene
       set nuevos-haplos remove ? nuevos-haplos ; y elimina de la lista de los nuevos haplotipos que va a recibir los que ellos ya tenían
       ]

     foreach nuevos-haplos [ ; para toda la lista de los nombres de los nuevos haplotipos que van a ser donados
       let add table:get tabla-aux ? * 0.1 ; toma una densidad del 10% de la densidad que tenían esos haplotipos en el patch vecino
       table:put haplos ? add ; 
       ]

     let dens-vecino 0
     foreach haplo-vecino [
       set dens-vecino ((table:get haplos ?) + dens-vecino)
     ]

     if dens-vecino > 100 [
       let nosPasamos (dens-vecino - 100)
        foreach nuevos-haplos [
          let valor table:get haplos ?
          let sobra valor / 100 * nosPasamos

          table:put haplos ? (valor - sobra)
        ]
       ]

   ]
  ]
end



to emitir-Esporas

  ;if marruecos [
   ;  set marruecos not (0 < count patches with [isla = 1 and table:length haplos > 0 ] and 0 < count patches with [isla = 2 and table:length haplos > 0 ])
    ;]

  ask patches with [temp != 0 and table:length haplos > 0][ ;Por patch de tierra con hongos

    ;if marruecos or (not marruecos and isla != 0) [

     ;Obtengo haplotipos
     let lista-Haplos table:keys haplos

     ;Por cada haplotipo
     foreach lista-Haplos [
       if table:get haplos ? > 13 [
         let n-Haplo ""
         let i 0

         ;Creo nuevo haplotipo con posible mutacion
         repeat (length ?) [
           set n-Haplo ( word n-Haplo (mutacion (item i ?)) )
           set i (i + 1)
         ]

         ; Generar turtle (cantidad de esporas -> % ocupacion)
         sprout 1 [
           set haplotipo n-Haplo
           set densidad  ((table:get haplos ?) / 2 )
           set t-vida densidad * .5
           set size .5
           set shape "circle"
           set color yellow
         ]
       ]
     ]
    ]
 ; ]
end

to-report mutacion [ x ]
  let prob random-float 100

    if x = "T" [
      if prob < 96.84 [ report "T" ]
      if prob >= 96.84 and prob < 97.92 [ report "C" ]
      if prob >= 97.92 and prob < 99 [ report "A" ]
      if prob >= 99 [ report "G" ]
      ]

    if x = "A" [
      if prob < 96.84 [ report "A" ]
      if prob >= 96.84 and prob < 97.92 [ report "C" ]
      if prob >= 97.92 and prob < 99 [ report "T" ]
      if prob >= 99 [ report "G" ]
      ]

    if x = "C" [
      if prob < 97.2 [ report "C" ]
      if prob >= 97.2 and prob < 98.28 [ report "A" ]
      if prob >= 98.28 and prob < 99.36 [ report "T" ]
      if prob >= 99.36 [ report "G" ]
      ]

    if x = "G" [
      if prob < 97.36 [ report "G" ]
      if prob >= 97.36 and prob < 98.36 [ report "A" ]
      if prob >= 98.36 and prob < 99.36 [ report "T" ]
      if prob >= 99.36 [ report "C" ]
      ]
end


to mover

  ask turtles with [t-vida > 0] [

    ifelse wind?
      [set heading direccion + direction]
      [set heading random-float 360]

    fd 1

    ;100 DEBERIA DE SER UN INPUT
    ;if tiempo mod 100 = 0 [ set t-vida (t-vida - 1)]

  ]

end

to colonizar

  ask turtles with [ t-vida < 0 ][

    let densidad-aux densidad
    let haplotipo-aux haplotipo

   ask patch pxcor pycor [

     if temp != 0 and isla != 0[ ;es tierra y no es marruecos

        ;Obtener ocupacion actual
        let ocupacion-actual 0
        let lista-Haplos table:keys haplos
        foreach lista-Haplos [
          set ocupacion-actual ((table:get haplos ?) + ocupacion-actual)
        ]

        let nueva-ocu densidad-aux
        if (ocupacion-actual + nueva-ocu) > 100 [
          set nueva-ocu ((ocupacion-actual + nueva-ocu) - 100)
        ]

        ifelse member? haplotipo-aux lista-Haplos [
          let ocu (nueva-ocu + table:get haplos haplotipo-aux)
          table:put haplos haplotipo-aux round ocu
          ]
        [
          if table:length haplos < 10 [ table:put haplos haplotipo-aux round nueva-ocu ]
          ]
       ]

     ]

    die
  ]
end

to-report resultado [ is ]

  let result table:make

  ask patches with [isla = is] [

      foreach table:keys haplos [

        ifelse member? ? table:keys result [
           let aux table:get result ?
           table:put result ? table:get haplos ? + aux
          ]
          [
            table:put result ? table:get haplos ?
            ]

      ]
  ]

  let result-final[]

  foreach table:keys result [
    let add ?
    set add word add "_"
    set add word add table:get result ?
    set result-final lput add result-final
  ]

  report result-final
end



to-report parada

  report 0 < count patches with [isla = 7 and table:length haplos > 0 ] and 0 < count patches with [isla = 6 and table:length haplos > 0 ]

end


;muestreo de la mitad de los parches de cada isla
to-report muestreo [is]
  let sample count patches with [isla = is]
  let result table:make
  ask n-of 18 patches with [isla = is] [
    set pcolor blue
    foreach table:keys haplos [
    table:put result ? table:get haplos ?]
  ]
  
  let result-final[]
  
  foreach table:keys result [
    let add ?
    set add word add "_"
    set add word add table:get result ?
    set result-final lput add result-final
  ]

  report result-final
end
