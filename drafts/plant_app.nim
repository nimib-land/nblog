# https://twitter.com/NicholasStrayer/status/1554523619379892225?s=20&t=DrHLr2OFAvYPHvz7fyBmRg
import nimib
nbInit
nb.useLatex
nbKaraxCode:
  import strformat, math, sequtils, sugar, jsplot
  from karax_widgets as kw import nil

  kw.inputSliderInt(leafiness, minValue=0, maxValue=60, defaultValue=19)
  kw.inputSliderInt(order, minValue=0, maxValue=50, defaultValue=20)
  kw.inputSliderInt(waviness, minValue=0, maxValue=10, defaultValue=4)
  kw.inputSliderFloat(simplicity, defaultValue=0.2)

  func plant(leafiness, waviness, order: int, simplicity: float): tuple[x, y: seq[float]] =
    let
      t = linspace(0.0, float(leafiness*2+1)*Pi*0.5, 1000)
    result.x = t.map(t => t*cos(t)^3)
    result.y = t.map(t => float(order)*t*sqrt(abs(cos(t))) + t*sin(simplicity*t)*cos(float(waviness)*t))

  var
    x, y = plant(leafiness, waviness, order, simplicity)

  postRender:
    let p = plant(leafiness, waviness, order, simplicity)
    plot(p.x, p.y)

  karaxHtml:
    canvas(id="canvas"):
      text "" # it seems I need to put something inside otherwise canvas element will not close
    inputSliderLeafiness()
    inputSliderOrder()
    inputSliderWaviness()
    inputSliderSimplicity()
nbText: """
$$ t \in [0, (2\lambda + 1)\pi / 2)] $$

$$ x = t (\cos t)^3 $$

$$ y = \omega  t \sqrt{|\cos t|} + t (\sin \sigma t) (\cos \phi t) $$

where $\lambda$ is leafiness, $\omega$ is order, $\phi$ is waviness and $\sigma$ is simplicity.
"""
nbText:
  """
---
Inspired by this tweet:
"""
nbRawOutput: """<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Play with the parameters of this plot right in your browser with Shiny for Python / ShinyLive. <a href="https://t.co/o1qvAg1KzJ">https://t.co/o1qvAg1KzJ</a><a href="https://twitter.com/hashtag/Python?src=hash&amp;ref_src=twsrc%5Etfw">#Python</a> <a href="https://twitter.com/hashtag/generativeart?src=hash&amp;ref_src=twsrc%5Etfw">#generativeart</a> <a href="https://twitter.com/hashtag/shinylive?src=hash&amp;ref_src=twsrc%5Etfw">#shinylive</a> <a href="https://t.co/6giQ2QoMIe">https://t.co/6giQ2QoMIe</a> <a href="https://t.co/xbIw8vFp1y">pic.twitter.com/xbIw8vFp1y</a></p>&mdash; Nick Strayer (@NicholasStrayer) <a href="https://twitter.com/NicholasStrayer/status/1554523619379892225?ref_src=twsrc%5Etfw">August 2, 2022</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>"""
nbText:
  """
Based on example [plant_js](./plant_js.html) (where `jsplot` module is defined).

karax_widgets is a tentative widget api [here](./karax_widgets_demo.html)

Notes:

* changed leafiness to be always odd (i.e. I use leafiness*2+1 in equation) 
"""
nbSave