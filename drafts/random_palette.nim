import nimib
nbInit
nbText: "### A random 8-color palette with [pixie](https://github.com/treeform/pixie)"
nbCode:
  import std/random, pixie

  proc randomColor : ColorRGB =
    rgb(rand(255).uint8, rand(255).uint8, rand(255).uint8)

  const
    radius = 32
    space = 16
  let image = newImage(8*(radius*2 + space), radius*2)

  var
    center = vec2(radius, radius)
    color: ColorRGB
    palette: seq[ColorRGB]
  
  for _ in 1 .. 8:
    color = randomColor()
    palette.add color
    image.fillCircle(center, radius, color)
    center += vec2(2*radius + space, 0)

  image.writeFile("palette.png")

nbImage("palette.png")

nbCode:
  for c in palette: echo $c

nbShow
# I am not able to have reproducible results!