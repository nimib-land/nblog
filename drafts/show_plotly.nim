import nimib

nbInit

nbText: """# Plotly in nimib
I want to be able to show a plot by [plotly](https://github.com/SciNim/nim-plotly)
in a nimib document. This will likely be integrated in nimib and is currently based on a 0.3 in dev version.
"""
nbCode:
  import plotly
  import chroma
nbCodeInBlock:
  const colors = @[Color(r:0.9, g:0.4, b:0.0, a: 1.0),
                  Color(r:0.9, g:0.4, b:0.2, a: 1.0),
                  Color(r:0.2, g:0.9, b:0.2, a: 1.0),
                  Color(r:0.1, g:0.7, b:0.1, a: 1.0),
                  Color(r:0.0, g:0.5, b:0.1, a: 1.0)]
  let
    d = Trace[int](mode: PlotMode.LinesMarkers, `type`: PlotType.Scatter)
    size = @[16.int]
  d.marker = Marker[int](size: size, color: colors)
  d.xs = @[1, 2, 3, 4, 5]
  d.ys = @[1, 2, 1, 9, 5]
  d.text = @["hello", "data-point", "third", "highest", "<b>bold</b>"]

  let
    layout = Layout(title: "testing", width: 1200, height: 400,
                    xaxis: Axis(title:"my x-axis"),
                    yaxis: Axis(title: "y-axis too"),
                    autosize: false)
    p = Plot[int](layout: layout, traces: @[d])
  echo p.save()
  p.show()
nbText: """
the above creates a temporary html file and opens it in the browser.

This is the source of the html file:
```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <title>testing</title>
     <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
  </head>
  <body>
    <div id="plot0"></div>
    <script>
            runRelayout = function() {
        var margin = 50; // if 0, would introduce scrolling
        Plotly.relayout('plot0', {width: window.innerWidth - margin, height: window.innerHeight - margin } );
      };
      window.onresize = runRelayout;
      Plotly.newPlot('plot0', [{"x":[1,2,3,4,5],"y":[1,2,1,9,5],"mode":"lines+markers","type":"scatter","text":["hello","data-point","third","highest","<b>bold</b>"],"marker":{"size":16,"color":["#E56600","#E56633","#33E533","#19B219","#007F19"]}}], {"title":"testing","width":1200,"height":400,"xaxis":{"title":"my x-axis","autorange":true},"yaxis":{"title":"y-axis too","autorange":true},"hovermode":"closest"}).then(runRelayout);

    </script>
    
  </body>
</html>
```

Note that the above structure can be seen as [plotly.tmpl_html.defaultTmplString](https://github.com/SciNim/nim-plotly/blob/35f634279f1f52bbadccf5d9bb9ad55a3c89ea53/src/plotly/tmpl_html.nim#L20).

(there is also a `saveImage` that I will not bother with for the moment).

The goal is now to create a `nbShow(p: plotly.Plot)` that will add the block and show it in the document.

We will need to:
  * add `plotly` library in head section (this will be a new `nbUsePlotly` template)
  * add a partial with the above structure of `div` and `script`, th only variable elements are:
    - an id for every new plot (e.g. `plot0`), a new feature in nimib 0.3 has `nb.newId` that will give us increasing integers
    - the serialized plot data and layout (lines that starts with `[{"x":[1,2,3,4,5],"y":[1,2,1,9,5],"mode": ...`),

Note that the way plotly produces the serialized plot is by calling the [`resizeScript`](https://github.com/SciNim/nim-plotly/blob/35f634279f1f52bbadccf5d9bb9ad55a3c89ea53/src/plotly/tmpl_html.nim#L12)
and the key line is:

```nim
Plotly.newPlot('plot0', $data, $layout).then(runRelayout);
```

(I did not even notice there were both data and layout in that line...)

`resizeScript` is called only once elsewhere in plotly codebase (thanks github search!) and I adapt below the relevant lines
(again ignoring the `imageInject` stuff)

```nim
proc fillHtmlTemplate(htmlTemplate,
                      data_string: string,
                      p: SomePlot,
                      filename = "",
                      autoResize = true): string =

  var
    slayout = "{}"
    title = ""
  if p.layout != nil:
    when type(p) is Plot:
      slayout = $(%p.layout)
      title = p.layout.title
    else:
      slayout = $p.layout
      title = p.layout{"title"}.getStr

  ...

  let scriptTag = if autoResize: resizeScript()
                  else: staticScript()
  let scriptFilled = scriptTag % [ "data", data_string,
                                   "layout", slayout ]
  
  ...
```

and the last element we need is how `data_string` is generated. Again I github search `fillHtmlTemplate`
and find only one usage in the same file where it is called by [`save`](https://github.com/SciNim/nim-plotly/blob/a32c97bc705a7c02e3136c8f27a65341cde677d0/src/plotly/plotly_display.nim#L171)

```nim
when type(p) is Plot:
  # convert traces to data suitable for plotly and fill Html template
  let data_string = parseTraces(p.traces)
else:
  let data_string = $p.traces
```

it is also useful to have here an excerpt of plotly's type:
```nim
type
  Plot*[T: SomeNumber] = ref object
    traces* : seq[Trace[T]]
    layout*: Layout

  PlotJson* = ref object
    traces* : JsonNode
    layout*: JsonNode

  SomePlot* = Plot | PlotJson
```

and I am guessing the imports needed to have `$` for `Trace`, `Layout` and to have `parseTraces`
are included in:

```nim
import api, plotly_types, plotly_display
```

and now I have all I need to start coding:
"""  # found potential bug in nim-markdown, when adding spaces after a final ```  the code block does not end.
nbCode:
  template usePlotly(doc: var NbDoc) =
    import plotly / [api, plotly_types, plotly_display]
    # I should create a doc.addToHead proc for this:
    doc.partials["head"] &= """<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>"""
    doc.partials["nbPlotly"] = """
<div id="{{plot_id}}"></div>
<script>
  Plotly.newPlot('{{plot_id}}', {{&plot_data}}, {{&plot_layout}});
</script>
"""
  nb.usePlotly

  template nbPlotly(plot, body: untyped) =
    ## plot must be the identifier of Plotly's plot in body
    newNbCodeBlock("nbPlotly", body):
      body

      nb.blk.context["plot_id"] = "plot-" & $nb.newid
      nb.blk.context["plot_data"] = block:
        when type(p) is Plot:
          parseTraces(p.traces)
        else:
          $p.traces

      nb.blk.context["plot_layout"] = block:
        if plot.layout != nil:
          when type(plot) is Plot:
            $(%plot.layout)
          else:
            $plot.layout
        else:
          "{}"
nbText: """Note that above I removed the call to relayout (I am fixing the width to be smaller than in original example)
and I am not currently showing the code that produces the plot below (see source code).
"""
nbPlotly(p):
  const colors = @[Color(r:0.9, g:0.4, b:0.0, a: 1.0),
                  Color(r:0.9, g:0.4, b:0.2, a: 1.0),
                  Color(r:0.2, g:0.9, b:0.2, a: 1.0),
                  Color(r:0.1, g:0.7, b:0.1, a: 1.0),
                  Color(r:0.0, g:0.5, b:0.1, a: 1.0)]
  let
    d = Trace[int](mode: PlotMode.LinesMarkers, `type`: PlotType.Scatter)
    size = @[16.int]
  d.marker = Marker[int](size: size, color: colors)
  d.xs = @[1, 2, 3, 4, 5]
  d.ys = @[1, 2, 1, 9, 5]
  d.text = @["hello", "data-point", "third", "highest", "<b>bold</b>"]

  let
    layout = Layout(title: "plotly in nimib", width: 800, height: 400,  # changed width to 800
                    xaxis: Axis(title:"my x-axis"),
                    yaxis: Axis(title: "y-axis too"),
                    autosize: true)  # changed to true but it does not seem to have a particular effect
    p = Plot[int](layout: layout, traces: @[d])
echo nb.blk.context["plot_id"]
nbSave