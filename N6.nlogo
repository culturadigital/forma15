breed [policias policia]
breed[turistas turista]
breed[prostitutas prostituta]
breed[clientes cliente]
breed[comercios comercio]
breed[vecinos vecino]
breed[atractivost atractivot]

prostitutas-own [satisfaccion numclientes]
globals[
  numvisitados
]
turistas-own[
  satisfaccion
  objetivo
  busca-obj
  busca-origen
  origen
  espera
  zona
]
clientes-own[
  satisfaccion
  objetivo
  busca-obj
  busca-origen
  origen
  espera
  zona
]

comercios-own[
  convertidor
]

vecinos-own[
  contUmbral
  umbral
  ]


to setup
  clear-all
  reset-ticks
  colocarComercios
  ask comercios with [(xcor < -250) or (xcor > 250)][die]
  set numvisitados 0
  ask avenida [set  pcolor white]
  atractivo n-of (10 * atractivos-ini) avenida
  crea-prostituta n-of 15 avenida
  ask nucleo [set  pcolor 99]
  atractivo n-of 30 nucleo
  ask panecillo [set  pcolor 39]
  atractivo n-of 6 panecillo
  ask sanroque [set  pcolor 127]
  atractivo n-of 3 sanroque
  ask laronda [set  pcolor 47]
  atractivo n-of 10 laronda
  ask n-of 30 comercios [
    set hidden? false
  ]
  create-policias 8 [set shape "person police"
                     set color blue
                     set size 10]
  create-vecinos num-vecinos [set shape "person"
                     set color yellow
                     set size 10
                     set contUmbral 60
                     set umbral 0]
  crea-turista n-of (17 * turistas-ini) nucleo nucleo
  crea-turista n-of (7 * turistas-ini) panecillo panecillo
  crea-turista n-of (3 * turistas-ini) sanroque sanroque
  crea-turista n-of (10 * turistas-ini) laronda laronda

  crea-cliente n-of (8 * clientes-ini) nucleo nucleo
  crea-cliente n-of (5 * clientes-ini) panecillo panecillo
  crea-cliente n-of (13 * clientes-ini) sanroque sanroque
  crea-cliente n-of (1 * clientes-ini) laronda laronda
end

to go
  ask vecinos [pasea]
  ask turistas [if (busca-obj = true )[visitar evalua-t] if (busca-origen = true and espera = 0 )[volver]]
  ask clientes [if (busca-obj = true )[visitar evalua-c] if (busca-origen = true and espera = 0 )[volver]]
  ask policias [pasea]
  ask prostitutas [trabajar]
  ask turistas with [espera != 0][set espera espera - 1]
  ask clientes with [espera != 0][set espera espera - 1]
  ask comercios [ evalua-com]
  ;ask vecinos[evalua-vecino]
  tick
end

to colocarComercios
  ;Fila de comercios de arriba
  ask patches with [pycor = 40 and ((pxcor mod 10) = 0)][sprout-comercios 1[
    set hidden? true
    set size 10
    set shape "building store"
    set color blue
    set convertidor 0
     ]
    ]
  ;Fila de comercios de abajo
  ask patches with [pycor = -40 and ((pxcor mod 10) = 0)][sprout-comercios 1[
    set hidden? true
    set size 10
    set shape "building store"
    set color blue
    set convertidor 0
      ]
    ]

end

to trabajar
  ifelse any? clientes in-radius 4 and member? patch-here avenida [set numclientes numclientes + 1 set satisfaccion 150 + random(60) ]
  [set satisfaccion satisfaccion - (count vecinos in-radius 4) - 1]
  if satisfaccion < 0 [ask clientes [if objetivo = myself [ set busca-origen true set espera 0 set busca-obj false] ] die]
  if numclientes > 4
  [set numclientes 0
   crea-prostituta patch-here
   set xcor xcor + random(15)
   set ycor ycor + random(15)]

end

to-report busca-atractivo
  report one-of atractivost
end

to-report busca-prostituta
  report one-of prostitutas
end

to visitar
  ifelse((distancexy [xcor] of objetivo [ycor] of objetivo) < 10)
  [facexy [xcor] of objetivo [ycor] of objetivo fd 1]
  [facexy [xcor] of objetivo [ycor] of objetivo fd 5]
  if (([pxcor] of patch-here = [xcor] of objetivo) and ([pycor] of patch-here = [ycor] of objetivo))
  [set busca-obj false
    set busca-origen true
    set espera (random 40) + 20
    if breed = turistas [set numvisitados numvisitados + 1]
    ]
end

to evalua-t
   set satisfaccion satisfaccion - (count prostitutas in-radius 20) * 20
   set satisfaccion satisfaccion + (count atractivost in-radius 20) * 20
   set satisfaccion satisfaccion - (count comercios with [color = red] in-radius 20) * 20
   set satisfaccion satisfaccion + (count comercios with [color = blue] in-radius 20) * 20
   set satisfaccion satisfaccion + (count vecinos in-radius 20) * 5
   set satisfaccion satisfaccion + (count turistas in-radius 20) * 10
   if(satisfaccion < 0 )[set busca-obj false
    set busca-origen true]
end

to evalua-c
   set satisfaccion satisfaccion + (count prostitutas in-radius 20) * 20
   set satisfaccion satisfaccion - (count turistas in-radius 20) * 20 - (count vecinos in-radius 20) * 20
   if(satisfaccion < 0 )[set busca-obj false
    set busca-origen true]
end


to evalua-com
  set convertidor convertidor - ((count prostitutas in-radius 20) * 5) + ((count vecinos in-radius 20) * 5) + ((count turistas in-radius 20) * 10)
  let comveci (count comercios with [hidden? = true] in-radius 20) + 1
  if (ticks mod 150 = 0 and ticks != 0)[
         if(convertidor / comveci < -100)[
         set color red
         set hidden? false
         ]
         if(100 > convertidor / comveci and convertidor / comveci  > -100)[
         set hidden? true
         ]
         if(convertidor / comveci > 100)[

         set color blue
         set hidden? false
         ]
       set convertidor 0
    ]
end

to evalua-vecino
      if(contUmbral = 0)[
      ;if any? comercios [
        set umbral umbral + ((count comercios with [color = blue]) * 1)
        set umbral umbral - ((count comercios with [color = red]) * 2)
        set umbral umbral - ((count prostitutas) * 2)

     ; ]
      if (umbral > 10 and count vecinos < 100)[
        ask one-of avenida[
           sprout-vecinos 1 [set shape "person"
                             set color yellow
                             set size 10
                             set contUmbral 60
                             set umbral 0]
           ]
       ]

      if(umbral < 0)[ die ]

      set contUmbral 60
      ]

    set contUmbral contUmbral - 1
end
to volver
   ifelse((distancexy [pxcor] of origen [pycor] of origen) < 10)
   [facexy [pxcor] of origen [pycor] of origen fd 1]
   [facexy [pxcor] of origen [pycor] of origen fd 5]
  if (([pxcor] of patch-here = [pxcor] of origen) and ([pycor] of patch-here = [pycor] of origen))[ if satisfaccion > 0 [ if breed = turistas[ crea-turista n-of int (satisfaccion / (count turistas * 100)) zona zona] if breed = clientes [ crea-cliente n-of int (satisfaccion / (count clientes * 50)) zona zona]] die]
end

to pasea
  fd 10
  ifelse not (member? patch-here avenida) [set heading heading - 180
                                         ] [ set heading heading + random (10) - 5]
end


to-report zonacomercios
  report patches with [(pycor = 40) or (pycor = -40) and pxcor < 250 and pxcor > -250]
end


to-report avenida
  report patches with [pycor < 40 and pycor > -40 and pxcor < 250 and pxcor > -250]
end

to-report nucleo
  report patches with [pycor > 39]
end

to-report panecillo
  report patches with [pycor < -39 and pxcor < 250 and pxcor > -250]
end

to-report sanroque
 report patches with [pycor < 40 and pxcor < -249 ]
end

to-report laronda
  report patches with [pycor < 40 and pxcor > 249]
end

to atractivo [p]
  ask p [sprout-atractivost 1[set color green set shape "flag" set size 10] set pcolor green ask neighbors [set pcolor green] ]
end

to crea-prostituta [p]
  let t 0
  ask p [set t count prostitutas in-radius 20]
  if t < 5
  [
    ask p [sprout-prostitutas 1 [set shape "person" set color red set size 10 set satisfaccion 150 + random(60) set numclientes 0]]
  ]
end

to crea-turista [p z]
  ask p [sprout-turistas 1 [set shape "person"
                set color brown
                set size 10
                set satisfaccion (random 40) + 80
                set objetivo busca-atractivo
                set busca-obj true
                set busca-origen false
                set origen patch-here
                set zona z]]
end


to crea-cliente [p z]
  if count prostitutas > 0[
  ask p [sprout-clientes 1 [set shape "person"
                set color black
                set size 10
                set satisfaccion (random 40) + 80
                set objetivo busca-prostituta
                set busca-obj true
                set busca-origen false
                set origen patch-here
                set zona z]]]
end
