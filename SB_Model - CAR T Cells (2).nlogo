;;in friday update email, send nikita new version of code
breed [ts t]
;;creates t-cells
breed [cs c]
;;creates c-cells

globals [meeting-count]
;global variables (meeting count which represents the amount of interactions cs and ts have)
turtles-own [
interaction-count-ts
  ;;the amount of interactions t-cells have (blue cells have)
interaction-count-cs
  ;;the amount of interactions c-cells have (red cells have)
c-ns
  ;;measures the amount of neighbors that are cancer cells specifically
  ;;uses turtle set to accumulate the amount of cancer cells neighbors as the cells travel (in go function)
t-ns
  ;measures the amount of neighbors around t-cells specifically
  ;uses turtle set to accumulate the amount of neighbors as the ts cells travel (in go function)
unique-interactions-cs
  ;measures the amount of unique interactions cancer cells have
unique-interactions-ts
  ;measures the amount of unique interactions t-cells have
unique-patches-visited
;measurs the amount of unique patches visited (helps validate data and experiments run - instituted for the fact that more interactions with lower tp]
]

to setup
  clear-all
  ;has to clear the simulation before setting it up - makes sure data or runs prior does not affect it

  let total-ratio t-ratio + c-ratio
  ;makes total ratio, the addition of what t-ratio and c-ratio is set to be
  ;this will help when getting the number of t-cells seen below
  set num-ts (total-cells / total-ratio) * t-ratio
  ;num-ts basically represents the total number of t-cells there will be
  ;it divides the total-cells (slider on interface) by the total ratio and then multiplies it by the t ratio
  set num-cs (total-cells / total-ratio) * c-ratio
  ;num-cs represents the total number of c-cells there is
  ;same logic as the above num-ts
  ask n-of num-ts patches with [not any? turtles-here] [
    ;n-of num-ts represents selecting a subset of num-ts agents (number is found by the chosen t-ratio and c-ratio in the interface)/the patches you want to choose and eventually sprout cells
    ;patches with [not any? turtles-here] sets a condition that ts can not be sprouted on any patches with cells already in it
   sprout-ts 1 [
      ;sprouts t-cell on empty patch (max number sprout is set with n-of num-ts)
  set shape "circle"
  set color blue
  set size 1
      ;sets cells to be blue to differentiate from cancer cells (which is red)
    ]
    ;end of descriptions about t-cells
  ]
  ;end of ask n-of statement

  ask n-of num-cs patches with [not any? turtles-here] [
    ;same logic as num-ts
    ;condition of new agents can not be sprouted on any patches with cells already in it
   sprout-cs 1 [
      ;sprouts 1 agent/c-cell on empty patch
  set shape "circle"
  set color red
  set size 1
      ;sets cells to be red to differentiate between t-cells (which is blue)
    ]
    ;end of description for c-cells
  ]
  ;end of n-of statement

  set meeting-count 0
  ;each time setup is clicked, meeting count has to be reverted back to 0 --> makes sure data is accurate, and runs are not affected by past runs (prior to setup)
  ask turtles [
    set c-ns (cs-on neighbors)
    ;setting c-ns to be the amount of cancer cells on neighbors (used for unique interactions)
    set t-ns (ts-on neighbors)
    ;setting t-ns to be the amount of t-cells on neighbors (used for unique interactions)
    pen-down
    ;tracks the path of each turtle
    set unique-patches-visited no-patches
    ;due to unique-patches-visited, the list cant have 0 in it otherwise it will be an error, instead initialize it with no-patches so it does not start with 0 and recieve an error due to patch-set 0 patch-here being impossible to do
  ]

 reset-ticks
end


to go
  ask turtles [move-p]
  ;move-p function is defined below, represents persistent movement + use of move probability and turn probability parameters

  ask turtles [
    let other-turtles other turtles-on neighbors
    ;makes other-turtles all the other turtles on one of the residing neighbors
    set meeting-count (meeting-count + count other turtles-on neighbors)
    ;accumulates meeting count to be meeting count + the amount of turtles on neighbors
    ;measures interaction count for all cells
    set interaction-count-ts (interaction-count-ts + count ts-on neighbors)
    ;measures meeting count for just t-cells by counting the amount of t-cells on the neighbors and adding that to interaction-count-ts
    set interaction-count-cs (interaction-count-cs + count cs-on neighbors)
    ;measures meeting count for just c-cells by counting the amount of c-cells on the neighbors and adding that to interaction-count-cs
    set c-ns (turtle-set c-ns cs-on neighbors)
    ;sets c-ns to be the amount of cancer cells on neighbors
    ;different from interacton count because turtle set finds the new values (creates an agentset containing unique turtles from various inputs/individual turtles) and takes away duplicates
    set t-ns (turtle-set t-ns ts-on neighbors)
    ;different from interaction count because turtle set finds unique values/unique t-cells on neighbors rather than counting the same interaction
    set unique-interactions-cs count c-ns
    ;sets unique-interactions of cancer cells to the cancer cells on neighbors (with no duplicates)
    set unique-interactions-ts count t-ns
    ;sets unique-interactions of t-cells to the cancer cells on neighbors (with no duplicates)
    set unique-patches-visited (patch-set unique-patches-visited patch-here)
    ;sets the variable of unique-patches-visited to the patch-set (so finds unique patches in the list by removing duplicates) and accumulating it with unique-patches-viisted with the current patch to get the accumulation of unique-patches-visited

    ]
    tick
  ;creates a tick for each go run
end
;ends go function

to move
  let free-neighbors neighbors with [not any? turtles-here]
  ;free-neighbors --> sets it as neighbors with no turtles here
  if any? free-neighbors [
    ;if-else statement for if there are free-neighbors
    let target-patch one-of free-neighbors
    ;creates a target patch of one of these free neighbors
    move-to target-patch
    ;moves to the target-patch
    ]

end
;end of move function (not being used due to persistent movement)

to see-free-neighbors
  ask turtles [
    let free-neighbors patches in-radius 1 with [count turtles-here = 0]
  ask free-neighbors [set pcolor green]
  ]
;neighbors with no turtles in patches of radius 1 should be green after clicking the button

end
;end of see-free-neighbors function

to move-p
  if random 100 < mp [
    ;a random number is less than the move probability given --> if mp is 0, there can be no number less than mp, if mp is 50, there is a 50% chance that random 100 is less than mp
    ;if else statement due to if random 100 is essentially less than mp
    ifelse random 100 < tp [
      ;another if statement to check if the tp parameters are true - same logic as mp
      let free-neighbors neighbors with [not any? turtles-here]
      ;sets free-neighbors as empty neighbors (with no turtles)
      let exclude-patch patch-ahead 1
      ;excludes the patch of one patch-ahead 1 - ask Nikita why
      set free-neighbors free-neighbors who-are-not exclude-patch
      ;sets free-neighbors empty neighbors who are not the patch ahead 1
      if any? free-neighbors [
        let target-patch one-of free-neighbors
        move-to target-patch
        ;if there are free-neighbors, let target patch be one of them and move to them
      ]
      ;end of if-else statement of free-neighbors
    ]
    ;end of if-else statement of tp parameter

    [
      ifelse count turtles-on patch-ahead 1 = 0 [
      ;if the patch-ahead 1 is 0 meaning there are no turtles
      move-to patch-ahead 1
      ;have the turtle move to patch ahead 1
    ]
    ;end of if statement of count-turtles on patch-ahead 1 (if there are no turtles on patch-ahead 1)
    [
      ;if if-else statement is not true (meaning there is a turtle on patch-ahead 1)
        let target-patch (patch-set patch-right-and-ahead 45 1 patch-left-and-ahead 45 1)
        set target-patch target-patch with [count turtles-here = 0]
      ;sets the target patch to be patches right of 45 degrees, and left of 45 degrees - sets target patch to be any target patch with no turtles in it
        if count target-patch > 0 [
        ;if the count of the target patch is not 0, meaning there is an empty target patch right and 45, and left and 45, then move to one of them
           move-to one-of target-patch
        ]
      ;end of the if there are target patches
    ]
    ;end of the if there are no turtles on the patch-ahead 1
    ]
  ;end of the else statement
  ]
;end of of if else statement of if random 100<mp
;the second part of if count-turtles on patch-ahead 1 = 0 and move to it does not affect tp due to this being under the if/else statement of the mp parameter - if random 100 were to be greater than mp then none of the code would run
end

@#$#@#$#@
GRAPHICS-WINDOW
287
32
850
596
-1
-1
16.82
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
42
40
108
73
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

SLIDER
40
135
142
168
num-ts
num-ts
0
100
33.333333333333336
10
1
NIL
HORIZONTAL

SLIDER
150
136
243
169
num-cs
num-cs
0
100
166.66666666666669
10
1
NIL
HORIZONTAL

MONITOR
42
247
217
292
meeting-count
meeting-count
17
1
11

BUTTON
129
38
256
71
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

MONITOR
40
303
215
348
NIL
count patches with [count turtles-here > 1]
17
1
11

BUTTON
39
363
216
396
NIL
see-free-neighbors
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
867
28
1258
216
Average Cancer Cell Interactions per T-cell
Ticks
Meeting Count
0.0
100.0
0.0
10.0
true
false
"" ""
PENS
"pen-1" 1.0 0 -7500403 true "" "plot mean [interaction-count-cs] of ts"

MONITOR
35
423
243
468
Average C interactions per T
mean [interaction-count-cs] of ts
17
1
11

MONITOR
33
480
244
525
Average T interactions per C
mean [interaction-count-ts] of cs
17
1
11

SLIDER
40
88
244
121
total-cells
total-cells
0
500
200.0
10
1
NIL
HORIZONTAL

SLIDER
41
187
133
220
t-ratio
t-ratio
0
10
1.0
1
1
NIL
HORIZONTAL

SLIDER
150
188
244
221
c-ratio
c-ratio
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
35
545
207
578
mp
mp
0
100
65.0
5
1
NIL
HORIZONTAL

MONITOR
869
240
1030
285
Unique Interactions (cs)
mean [unique-interactions-cs] of ts
17
1
11

SLIDER
34
593
206
626
tp
tp
0
100
80.0
5
1
NIL
HORIZONTAL

MONITOR
870
352
1022
397
Unique Patches Visited
mean [count unique-patches-visited] of turtles
17
1
11

MONITOR
870
297
1028
342
Unique Interactions (ts)
mean [unique-interactions-ts] of cs
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="t-c-ratio_interactions" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>mean [interaction-count-cs] of ts</metric>
    <metric>mean [interaction-count-ts] of cs</metric>
    <enumeratedValueSet variable="total-cells">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="t-ratio">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="c-ratio">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="covary-ratio_interactions" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>mean [interaction-count-cs] of ts</metric>
    <metric>mean [interaction-count-ts] of cs</metric>
    <enumeratedValueSet variable="total-cells">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="t-ratio">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="c-ratio">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="t-ratio_interactions_50rep" repetitions="50" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>mean [interaction-count-cs] of ts</metric>
    <metric>mean [interaction-count-ts] of cs</metric>
    <enumeratedValueSet variable="total-cells">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="t-ratio">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="c-ratio">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="t-ratio_interactions_10rep" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>mean [interaction-count-cs] of ts</metric>
    <metric>mean [interaction-count-ts] of cs</metric>
    <enumeratedValueSet variable="total-cells">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="t-ratio">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="c-ratio">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="t-ratio_interactions_100rep" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>mean [interaction-count-cs] of ts</metric>
    <metric>mean [interaction-count-ts] of cs</metric>
    <enumeratedValueSet variable="total-cells">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="t-ratio">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="c-ratio">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="t-ratio_interactions_500rep (copy)" repetitions="500" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>mean [interaction-count-cs] of ts</metric>
    <metric>mean [interaction-count-ts] of cs</metric>
    <enumeratedValueSet variable="total-cells">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="t-ratio">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="c-ratio">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="mp_relationship_interactions" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2000"/>
    <metric>mean [interaction-count-cs] of ts</metric>
    <metric>mean [interaction-count-ts] of cs</metric>
    <enumeratedValueSet variable="c-ratio">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-cells">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tp">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-cs">
      <value value="166.66666666666669"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mp">
      <value value="0"/>
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
      <value value="60"/>
      <value value="70"/>
      <value value="80"/>
      <value value="90"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="t-ratio">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-ts">
      <value value="33.333333333333336"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="tp_relationship_interactions" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2000"/>
    <metric>mean [interaction-count-cs] of ts</metric>
    <metric>mean [interaction-count-ts] of cs</metric>
    <enumeratedValueSet variable="c-ratio">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-cells">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mp">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-cs">
      <value value="166.66666666666669"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tp">
      <value value="0"/>
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
      <value value="60"/>
      <value value="70"/>
      <value value="80"/>
      <value value="90"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="t-ratio">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-ts">
      <value value="33.333333333333336"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="mp+tp_relationship_interactions (copy)" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>mean [interaction-count-cs] of ts</metric>
    <metric>mean [interaction-count-ts] of cs</metric>
    <enumeratedValueSet variable="c-ratio">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-cells">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mp">
      <value value="0"/>
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
      <value value="60"/>
      <value value="70"/>
      <value value="80"/>
      <value value="90"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-cs">
      <value value="166.66666666666669"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tp">
      <value value="0"/>
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
      <value value="60"/>
      <value value="70"/>
      <value value="80"/>
      <value value="90"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="t-ratio">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-ts">
      <value value="33.333333333333336"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="unique patches visited+tp_relationship" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>mean [count c-neighbors] of cs</metric>
    <metric>mean [count t-neighbors] of ts</metric>
    <enumeratedValueSet variable="c-ratio">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-cells">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tp">
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
      <value value="60"/>
      <value value="70"/>
      <value value="80"/>
      <value value="90"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-cs">
      <value value="166.66666666666669"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mp">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="t-ratio">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-ts">
      <value value="33.333333333333336"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
0
@#$#@#$#@
