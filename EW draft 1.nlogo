breed [orgs org]

globals [
  weatherIntensity ;intensity of weather (abstract way to express weather intenstiy, global var
  weatherExp  ; a list documenting exp with weather for each tick
  extremeWeatherFreq ; a list documenting extreme weather frequency
  serviceArea ; the agency's service area


]

orgs-own [; doc intensity of extreme weather
  budget ; total budget for maintainance and adaptation (preventive measures)
  orgWeatherExp ; document past  weather experience for every tick
  orgextremeWeatherFreq ; past extreme weather frequency, filter only the extreme one from orgWeatherExp
  damageExp; document damage from weather every tick, is 0 when there is no extreme weather
  initialBudget ; starting budget for each tick
  orgRepairBudget; = budget * repairRatio
  orgVulnerability ; average of mean vulnerablity of its service area
  whetherAdapt  ; does it adapt or not
  adaptTime ; times of adaptation
  serviceAreaDamage ; total damage on service area patches
]

patches-own [
  infraQuality  ; infra conditions on the serviceArea; updated each tick
  initialInfraQuality  ; initial conditions of the infra; for fix actions, the infraQuality restore to initialInfraQuality with some randomness
  owner ; identity which transit the patches belong to
  repairCost ; repair cost for each patch, positively related to the damage it sustained each tick
  damagePerTick ; damage for each tick
  prevention  ; number of prevention measures which help buffer impacts from EW
  infraVulnerability ; vulnerablity of patch
]


to setup
  ca
;  random-seed 47822
  set-default-shape orgs "house"
  set extremeWeatherFreq 0
  set weatherExp []
  create-orgs 1 [
    set size 4
    set color red
    set budget orgBudget ;orgBudget is slider
    set initialBudget budget ; initial budget for each tick
    set orgWeatherExp []
    set whetherAdapt false
    set adaptTime 0
    set damageExp []



      ask patches in-radius 5 [
        set owner 1
        set infraQuality random 100
        if infraQuality = 0 [set infraQuality 1] ; avoid dividing by zero
        set initialInfraQuality infraQuality
        set prevention random maxPrevention
        set damagePerTick 0  ; infra damage per each tick
        update-pcolor
    ]
  ]
  set serviceArea patches with [owner = 1] ; will be useful when we have more than one org
  ask orgs [
    update-vulnerability
    recolor
 ]
  reset-ticks
end

to go
  check-weather ; check weather every tick, a tick is a month
  if ticks > 0 and ticks mod numMonths = 0 ; renew budget every numMonth (slider) with an increment of 12;
  [
    ask orgs
    [
       renew-budget
       adapt-strategy ; I used a chooser to model the conditions under which orgs adapt
    ]
  ]

  ask serviceArea [ ; carry out every tick
    infra-decay ; infra takes natural decay
    update-pcolor ; for visual convenience
  ]

  ask orgs [ ; every tick
    update-vulnerability
    recolor
  ]

  tick
end


to adapt-strategy
  if chooseStrategy = "rememberFrequency" [ ; remember EW by frequency it happens
    adapt-by-EWfreq
  ]

  if chooseStrategy = "rememberCumDamage" [
    adapt-by-CumDamage ; adapt depending on cumulative damage over the past year
  ]

  if chooseStrategy ="rememberSevereDamage"[
    adapt-by-severeDamage ; adapt depending on
  ]


  if chooseStrategy = "riskPerception" [
    adapt-by-riskPerception
  ]


  if chooseStrategy = "doNothing" [
    not-adapt
  ]

end

to adapt-by-EWfreq
  let preWeatherExp sublist orgWeatherExp 0 min list interval length orgWeatherExp ; interval is a slider to show how many months do orgs remembers and checks stategy
  set orgextremeWeatherFreq filter [ i -> i > intensityThreshold] preWeatherExp

  if length orgextremeWeatherFreq >= adaptThreshold  ; if in the last year exp a certain number of extreme events (slider adaptThreshold), adapt
   [
    set whetherAdapt true
    set adaptTime adaptTime + 1
    adapt
    update-repairRatio ; they decide they want to change everything this year (before the adapt); or the
   ] ;
   set whetherAdapt false  ; after adaptation once, set adapt back to false
   set orgextremeWeatherFreq [] ; restart the counter very
end


to adapt-by-CumDamage

  let preWeatherDamage sublist damageExp 0 min (list interval length damageExp)
  let preCumDamage sum preWeatherDamage  ; how much damage occurred during the period (defined by the slider "interval"); cumulatively

  let initialTotalInfraQuality sum [initialInfraQuality] of serviceArea
;  print preCumDamage / initialInfraQuality
  if preCumDamage / initialInfraQuality > cumDamageRatioThreshold [
    set whetherAdapt true  ; total the total amount
    set adaptTime adaptTime + 1 ; keep track of how many times they adapted
    adapt
    update-repairRatio  ; updateRatio for next year
  ]
  set whetherAdapt false
end



to adapt-by-severeDamage ; how severe is one single extreme weather event

  let preWeatherDamage sublist damageExp 0 min (list interval length damageExp)

  let initialTotalInfraQuality sum [initialInfraQuality] of serviceArea  ; initial infra quality summed over serviceArea
  let damagedRatio map [i -> i / initialTotalInfraQuality] preWeatherDamage ; calculate aggregated damaged ratio
  print max damagedRatio

  let bigDamagedRatio any-tippingRatio damagedRatio damageRatioThreshold
  if bigDamagedRatio = true [

;  let SevereDamaged filter [ i -> i > damageRatioThreshold] DamagedRatio ; how many damage are above the threshold, filter the list
;  if length SevereDamaged > 1 [ ; change to a slider (remember just one); two or three; or maybe the other thing;
    set whetherAdapt true  ; total the total amount
    set adaptTime adaptTime + 1
    adapt
    update-repairRatio
  ]
 set whetherAdapt false

end

to-report any-tippingRatio [ls threshold]
  (foreach ls [ x ->
    if x > threshold [
      report true
  ]
    ])
  report false
end



to adapt-by-riskPerception
   let preWeatherExp sublist orgWeatherExp 0 min list interval length orgWeatherExp ; a list docs weather intensity for each tick (filtered through the timeframe we defined)
   let preWeatherDamage sublist damageExp 0 min (list interval length damageExp) ; a list docs weather damage for each tick (filtered through the timeframe we defined)
   let extremeFreqDamage [] ; docs both freq and damage in a list
   let riskPerceptionSum 0  ;

;print

  (foreach preWeatherExp preWeatherDamage [
    [a b] ->
    let freqDamage list  a b
    set freqDamage fput 1 freqDamage ; 1 is the freq responding to each filtered event;
   ; print freqDamage

    if item 1 freqDamage > intensityThreshold [ ;filter only extreme weather, item 1 is the weather intensity
      set extremeFreqDamage fput extremeFreqDamage freqDamage
;      print extremeFreqDamage
;     let riskPerception (item 0 freqDamage) * 0.2 + (item 1 freqDamage) * 0.3
      let riskPerception (item 0 freqDamage) * 0.2 + (item 2 freqDamage) * 0.3 + random-normal 0 1  ; item 0 is freq, item 2 is damage, also add some random errors
      print riskPerception
      set riskPerceptionSum riskPerceptionSum + riskPerception
      print riskPerceptionSum

       ]
    ])



  if riskPerceptionSum >  riskPerceptionThreshold [
   set whetherAdapt true  ; total the total amount
    set adaptTime adaptTime + 1
    adapt
    update-repairRatio
  ]

;  print riskPerceptionSum

end


;  ; i want to incorporate this as riskPerction = frequency *b1 + damage * b2 + random errors, then model adaptation as if riskPerception > threshond, [adapt]
;  ; this would require operating on the two lists of same length. For example I need to filter the item in list 1 (whch keeps track of prob of extreme weather)
;  with random float 1 > intensity threshold, then for each of the item selected from list 1, I will find the corresponding item in list 2 (damage) to get its damage
; that way I can have both freq (using the list of preWeatherExp and preWeatherDamage does not capture freq directly; instead I had to add 1 to the parallel list to
;  indicate each eligible list is of freq 1) and damage from the same extreme event and factor them in the function for risk perception.
;



to not-adapt ; is there better way to model "do nothing maintaining the status quo"
 set whetherAdapt false
 set repairRatio repairRatio

end


to update-pcolor
  set pcolor scale-color green infraQuality 0 100
end

to renew-budget
    set budget orgBudget  ;
    set initialBudget budget

end

to update-repairRatio ; this model applies to when orgs adapt, they also increase their adapti
  let currentInfraQuality mean [infraQuality] of serviceArea
  let originalInfraQualty mean [initialInfraQuality] of serviceArea
  if changeRepairRatio? = true and currentInfraQuality >= 0.5 * originalInfraQualty [
  set repairRatio repairRatio - 0.01
  if repairRatio < 0.5 [set repairRatio 0.5]
  ]

end

to check-weather  ; rains every step
  set weatherIntensity random-float 1 ;
  set weatherExp fput weatherIntensity weatherExp
  ask orgs [
  set orgWeatherExp fput weatherIntensity orgWeatherExp
  ]
  ifelse weatherIntensity > intensityThreshold [ ;intensityThreshold is slider between 0 and 1 to determine if the weather is extreme
    set extremeWeatherFreq extremeWeatherFreq + 1  ; global var of ew
    ask orgs [; check the current infraQuality after taking damage
    ask serviceArea [take-damage]
    calculate-repairCost ; scan infra, calculate costs and decide whether to repair or add prevention
    repair ; do repair or adapt (adding preventions）
    recolor]
  ] [
    ask orgs [ask serviceArea [set damagePerTick 0]]
  ]

  ask orgs [record-damage]


end



to take-damage
  set damagePerTick random ExtremeWeatherDamage

  ifelse damagePerTick <= prevention
    [set damagePerTick 0]
    [set damagePerTick abs (prevention - damagePerTick)]

  set prevention prevention - 1
  if prevention < 0 [set prevention 0]

  set infraQuality infraQuality - damagePerTick ; what if infraQuality goes below 0
  if infraQuality <= 0 [set infraQuality 1]  ; prevention goes down, but it prevents the hits on the infra;
  if infraQuality > 100 [set infraQuality 100]
    ; this one currently not used in other places in the model

end

to record-damage
  let seriveAreaDamage sum [damagePerTick] of serviceArea
  set damageExp fput seriveAreaDamage damageExp

end


;to record-damage-memory ; currently not use in the model
; ask orgs [
;    if length damageExp > maxMemoryLength ; maxMemoryLength is a slider
;    [set damageExp remove-item 0 damageExp]  ; forget the damage from the oldest event;
; ]
;end



to calculate-repairCost
  ask serviceArea with [infraQuality < initialInfraQuality ][
      let decline initialInfraQuality - infraQuality  ; how does the infra-qualty reduce compared to the initial state
      set repairCost decline * 1; each patch repair cost of 10 for each quality decline; 1 is the unit repair cost, put on the same scale as daptation cost per patch
    ]

end

to repair
  set orgRepairBudget repairRatio * budget
  let repairBudget orgRepairBudget ; define this for patch use
  let originalRepairBudget repairBudget

  let repairCostRank sort-on [(- repairCost)] serviceArea
  foreach repairCostRank [ x -> ask x [
        set repairBudget fix-infra repairBudget; repairCost specific to patches, repair budget specific to orgs
     ]
  ]
  let repairMoneySpent originalRepairBudget - repairBudget
  set budget budget - repairMoneySpent
end

to-report fix-infra [repairMoney]
  if repairCost < repairMoney [
    set infraQuality initialInfraQuality
    set repairMoney repairMoney - repairCost
  ]
  report repairMoney
end


to adapt ; adapt every 12 ticks, turtle procedure

  let adaptCost adaptCostPerUnit ; to add each capital investment to enhance infra resilience, the cost is 50
  let adaptBudget (1 - repairRatio) * initialBudget
  let initialAdaptBudget adaptBudget
;  let candidatePatches ( serviceArea with [prevention < maxPrevention])  ; only add prevention to serviceArea with less than maxPrevention preventions on them already
  let canAdapt true

  if any? serviceArea with [prevention < maxPrevention] [
    while [adaptBudget > 0 and canAdapt] [  ; added the condition canAdapt to exit the "while" loop when necessary

      ;;; problem is you have two different variables, candidatePatches and candidatePatchesUpdate
      let candidatePatchesUpdate ( serviceArea with [prevention < maxPrevention])
      let numAdapt count candidatePatchesUpdate
      if numAdapt = 0 [
        set canAdapt false
      ]

      ; min (list floor (adaptBudget / adaptCost) count candidatePatches)
      ask min-n-of numAdapt candidatePatchesUpdate [infraQuality][
        ifelse adaptBudget > adaptCost
        [
          set prevention prevention + 1
          set adaptBudget adaptBudget - adaptCost
        ]
        [
          set canAdapt false
        ]
      ] ; select pathes with less than maxPrevention, rank them by worst infraQuality, loop over these patches adding prevention 1 to each of them; a  patch does not get a 2nd prevention until
    ]   ; the org finishes one round of looping over the entire set of available patches.
  ]

  let moneySpent initialAdaptBudget - adaptBudget

  set budget budget - moneySpent
end


to infra-decay
  if random 100 > 99 [  ; o.01 percent decay
    set infraQuality infraQuality - 1
    set prevention prevention - 1
  ]
end



to update-vulnerability
  ask serviceArea [
    if infraQuality = 0 [set infraQuality 1]
    set infraVulnerability 1 / (infraQuality + prevention) ; vul is set like this, so that both higher infra quality and more prevention can reduce vul; and lower of both can increase vul.
  ]
  set orgVulnerability mean [infraVulnerability] of serviceArea
end

to recolor
  ; set color scale-color red orgVulnerability 0  10
  set color red
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
533
334
-1
-1
15.0
1
10
1
1
1
0
1
1
1
-10
10
-10
10
1
1
1
ticks
30.0

BUTTON
59
30
122
63
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
58
72
121
105
step
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
589
122
652
167
Num EW
extremeWeatherFreq
0
1
11

BUTTON
59
117
122
150
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
15
195
187
228
intensityThreshold
intensityThreshold
0
1
0.6
0.1
1
NIL
HORIZONTAL

PLOT
804
190
1004
340
mean infra quality
Tick
infraQuality
0.0
10.0
1.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -2674135 true "" "plot mean [infraQuality] of serviceArea\n"

MONITOR
793
20
894
65
Min infra quality
min [infraQuality] of serviceArea
2
1
11

MONITOR
795
71
900
116
Max infra quality
max [infraQuality] of serviceArea
2
1
11

MONITOR
795
121
907
166
Mean infra quality
mean [infraQuality] of serviceArea
2
1
11

MONITOR
663
456
766
501
Total repair cost
sum [repairCost] of serviceArea
2
1
11

PLOT
582
183
782
333
Mean Prevention/Damage
NIL
NIL
0.0
10.0
0.0
20.0
true
false
"" ""
PENS
"default" 1.0 0 -14439633 true "" "plot mean [prevention] of serviceArea"
"pen-1" 1.0 0 -8053223 true "" "plot mean [damagePerTick] of serviceArea"

MONITOR
1041
187
1145
232
Total Prevention
sum [prevention] of serviceArea
17
1
11

MONITOR
664
405
738
450
repairRatio
[repairRatio] of orgs
2
1
11

MONITOR
596
356
653
401
org vul
[Orgvulnerability] of orgs
2
1
11

MONITOR
662
356
778
401
org repair budgets
[orgRepairBudget] of orgs
0
1
11

SLIDER
15
235
185
268
orgBudget
orgBudget
0
5000
1500.0
500
1
NIL
HORIZONTAL

MONITOR
1020
240
1152
285
mean damage per tick
mean [damagePerTick] of serviceArea
2
1
11

MONITOR
1025
335
1147
380
min damage per tick
min [damagePerTick] of serviceArea
2
1
11

SLIDER
15
280
185
313
repairRatio
repairRatio
0
1
0.4
0.01
1
NIL
HORIZONTAL

MONITOR
1020
288
1147
333
max damage pertick
max [damagePerTick] of serviceArea
2
1
11

MONITOR
661
505
766
550
mean repair cost
mean [repairCost] of serviceArea
0
1
11

MONITOR
1039
136
1145
181
mean prevention
mean [prevention] of serviceArea
0
1
11

MONITOR
1039
40
1134
85
Min prevention
min [prevention] of serviceArea
0
1
11

SLIDER
15
320
185
353
ExtremeWeatherDamage
ExtremeWeatherDamage
0
20
7.0
1
1
NIL
HORIZONTAL

MONITOR
1039
87
1139
132
max prevention
max [prevention] of serviceArea
0
1
11

SLIDER
14
364
186
397
maxPrevention
maxPrevention
0
40
12.0
1
1
NIL
HORIZONTAL

SLIDER
12
407
184
440
adaptThreshold
adaptThreshold
0
10
2.0
1
1
NIL
HORIZONTAL

MONITOR
790
380
870
425
adapt Times
sum [adaptTime] of orgs
0
1
11

SWITCH
13
448
179
481
changeRepairRatio?
changeRepairRatio?
1
1
-1000

SLIDER
11
487
183
520
adaptCostPerUnit
adaptCostPerUnit
0
10
2.0
1
1
NIL
HORIZONTAL

SLIDER
210
345
382
378
maxMemoryLength
maxMemoryLength
0
10
2.0
1
1
NIL
HORIZONTAL

CHOOSER
400
420
587
465
chooseStrategy
chooseStrategy
"rememberFrequency" "rememberCumDamage" "rememberSevereDamage" "riskPerception" "doNothing"
2

SLIDER
210
420
391
453
damageRatioThreshold
damageRatioThreshold
0
0.5
0.06
0.01
1
NIL
HORIZONTAL

MONITOR
785
430
908
475
DamageRatio
sum [damagePerTick] of serviceArea / sum [initialInfraQuality] of serviceArea
2
1
11

SLIDER
210
455
382
488
interval
interval
0
100
22.0
11
1
NIL
HORIZONTAL

SLIDER
210
495
382
528
numMonths
numMonths
0
100
12.0
12
1
NIL
HORIZONTAL

SLIDER
210
385
412
418
cumDamageRatioThreshold
cumDamageRatioThreshold
0
10
2.0
1
1
NIL
HORIZONTAL

PLOT
915
400
1115
550
Org vulnerablity 
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot sum [orgVulnerability] of orgs"

SLIDER
400
475
577
508
riskPerceptionThreshold
riskPerceptionThreshold
0
100
92.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?
We now model one org to get the patterns right, before populating more orgs.

This model tries to simluate organization response to extreme weather events. The organization has its fixed service area (patches). Each patch has transit infrastructure, the conditions(quality) of which is set as random 100 (when 0, reset to 1).Each patch also has a certain number of prevention (reflecting its resilience). The more prevention it has, the less damage it will take during extreme weather.  The org renews its budget every numMonths a slider. A certain ratio of the budget is allocated to repair the infra each tick, when infra takes damage.

Based on one month as a tick, the organizaiton starts by checking the weather intensity. Whatever happens, the model documents the weather intensity and damage the organization suffers each tick. 

When the weather is not exrteme, the damage is zero. When the weather is extreme, the infra on the organization's service area take damage; how much damage it takes is conditioned by how much prevention (resilience) the infra has. Check take-damage module to see how this resilience is operationalized. 

If the weather intensity < intensityThreshold, the organization does nothing and damage per tick would be zero. But when it crosses the threshold, the organization will evaluate the repair costs to recover the serviceAreas (its patches) to the initial infra conditions (infraQuality). How much the organization can repair is constrained by its budget * repairRatio. The repair works as follows: the patches evaluates how much damage they suffered and update the infra quality by deducting the damage. After deducting the damage, the patches compares the already updated infra quality with its initial setting and calculate the gap. For each unit of decline in the infra quality, the org needs to pay repairCostPerUnit, multiple it with the decline in infra quality and then sum the cost across its service patches. If there are enough budget, then recover all infra back to the original status; if not, rank them by repairCost and fix the ones damaged most (also most expensive)

Every couple of years (we set the interval with the "interval" slider on the interface), the organization will look back at its experience with weather intensity and damage (both documented at each tick), and decide wheather it will adapt. The choose "choose-strategy" has five scenarios for orgs to adapt. I have detailed comments on each strategy on how it works.

When adapting, organization will add prevention to each of its service patches. It loops across them by adding 1 to each, and then adding a second one to each after all the patches have added 1 already and adding a third one after all patches have added the 2nd one. It continues the looping until it runs out of money. 

NOTE: all params are set in an absract sense to capture the pattern. They make qualitative sense (aligns with the theory), but are not done quantitatively so far to validate with the reality. Consider this as a lab experiment to research something we cannot observe.




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
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment1" repetitions="2" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks = 120</exitCondition>
    <metric>mean [infraQuality] of serviceArea</metric>
    <metric>mean [infraVulnerability] of serviceArea</metric>
    <metric>mean [currentDamage] of serviceArea</metric>
    <metric>extremeWeatherFreq</metric>
    <metric>mean [prevention] of serviceArea</metric>
    <enumeratedValueSet variable="numMonths">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adaptThreshold">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adaptCostPerUnit">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="intensityThreshold">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="damageRatioThreshold">
      <value value="0.08"/>
      <value value="0.16"/>
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="repairRatio">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="choose-strategy">
      <value value="&quot;rememberFrequency&quot;"/>
      <value value="&quot;rememberCumDamage&quot;"/>
      <value value="&quot;rememberSevereDamage&quot;"/>
      <value value="&quot;doNothing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interval">
      <value value="11"/>
      <value value="23"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maxMemoryLength">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="changeRepairRatio?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maxPrevention">
      <value value="0"/>
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
    <steppedValueSet variable="orgBudget" first="0" step="1000" last="3000"/>
    <enumeratedValueSet variable="ExtremeWeatherDamage">
      <value value="0"/>
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cumDamageRatioThreshold">
      <value value="2"/>
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment2" repetitions="2" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks = 120</exitCondition>
    <metric>mean [infraQuality] of serviceArea</metric>
    <metric>mean [infraVulnerability] of serviceArea</metric>
    <metric>mean [currentDamage] of serviceArea</metric>
    <metric>extremeWeatherFreq</metric>
    <metric>mean [prevention] of serviceArea</metric>
    <enumeratedValueSet variable="numMonths">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adaptThreshold">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adaptCostPerUnit">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="intensityThreshold">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="damageRatioThreshold">
      <value value="0.08"/>
      <value value="0.16"/>
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="repairRatio">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="choose-strategy">
      <value value="&quot;rememberFrequency&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interval">
      <value value="11"/>
      <value value="23"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maxMemoryLength">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="changeRepairRatio?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maxPrevention">
      <value value="0"/>
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
    <steppedValueSet variable="orgBudget" first="0" step="1000" last="3000"/>
    <enumeratedValueSet variable="ExtremeWeatherDamage">
      <value value="0"/>
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cumDamageRatioThreshold">
      <value value="2"/>
      <value value="5"/>
      <value value="10"/>
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
1
@#$#@#$#@
