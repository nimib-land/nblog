# https://twitter.com/NicholasStrayer/status/1554523619379892225?s=20&t=DrHLr2OFAvYPHvz7fyBmRg
import nimib
nbInit

nbKaraxCode:
  import strformat, math, sequtils, sugar, jsplot

  let
    leafinessDefault = 39
    leafinessMin = 1
    leafinessMax = 120
    idLeafinessInput = "idLeafiness"
  var leafiness = leafinessDefault

  let
    wavinessDefault = 4
    wavinessMin = 0
    wavinessMax = 10
    idWavinessInput = "idWaviness"
  var waviness = wavinessDefault

  func plant(leafiness: int, waviness: int): tuple[x, y: seq[float]] =
    let
      t = linspace(0.0, float(leafiness)*Pi*0.5, 1000)
    result.x = t.map(t => t*cos(t)^3)
    result.y = t.map(t => 9.0*t*sqrt(abs(cos(t))) + t*sin(0.2*t)*cos(float(waviness)*t))

  var
    x, y = plant(leafiness, waviness)
  # how do I plot without input being changed?
  # can I avoid calling plot when each input is changed?
  postRender:
    let p = plant(leafiness, waviness)
    plot(p.x, p.y)

  karaxHtml:
    canvas(id="canvas"):
      text "hi" # it seems I need to put something inside otherwise canvas element will not close
    tdiv: # if I do not put this then label gets centered
      label:
        text &"Leafiness ({leafinessMin}-{leafinessMax}): {leafiness}"
      input(`type`="range", min= $leafinessMin, max= $leafinessMax, value= $leafinessDefault, id=idLeafinessInput):
        proc oninput() =
          leafiness = parseInt getVNodeById(idLeafinessInput).getInputText
    tdiv:
      label:
        text &"Waviness ({wavinessMin}-{wavinessMax}): {waviness}"
      input(`type`="range", min= $wavinessMin, max= $wavinessMax, value= $wavinessDefault, id=idWavinessInput):
        proc oninput() =
          waviness = parseInt getVNodeById(idWavinessInput).getInputText
nbText:
  """
---
**work in progress**

based on example [plant_js](./plant_js.html) (which is the js version of [trignometric_plant](./trigonometric_plant.html)).

Inspired by this tweet:
"""
nbRawOutput: """<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Play with the parameters of this plot right in your browser with Shiny for Python / ShinyLive. <a href="https://t.co/o1qvAg1KzJ">https://t.co/o1qvAg1KzJ</a><a href="https://twitter.com/hashtag/Python?src=hash&amp;ref_src=twsrc%5Etfw">#Python</a> <a href="https://twitter.com/hashtag/generativeart?src=hash&amp;ref_src=twsrc%5Etfw">#generativeart</a> <a href="https://twitter.com/hashtag/shinylive?src=hash&amp;ref_src=twsrc%5Etfw">#shinylive</a> <a href="https://t.co/6giQ2QoMIe">https://t.co/6giQ2QoMIe</a> <a href="https://t.co/xbIw8vFp1y">pic.twitter.com/xbIw8vFp1y</a></p>&mdash; Nick Strayer (@NicholasStrayer) <a href="https://twitter.com/NicholasStrayer/status/1554523619379892225?ref_src=twsrc%5Etfw">August 2, 2022</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>"""
nbSave