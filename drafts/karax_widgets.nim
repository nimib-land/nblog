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