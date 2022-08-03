import jscanvas, colors, dom, math

# adapted from numericalnim: https://github.com/SciNim/numericalnim/blob/1db5c72dd4d4e0d31b0859b934f7505a9e4b45d9/src/numericalnim/utils.nim#L435
proc linspace*(x1, x2: float, N: int): seq[float] =
  assert N >= 2, "Need at least two samples (N>=2)"
  let dx = (x2 - x1) / (N - 1).toFloat
  result.add(x1)
  for i in 1 .. N - 2:
    result.add(x1 + dx * i.toFloat)
  result.add(x2)

proc plot*(x, y: seq[float], width = 480, height = 320, margin = 10, id="canvas") =
  var canvas = document.getElementById(id).CanvasElement
  canvas.width = width
  canvas.height = height

  var ctx = canvas.getContext2d()
  ctx.strokeStyle = $colGreen

  let
    xmax = max(x)
    xmin = min(x)
    ymax = max(y)
    ymin = min(y)
    # xc stands for x of canvas
    xcmax = float(width - margin)
    xcmin = float(margin)
    ycmax = float(height - margin)
    ycmin = float(margin)  

  proc xc(x: float): float =
    (x - xmin) / (xmax - xmin) * (xcmax - xcmin) + xcmin
  
  proc yc(y: float): float =
    float(height) - ((y - ymin) / (ymax - ymin) * (ycmax - ycmin) + ycmin)
  

  ctx.moveTo(xc(x[0]), yc(y[0]))
  for i in 1 ..< x.len:
    ctx.lineTo(xc(x[i]), yc(y[i]))
  ctx.stroke()
