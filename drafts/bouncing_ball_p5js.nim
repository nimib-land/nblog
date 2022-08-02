import nimib

nbInit
setCurrentDir nb.thisDir
nbRawOutput:
  """<script src="https://cdnjs.cloudflare.com/ajax/libs/p5.js/1.4.2/p5.min.js" integrity="sha512-rCZdHNB0AePry6kAnKAVFMRfWPmUXSo+/vlGtrOUvhsxD0Punm/xWbEh+8vppPIOzKB9xnk42yCRZ5MD/jvvjQ==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>"""

nbText: """# Bouncing ball with [p5js]

Inspired by a [forum thread](https://forum.nim-lang.org/t/9341) I wanted to try
and use [nim-p5] in nimib. I ran into a small [issue](https://github.com/Foldover/nim-p5/issues/1),
which does not seem to difficult to solve.
It is anyway easier and faster to give a simple example
of wrapping and using [p5js].
I am using the [CDN version of p5js].

I am wrapping the minimal stuff that I need
to implement a [bouncing ball] example.

[nimp5]: https://github.com/Foldover/nim-p5
[p5js]: https://p5js.org
[CDN version of p5js]: https://cdnjs.com/libraries/p5.js
[bouncing ball]: https://editor.p5js.org/icm/sketches/BJKWv5Tn

Here is the wrapper:
"""
nbFile("p5.nim"): """
type PNumber = int or float

var width* {.importc.}: float
var height* {.importc.}: float

{.push importc.}

proc createCanvas*(width, height: PNumber)
proc background*(gray: PNumber)
proc ellipse*(x, y, diameter: PNumber)

{. pop .}
""" # with the untyped version it gives error! :(
nbText: "and here the bouncing ball example:"
nbCodeToJs: """
import p5, std / lenientops

let r = 25

var
  x = 320
  y = 180
  xspeed = 5
  yspeed = 2

echo x

proc setup() {. exportc .} =
  createCanvas(640, 360)

proc draw() {. exportc .} =
  background(0)
  ellipse(x, y, 2*r)
  x += xspeed
  y += yspeed
  if x > width - r or x < r:
    xspeed = -xspeed
  if y > height - r or y < r:
    yspeed = -yspeed;
"""
nbCodeToJsShowSource
nbSave