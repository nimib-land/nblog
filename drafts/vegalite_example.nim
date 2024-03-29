import nimib

nbInit
nbText: """# [vegalite] plot in nimib

[vegalite] is a js plotting library that has a declarative api
and can plot interactive graphics.

> Why vega**lite**? because it is a grammar that compiles
> to vega library (where **V**e**G**a sort of stands for **V**isualization **G**rammar);
> the advantage of vegalite is it provides a simple grammar to produce fairly
> complex charts, while vega is more low level.
>
> Note that Vega itself is again [built on top of D3](https://vega.github.io/vega/about/vega-and-d3/)

Since its grammar is completely defined by some specs that are available
in [jsonschema] format, it means that we could in principle produce
bindings using Nim metaprogramming capabilities.
Indeed [altair] is the Python binding and the library is build from specs
using some manual "meta-programming" (writing python files).

It was indeed the first thing I wanted to do in Nim, a library "wrapping" vegalite
and call it **deneb**
(vega, altair and deneb are the brightest star of summer sky,
appearing in a formation known as the [summer triangle]).
Then it was too hard for my nim skills at the time and I hashed out [nimoji] in a weekend.

Today I was remind about this project by [an issue in jsonim](https://github.com/jiro4989/nimjson/issues/30#issuecomment-1288968549).
The tricky part is how to translate the rather complex [vegalite's jsonschema](https://github.com/vega/schema)
(latest version is 1.7 MB of json)
in a reasonable hierarchy of nim types and possibly provide some syntactic sugar on top of it,
along with possibility to serialize to json.

What is rather easy instead, is to show a vegalite plot in nimib starting from a json spec.
Which is what we are doing now.

Vegalite's [usage] page is all we need to implement nimib's custom blocks:

[vegalite]: https://vega.github.io/vega-lite/
[jsonschema]: https://json-schema.org
[altair]: https://altair-viz.github.io
[summer triangle]: https://en.wikipedia.org/wiki/Summer_Triangle
[usage]: https://vega.github.io/vega-lite/usage/embed.html
[nimoji]: https://github.com/pietroppeter/nimoji
"""
nbCode:
  template useVegalite(doc: var NbDoc) =
    doc.partials["head"] &= """
<script src="https://cdn.jsdelivr.net/npm/vega@5.22.1"></script>
<script src="https://cdn.jsdelivr.net/npm/vega-lite@5.6.0"></script>
<script src="https://cdn.jsdelivr.net/npm/vega-embed@6.21.0"></script>"""
    doc.partials["nbVegalite"] = """
<div id={{id}}></div>
<script>vegaEmbed('#{{id}}', {{&spec}});</script>
"""

  template nbVegalite(jsonSpec: string) =
    newNbSlimBlock("nbVegalite"):
      nb.blk.context["id"] = "vis-" & $(nb.newId)
      nb.blk.context["spec"] = jsonSpec
  
  nb.useVegalite

nbText: """
Now it is just a matter of picking an example from [examples gallery](https://vega.github.io/vega-lite/examples/#interactive-charts).

I picked a nice interactive one about [seattle weather](https://vega.github.io/vega-lite/examples/interactive_seattle_weather.html).
"""

nbCode:
  let seattleSpec = """{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "title": "Seattle Weather, 2012-2015",
  "data": {
    "url": "https://raw.githubusercontent.com/vega/vega/main/docs/data/seattle-weather.csv"
  },
  "vconcat": [
    {
      "encoding": {
        "color": {
          "condition": {
            "param": "brush",
            "title": "Weather",
            "field": "weather",
            "type": "nominal",
            "scale": {
              "domain": ["sun", "fog", "drizzle", "rain", "snow"],
              "range": ["#e7ba52", "#a7a7a7", "#aec7e8", "#1f77b4", "#9467bd"]
            }
          },
          "value": "lightgray"
        },
        "size": {
          "title": "Precipitation",
          "field": "precipitation",
          "scale": {"domain": [-1, 50]},
          "type": "quantitative"
        },
        "x": {
          "field": "date",
          "timeUnit": "monthdate",
          "title": "Date",
          "axis": {"format": "%b"}
        },
        "y": {
          "title": "Maximum Daily Temperature (C)",
          "field": "temp_max",
          "scale": {"domain": [-5, 40]},
          "type": "quantitative"
        }
      },
      "width": 600,
      "height": 300,
      "mark": "point",
      "params": [{
        "name": "brush",
        "select": {"type": "interval", "encodings": ["x"]}
      }],
      "transform": [{"filter": {"param": "click"}}]
    },
    {
      "encoding": {
        "color": {
          "condition": {
            "param": "click",
            "field": "weather",
            "scale": {
              "domain": ["sun", "fog", "drizzle", "rain", "snow"],
              "range": ["#e7ba52", "#a7a7a7", "#aec7e8", "#1f77b4", "#9467bd"]
            }
          },
          "value": "lightgray"
        },
        "x": {"aggregate": "count"},
        "y": {"title": "Weather", "field": "weather"}
      },
      "width": 600,
      "mark": "bar",
      "params": [{
        "name": "click",
        "select": {"type": "point", "encodings": ["color"]}
      }],
      "transform": [{"filter": {"param": "brush"}}]
    }
  ]
}
"""
nbText: "and now I call `nbVegalite(seattleSpec)`"
nbVegalite(seattleSpec)
nbText: """
Some notes:

* I had to change the url from the relative one used by vegalite example to an absolute one
* **interactivity**: you can select a span of time in top chart or pick a type of weather from bottom chart
* to undo a selection click on the empty part of the grid in the chart

We can add also a `JsonNode` version
"""
nbCode:
  import json

  template nbVegalite(json: JsonNode) =
    nbVegalite($json)
nbText: "And this is an example using it:"
nbCode:
  let jsonExample = %*
    {
    "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
    "description": "A bar chart with highlighting on hover and selecting on click. (Inspired by Tableau's interaction style.)",
    "data": {
      "values": [
        {"a": "A", "b": 28}, {"a": "B", "b": 55}, {"a": "C", "b": 43},
        {"a": "D", "b": 91}, {"a": "E", "b": 81}, {"a": "F", "b": 53},
        {"a": "G", "b": 19}, {"a": "H", "b": 87}, {"a": "I", "b": 52}
        ]
      },
    "params": [
        {
          "name": "highlight",
          "select": {"type": "point", "on": "mouseover"}
        },
        {"name": "select", "select": "point"}
      ],
    "mark": {
      "type": "bar",
      "fill": "#4C78A8",
      "stroke": "black",
      "cursor": "pointer"
    },
    "encoding": {
      "x": {"field": "a", "type": "ordinal"},
      "y": {"field": "b", "type": "quantitative"},
      "fillOpacity": {
        "condition": {"param": "select", "value": 1},
        "value": 0.3
      },
      "strokeWidth": {
        "condition": [
          {
            "param": "select",
            "empty": false,
            "value": 2
          },
          {
            "param": "highlight",
            "empty": false,
            "value": 1
          }
        ],
        "value": 0
      }
    },
    "config": {
      "scale": {
        "bandPaddingInner": 0.2
      }
    }
  }
nbVegalite(jsonExample)
nbText: "Did you know that ggplotnim has an (experimental) [vegalite backend](https://github.com/Vindaar/ggplotnim#experimental-vega-lite-backend)? Let's use that know!"
nbCode:
  import ggplotnim
  import ggplotnim / ggplot_vega
  import options

  let mpg = toDf(readCsv("https://raw.githubusercontent.com/Vindaar/ggplotnim/master/data/mpg.csv"))
  let plot = ggplot(mpg, aes(x = "displ", y = "cty", color = "class")) +
    geom_point() +
    ggtitle("ggplotnim in Vega-Lite!")

  proc toVegalite(plot: GgPlot): JsonNode =
     let d = VegaDraw(fname: "", width: some(640.0), height: some(480.0), asPrettyJson: false)
     result = ggvegaCreate(plot, d) 

  let plotJson = plot.toVegalite

nbVegalite(plotJson)
nbText: """
Notes:
  - some variation of `toVegalite` could be added to `ggplotnim`
  - the `fname` field of `VegaDraw` is not used in our context
  - `ggVegaCreate` does not work if `width` or `height` are set to `none(float)` (although specifying no wdith or height is valid in vegalite)
  - (windows specific) had to remember to use `-d:nolapack`, see [ggplotnim/issues/133](https://github.com/Vindaar/ggplotnim/issues/133#issuecomment-1044284796)
  - (windows specific?) had also to add `-d:ssl` (could ggplotnim use `treeform/puppy` to fecth from url?)
"""
nbSave