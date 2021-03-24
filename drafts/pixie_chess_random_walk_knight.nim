# inspired by https://www.johndcook.com/blog/2012/05/08/a-knights-random-walk/
import nimib

nbInit
nbText: """## Draw a chessboard using pixie
How do I draw a chess board using [pixie](https://github.com/treeform/pixie)?

A [chessboard](https://en.wikipedia.org/wiki/Chessboard) is a square 8x8 board with black and white squares.

Starting from pixie's [square example](https://github.com/treeform/pixie#square):
"""
nbCode:
  import pixie

  const
    squareSize = 16
    white = rgba(255, 255, 255, 255)
    black = rgba(0, 0, 0, 255)
  let image = newImage(8*squareSize, 8*squareSize)
  image.fill(white)

  var
    pos = vec2(0, 0)
  let
    wh = vec2(squareSize, squareSize)

  for y in 1 .. 8:
    pos.x = 0
    for x in 1 .. 8:
      if (x + y) mod 2 == 0:
        image.fillRect(rect(pos, wh), black)
      else:
        image.fillRect(rect(pos, wh), white)
      pos += vec2(squareSize, 0)
    pos += vec2(0, squareSize)

  image.writeFile("chessboard.png")
nbImage("chessboard.png")
nbShow