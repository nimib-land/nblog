template inputSliderInt*(ident: untyped, label="", minValue=0, maxValue=10, defaultValue=5) {. dirty .} =
  let
    `ident Default` = defaultValue
    `ident min` = minValue
    `ident max` = maxValue
    `id ident input` = "id"

  var ident = `ident Default`