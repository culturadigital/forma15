breed[viviendas vivienda]
breed[demandantes demandante]

globals[
 administraciondaayuda?
 presupuestoadministracion ;integer 0 Bajo, 1 Medio, 2 Alto,
]


viviendas-own[
  ocupada? ; boolean
  estado ; integer {B(0)/R(1)/M(2)}
  edad ;integer (0-4) {(0,5],(5,25],(25,50],(50, +inf)}
  precio ;precio de la vivienda {Bajo(0),Medio(1),Alto(2)}
  capacidad ; integeremanda numero de personas (1-6)
  perfilbuscado; integer 0 Parado, 1 Estudiante, 2 Ocupado,
  edadbuscada; {Joven 0, Adulto 1, Anciano 2}
  visitada? ;hace falta durante la ejecucion
  ]

demandantes-own[
  tienevivienda?
  wvivienda; en el caso de que tenga una vivienda tiene la vivienda con el who...
  presupuesto ; {Bajo(0),Medio(1),Alto(2)}
  estadoentorno ; aceptaria una vivienda con un entorno tipo REFERIDA AL ENTORNO!
  estadovivienda ; aceptaria una vivienda en el estado referido a si misma
  npersonas ; numero personas dentro de.. (puede ser familia o individual) integer (1-6)
  profesion ; integer 0 Estudiante, 1 Trabajador, 2 Parado
  ]


patches-own [
  uso  ;Tipo de patch {1 (Residencial), 2(EspacioPublico), 3(Comercio)}
  nViviendas ; numero de vivienda ->Solo para residencial
  ;ocupacion ; porcentaje de ocupacion ->Solo para residencial
  entorno ; {1 (Todo Residencial), 2 (Todo EspacioPublico), 3(Todo Comercio), 4 (De los tres tipos)} ->Solo para residencial
  estado-ePublico ; {B(0)/R(1)/M(2)} ->Solo para Espacio Publico
  activo-Comercio? ; booleano ->Solo para Comercio
]

to setup
  ca
  crea-mundo
  crea-viviendas
  crea-demandante

set administraciondaayuda? false
set presupuestoadministracion -1


  ;Importar con el codigo PARA INCLUIR IMAGEN COMO MAPA
  ;ask patches [set pcolor white]
  ;import-pcolors-rgb "Planta FORMA15.png"

  ;Asigna a todos los patches su uso
  ;ask patches with [pcolor = [204 150 4]][set uso 1] ;RESIDENCIA
  ;ask patches with [pcolor = [211 223 15]][set uso 2] ;EPUBLICO
  ;ask patches with [pcolor = [170 0 0]][set uso 3] ;COMERCIO

  reset-ticks
end

to crea-mundo
  ;Crea los patches
 ask patches
 [
  let porcentaje random 100
  ifelse porcentaje <= residencial [
    set uso 1
    set pcolor brown
    set nViviendas 1;random 50 + 1
    set entorno 0
    set estado-ePublico 0
    set activo-Comercio? false]
  [

  ifelse ((porcentaje > residencial) and porcentaje <= (comercio + residencial)) [
      set uso 3
      set pcolor blue
      set nViviendas 0

      set entorno 0
      set estado-ePublico 0
      set activo-Comercio? ifelse-value (random-float 1 < 0.5) [true][false]
      ]
  [
    set uso 2
      set pcolor green
      set nViviendas 0
      set entorno 0
      set estado-ePublico random 3
      set activo-Comercio? false

    ]
  ]
 ]


 ;Le pide a todos los que son residenciales que calcule el entorno
 ask patches with [uso = 1] [

   let arrayusos sort ([uso] of neighbors)

   ifelse first arrayusos = last arrayusos
   [
     set entorno first arrayusos
   ]
   [
     set entorno 4
   ]

 ]
end
to crea-demandante
  create-demandantes Num-Demandantes [
    set shape "person"
    set size 2
    set color yellow
    set tienevivienda? false
    set presupuesto random 3
    set estadoentorno (random 4) + 1
    set estadovivienda random 3
    set npersonas (random 6) + 1
    set profesion random 3
    move-to one-of patches with[uso = 2]
  ]
end



to crea-viviendas


    foreach sort patches with [uso = 1] [
    create-viviendas [nViviendas] of ? [
     move-to ?
     set shape "house"
     set color red
     set ocupada? false
     set estado random 3
     set edad random 5
     set precio random 3
     set capacidad (random 6) + 1
     set perfilbuscado random 3
     set edadbuscada random 3
    ]
    ]

end

to go

  demandantes-ocupar
  
  if (ticks mod 4 = 0)
  [ 
    set administraciondaayuda? (not administraciondaayuda?)
  ]
   
  if (ticks mod 2 = 0)
  [ 
    set presupuestoadministracion (presupuestoadministracion + 1) mod 3
  ]
  
  demandantes-abandono
  vivienda-edad ;el demandante podria abandonarla (dentro)

  tick
end

to demandantes-ocupar

  let conj-demandantes (demandantes with [tienevivienda? = false])
  if not (conj-demandantes = nobody) [
     ask conj-demandantes
     [
          let deman-act self
          ask viviendas with [ocupada? = false and capacidad >= [npersonas] of deman-act]
           [
              set visitada? false
           ]
          let tengodisponibles? false
          while [([tienevivienda?] of deman-act) = false and tengodisponibles? = false][
             let vivienda-factible (one-of viviendas with [(visitada? = false) and (ocupada? = false) and (capacidad >= [npersonas] of deman-act)])

             ifelse  (vivienda-factible = nobody)
             [
               set tengodisponibles? true
             ]
             [
               ask vivienda-factible[
                  let viv-act self
                  set visitada? true

                 ifelse (alquila-facilmente? deman-act viv-act)[
                    set ocupada? true
                    set color magenta
                    ask deman-act [
                       set tienevivienda? true
                       set wvivienda ([who] of viv-act)
                       set color magenta
                       move-to viv-act
                    ]

                 ]
                 [
                     ifelse (alquila-condificultades?  deman-act viv-act)[
                         set ocupada? true
                         set color magenta
                         
                         ask deman-act [
                             set tienevivienda? true
                             set wvivienda ([who] of viv-act)
                             set color magenta
                             move-to viv-act
                         ]
                     ]
                     [
                         if(alquila-conreforma?  deman-act viv-act) [
                             set ocupada? true
                             set estado estado + 1
                             set color magenta
                             ask deman-act [
                                 set wvivienda ([who] of viv-act)
                                 set tienevivienda? true
                                 set color magenta
                                 move-to viv-act
                             ]
                         ]
                     ]
                 ]

               ]
             ]
          ]

     ]
  ]


end

to-report alquila-facilmente? [deman viv]

  ifelse (([presupuesto] of deman >= [precio] of viv)  and ([estado] of viv >= [estadovivienda] of deman))[
         report true
   ]
  [
        report false
  ]
end


to-report alquila-condificultades? [deman viv]

  ifelse(([presupuesto] of deman = ([precio] of viv - 1)) and ([profesion] of deman = 2) and ([estado] of viv >= [estadovivienda] of deman))[
      report true
   ]
  [
      ifelse(([presupuesto] of deman = ([precio] of viv - 1)) and ([profesion] of deman < 2) and (administraciondaayuda? = true) and ([estado] of viv >= [estadovivienda] of deman))[
            report true
      ]
      [
            report false
      ]

  ]

end

to-report alquila-condificultades-conestadounomejor? [deman viv]

  ifelse(([presupuesto] of deman = ([precio] of viv - 1)) and ([profesion] of deman = 2) and (([estado] of viv + 1) >= [estadovivienda] of deman))[
      report true
   ]
  [
      ifelse(([presupuesto] of deman = ([precio] of viv - 1)) and ([profesion] of deman < 2) and (administraciondaayuda? = true) and (([estado] of viv + 1) >= [estadovivienda] of deman))[
            report true
      ]
      [
            report false
      ]

  ]

end


to-report alquila-conreforma? [deman viv]
       ifelse((administraciondaayuda? = true) and (presupuestoadministracion >= [profesion] of deman)  and ([estado] of viv + 1 = [estadovivienda] of deman) and ((alquila-condificultades-conestadounomejor? deman viv) = true))[
         report true
       ]
       [
        report false
       ]
end


;Código para adaptar--------------------------------------------------------
to vivienda-edad
  ;A todas la viviendas bajo el grado precio y grado estado
  if(ticks mod 5 = 0)[
     ask viviendas with[edad = 0][
       set edad edad + 1
       if (not (estado = 2))[
        set estado estado + 1 
       ]
     ]
     demandantes-abandono-por-edad
  ]
  if(ticks mod 25 = 0)[
   ask viviendas with [edad > 0 and edad < 3] [
     set edad edad + 1
       if (not (estado = 2))[
        set estado estado + 1 
       ]
   ]
    demandantes-abandono-por-edad
  ]
 
;el precio no varia
end

to-report calcula-numero-persona
  let suma 0
  ask demandantes [set suma suma + npersonas]
  report suma
end


to demandantes-abandono

   ask demandantes with [tienevivienda? = true] [
     let deman-act self
     let viv-act (vivienda wvivienda)
     
      if(([precio] of viv-act > [presupuesto] of deman-act) and ([profesion] of deman-act < 2))[
        ifelse (administraciondaayuda? = false)[
          
         ; me voy fuera
         ask viv-act [
           set ocupada? false
           set color red
         ]              
          set wvivienda -1
          set tienevivienda? false
          set color yellow
          move-to one-of patches with [uso = 2]
         
        ][
           if (not (([presupuesto] of deman-act = ([precio] of viv-act - 1)) and ([profesion] of deman-act < 2)))[
            ; se va
             ask viv-act [
               set ocupada? false
               set color red
             ]              
             set wvivienda -1
             set tienevivienda? false
             set color yellow
             move-to one-of patches with [uso = 2]
           ]
        ]
      ]
     
   ]
end

to demandantes-abandono-por-edad
  
 ask demandantes with [tienevivienda? = true][
  let deman-act self
  let viv-act vivienda wvivienda
  
  if([estado] of viv-act < [estadovivienda] of deman-act)[
    
      ;mevoy
     ask viv-act [
       show "me voy por vieja"
               set ocupada? false
               set color red
             ]              
             set wvivienda -1
             set tienevivienda? false
             set color yellow
             move-to one-of patches with [uso = 2]
      ]
  ]
   
  
  
end
