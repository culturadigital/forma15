; el objetivo es max-pxcor max-pycor

globals[
  constante-veloc
  num-exitos
  inyeccion-energia
]

patches-own [nivel] ;si es bloqueo se pierde mucha energía, si es neutral menos, si es motivacion muy poco
turtles-own [
  energy
  objetivo-x
  objetivo-y
  velocidad
  objetivo?
  ]

breed [autoeficaciasPercibidas autoPer]
breed [expectativasExito expEx]
breed [percepcionesExito perEx]

to setup
  clear-all
  reset-ticks
  set constante-veloc -10
  set num-exitos 0
  set inyeccion-energia 20
  setupPatches
  setupTurtles
end

to go
  if objetivo-alcanzado? [
    set num-exitos num-exitos + 1
    ask turtles[
      setxy random-pxcor random-pycor
      set energy energy + inyeccion-energia
      ]
    ]

  redefinir-objetivos
  calculo-direccion
  calculo-velocidad
  mover
  gasto-energia
  coaching
  tick
end

to gasto-energia
  ask turtles[
    set energy energy - nivel
  ]
end

;;objetivo del agente = (objetivo real + (random * distancia objetivo real/energía))
to redefinir-objetivos
  ask turtles [
    set objetivo-x round (0 + (random-float 4 * distance (patch 0 0)) / energy)
    set objetivo-y round (0 + (random-float 4 * distance (patch 0 0)) / energy)
  ]
end

to calculo-direccion
  ask turtles[
    ;let ahora heading
    face patch objetivo-x objetivo-y
    let nueva heading
    ;set heading ahora
    ;let valor nueva - ahora

    ifelse  energy < 30 OR energy > 70
    [set heading nueva - 180]
    [set heading nueva + (-9 * energy + 450)]
  ]
end

to calculo-velocidad
  ask turtles[
    set velocidad (energy / 40)
  ]
end

to mover
  ask turtles[
    fd velocidad
  ]
end

to coaching
  ask turtles[
    if energy < 30 or energy > 70[
      let calc 0
      let impacto (random 7 + 1)
      let intensidad (random 7 + 1)
      let total (impacto + intensidad)
      set calc (log (impacto / total) 2 + log (intensidad / total) 2) * constante-veloc
      ifelse energy > 70
      [set energy energy - calc]
      [set energy energy + calc]
    ]
  ]
end

to-report objetivo-alcanzado?
  ifelse any? percepcionesExito with [pxcor = 0 and pycor = 0]
  [report true]
  [report false]

  ;ask expectativasExito[
  ;  if (pxcor = 0 and pycor = 0)
  ;  [report true]
  ;]
  ;report false
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SETUP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to-report objetivo-tortuga [tortuga]
  let salida1 ([objetivo-x] of tortuga)
  let salida2 ([objetivo-y] of tortuga)
  report (word salida1 ", " salida2)
end

to-report energia [tortuga]
  report [energy] of tortuga
end

to setupTurtles

  ;set-default-shape autoeficaciasPercibidas "caterpillar2"
  ;set-default-shape expectativasExito "bee 2"
  ;set-default-shape percepcionesExito "bee"
  set-default-shape autoeficaciasPercibidas "default"
  set-default-shape expectativasExito "default"
  set-default-shape percepcionesExito "bee 2"

  create-autoeficaciasPercibidas 1 [set color brown - 2]
  create-expectativasExito 1 [set color black]
  create-percepcionesExito 1 [set color blue - 2]

  ask turtles [
    setxy random-pxcor random-pycor
    set energy initialEnergy
    set objetivo? false
  ]

end

to setupPatches
  let total  world-width * world-height

  let norange  (blockPercent * total) / 100
  let ngreen  (incentivePercent * total) / 100

  ask patches[
    set pcolor white
    set nivel neutralValue
  ]

  ; se trata del objetivo esquina derecha superior
  ;ask patch max-pxcor max-pycor [
  ;  set pcolor blue
  ;]

  ask patch 0 0 [
    set pcolor blue
  ]

  ask n-of norange patches with [pcolor = white][
    set pcolor orange
    set nivel blockValue
  ]

  ask n-of ngreen patches with [pcolor = white][
      set pcolor green
      set nivel motivValue
  ]

end
