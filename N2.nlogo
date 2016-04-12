globals [
 resul 
 medx
 medy
]

to persecucion-cubo
    ca
  crt 1 [
    setxyz (min-pxcor / 2) (min-pycor / 2) (min-pzcor / 2)
    set label 0
    ]
  crt 1 [
    setxyz (max-pxcor / 2) (min-pycor / 2) (min-pzcor / 2)
    set label 1
    ]
  crt 1 [
    setxyz (max-pxcor / 2) (min-pycor / 2) (max-pzcor / 2)
    set label 2
    ]
  crt 1 [
    setxyz (max-pxcor / 2) (max-pycor / 2) (max-pzcor / 2)
    set label 3
    ]
  crt 1 [
    setxyz (max-pxcor / 2) (max-pycor / 2) (min-pzcor / 2)
    set label 4
    ]
  crt 1 [
    setxyz (min-pxcor / 2) (max-pycor / 2) (min-pzcor / 2)
    set label 5
    ]
  crt 1 [
    setxyz (min-pxcor / 2) (max-pycor / 2) (max-pzcor / 2)
    set label 6
    ]
  crt 1 [
    setxyz (min-pxcor / 2) (min-pycor / 2) (max-pzcor / 2)
    set label 7
    ]
  dibuja
end

to dibuja
    ask turtle 0[
    create-link-to turtle 1
    create-link-to turtle 5
    create-link-to turtle 7
    ask links [ 
      set color 105
      stamp 
    ]
  ]
  ask turtle 2[
    create-link-to turtle 1
    create-link-to turtle 3
    create-link-to turtle 7
    ask links [ 
      set color 105
      stamp 
    ]
  ]
  ask turtle 4[
    create-link-to turtle 1
    create-link-to turtle 3
    create-link-to turtle 5
    ask links [ 
      set color 105
      stamp 
    ]
  ]
    ask turtle 6[
    create-link-to turtle 3
    create-link-to turtle 5
    create-link-to turtle 7
    ask links [ 
      set color 105
      stamp 
    ]
  ]
  reset-ticks
end

to estampa
  let var 0
  let var-parada 0
  ask links [ 
    stamp 
    set color 105
   ]
      ask turtle 0 [ set var-parada distance max-one-of turtles [distance myself] ]
    if(var-parada < 0.1)[
      set medx (precision median [xcor] of turtles 3)
      set medy (precision median [ycor] of turtles 3)
      stop
    ]
  tick
end

to direcciona-personalizado
  let var 0
  let var-parada 0
  let para 0
  ask turtle 0 [
    face turtle cero-persigue-a
    pd
    fd .01
    set label ""
  ]
  ask turtle 1 [
    face turtle uno-persigue-a
    pd
    fd .01
    set label ""
  ]
  ask turtle 2 [
    face turtle dos-persigue-a
    pd
    fd .01
    set label ""
  ]
  ask turtle 3 [
    face turtle tres-persigue-a
    pd
    fd .01
    set label ""
  ]
  ask turtle 4 [
    face turtle cuatro-persigue-a
    pd
    fd .01
    set label ""
  ]
  ask turtle 5 [
    face turtle cinco-persigue-a
    pd
    fd .01
    set label ""
  ]
  ask turtle 6 [
    face turtle seis-persigue-a
    pd
    fd .01
    set label ""
  ]
  ask turtle 7 [
    face turtle siete-persigue-a
    pd
    fd .01
    set label ""
  ]
    ask turtle 0 [ set var-parada distance max-one-of turtles [distance myself] ]
    if(var-parada < 0.1)[
      set medx (precision median [xcor] of turtles 3)
      set medy (precision median [ycor] of turtles 3)
      set para 1
    ]
    if(para = 1)[
      ask turtles [
        set hidden? true
      ]
    stop
  ]
  tick
end

to direcciona
  let contador (count turtles)
  let var 0
  let var-parada 0
  let para 0
  ask turtles[
    let aux who
    face one-of turtles with [ who = ((aux + 1)  mod contador) ]
    pd
    fd .01
    set label ""
  ]
  ask turtle 0 [ set var-parada distance max-one-of turtles [distance myself] ]
  if(var-parada < 0.1)[
    set medx (precision median [xcor] of turtles 3)
    set medy (precision median [ycor] of turtles 3)
    set para 1
  ]
  if(para = 1)[
    ask turtles [
      set hidden? true
    ]
    stop
  ]
  tick
end

to-report altura
  
  let res 0
  ask patch-here [
   ;if pcolor <  1.1 [
     set res (pcolor * .1)
   ;] 
  ]
  report res
end


to crea-cazador-presa
  ca
  resize-world -13 13 -13 13 -13 13
  set-patch-size 17
  crt 1 [
   setxy 5.729577951 0 
   set heading 0
  ]
  crt 1 [
   setxyz random-xcor random-ycor random-zcor
  ]
  reset-ticks
end

to gira
  ask turtle 0 [
   ;pd
   fd .1
   lt 1 
   if( zdireccion = -1 ) [
     set zcor (zcor - 0.001)
   ]
   if( zdireccion = 1 )[
     set zcor (zcor + 0.001)
   ]
   
  ]
  ask turtle 1 [
   face turtle 0  
   pd
   fd w
 
  
  ]
  set resul calcula-radio
  tick
end

to-report calcula-radio
  let distancia 0
  ask turtle 1[
    if(ticks > 10000)[
      set distancia abs(sqrt( (xcor * xcor) + (ycor * ycor)))
    ]
  ]
  report distancia
end
