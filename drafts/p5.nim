type PNumber = int or float

var width* {.importc.}: float
var height* {.importc.}: float

{.push importc.}

proc createCanvas*(width, height: PNumber)
proc background*(gray: PNumber)
proc ellipse*(x, y, diameter: PNumber)

{. pop .}
