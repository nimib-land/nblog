
import
  std / json

let rootid_452985407 = parseJson(""""karax-0"""").to(string)
import
  karax / [kbase, karax, karaxdsl, vdom, compact, jstrutils, kdom]

template karaxHtml(body_452985408: untyped) =
  proc createdom_452985388(): VNode =
    result = buildHtml(tdiv) do:
      body_452985408

  setRenderer(createdom_452985388, root = rootid_452985407.cstring)

var nchars_452985409, nsplits_452985410: int
let
  idinputchars_452985411 = "idInputChars"
  idinputsplits_452985412 = "idInputSplits"
  idbutton_452985413 = "idButton"
  idoutput_452985414 = "idOutput"
karaxHtml:
  label:
    text "Number of characters"
  input(type = "range", min = "20", max = "120", value = "80",
        id = idinputchars_452985411):
    proc oninput() =
      nchars_452985409 = parseInt getVNodeById(idinputchars_452985411).getInputText

  label:
    text "Number of splits"
  input(type = "range", min = "2", max = "12", value = "3",
        id = idinputsplits_452985412):
    proc oninput() =
      nchars_452985409 = parseInt getVNodeById(idinputsplits_452985412).getInputText

  button(id = idbutton_452985413):
    text "Split and render"
    proc onClick() =
      getVNodeById(idoutput_452985414).setInputText
          splitScreenNaive.render(nchars_452985409, nsplits_452985410)

  hr()
  p(id = idoutput_452985414)