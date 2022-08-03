import nimib
nbInit
setCurrentDir nb.thisDir
nbText: "a work in progress library for karax widgets"

nbFile("karax_widgets.nim"):
  template inputSliderInt*(ident: untyped, labelText="", minValue=0, maxValue=10, defaultValue=5) {. dirty .} =
    let
      `ident default` = defaultValue
      `ident min` = minValue
      `ident max` = maxValue
      `id ident` = "idInput" & astToStr(ident)
      `ident label` = (if labelText.len > 0: labelText else: astToStr(ident)) & " (" & $minValue & "-" & $maxValue & ")"
    
    var ident = `ident default`

    proc `inputSlider ident`: VNode =
      let
        labelTextComplete = `ident label` & ": " & $ident
      result = buildHtml(tdiv()):
        label:
          text labelTextComplete
        input(`type`="range", min= $`ident min`, max= $`ident max`, value= $`ident default`, id=`id ident`):
          proc oninput() =
            ident = parseInt getVNodeById(`id ident`).getInputText

  template inputSliderFloat*(ident: untyped, labelText="", minValue=0.0, maxValue=1.0, defaultValue=0.5, stepValue=0.01) {. dirty .} =
    let
      `ident default` = defaultValue
      `ident min` = minValue
      `ident max` = maxValue
      `ident step` = stepValue
      `id ident` = "idInput" & astToStr(ident)
      `ident label` = (if labelText.len > 0: labelText else: astToStr(ident)) & " (" & $minValue & "-" & $maxValue & ")"
    
    var ident = `ident default`

    proc `inputSlider ident`: VNode =
      let
        labelTextComplete = `ident label` & ": " & $ident
      result = buildHtml(tdiv()):
        label:
          text labelTextComplete
        input(`type`="range", min= $`ident min`, max= $`ident max`, value= $`ident default`, step= $`ident step`, id=`id ident`):
          proc oninput() =
            ident = parseFloat getVNodeById(`id ident`).getInputText

nbText: "example of usage"
nbKaraxCode:
  from karax_widgets as kw import nil

  kw.inputSliderInt(leafiness, minValue=1, maxValue=60, defaultValue=19)
  kw.inputSliderInt(waviness)
  kw.inputSliderFloat(simplicity)

  karaxHtml:
    inputSliderLeafiness()
    inputSliderWaviness()
    inputSliderSimplicity() # not sure why but with default 0.5 it starts right
    p:
      text "leafiness*waviness + simplicity = " & $(float(leafiness*waviness) + simplicity)

nbCodeToJsShowSource # how do I show just the code in nbKaraxCode? (this shows also the karax boilerplate)
setCurrentDir nb.initDir
nbSave