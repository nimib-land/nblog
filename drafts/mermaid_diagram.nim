import nimib

nbInit

nbText: """# Making Diagrams using [mermaid.js] 🧜‍♀️

Github has started yesterday (Feb 13th 2022) to support [creation of diagrams]
in Markdown using [mermaid.js] and the [HN crowd] seemed to like it.
So I asked myself, _how long does it take me to support
diagrams in Nimib using Mermaid_?

According to mermaid's [documentation] it is three easy steps:

  1. Inclusion of the mermaid address in the html page using
  a `script` tag, in the `src` section. Example:
  
  ```html
  <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
  ```

  2. The `mermaidAPI` call, in a separate `script` tag. Example:

  ```html
  <script>mermaid.initialize({startOnLoad:true});</script>
  ```

  3. A graph definition, inside `<div>` tags labeled `class=mermaid`. Example:
  
  ```html
  <div class="mermaid">
     graph LR
      A --- B
      B-->C[fa:fa-ban forbidden]
      B-->D(fa:fa-spinner);
  </div>
  ```

[mermaid.js]: https://github.com/mermaid-js/mermaid#readme
[creation of diagrams]: https://github.blog/2022-02-14-include-diagrams-markdown-files-mermaid/
[HN crowd]: https://news.ycombinator.com/item?id=30334338
[documentation]: https://mermaid-js.github.io/mermaid/#/usage?id=using-mermaid
"""
nbText: """## A nimib API for mermaid.js

This is the API I am targeting
"""
nbCodeInBlock:
  proc useMermaid(doc: var NbDoc) =
    discard

  template nbDiagram(spec: string) =
    discard

  nb.useMermaid
  nbDiagram: """graph LR
      A --- B
      B-->C[fa:fa-ban forbidden]
      B-->D(fa:fa-spinner);
"""

nbText: "an this is an implementation:"
nbCode:
  proc useMermaid(doc: var NbDoc) =
    nb.partials["head"] &= """<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
<link rel="stylesheet" href="https://cdn.bootcss.com/font-awesome/4.7.0/css/font-awesome.css">"""
    nb.partials["main"] &= """<script>mermaid.initialize({startOnLoad:true});</script>"""
    doc.partials["nbDiagram"] = """<div class="mermaid">
{{specs}}
</div>"""

  template nbDiagram(specs: string) =
    newNbSlimBlock("nbDiagram"):
      nb.blk.context["specs"] = specs

nbText: "and here is an example of usage"

nb.useMermaid
nbDiagram: """graph LR
  A --- B
  B-->C[fa:fa-ban forbidden]
  B-->D(fa:fa-spinner);
"""
nbText: "_This took less than 30 minutes from conception to realization!_"
nbText: """## notes

* I should add html highlighting to nimib
* to use font awesome you need to add them (not mentioned in documentation as reported above, see [this issue](https://github.com/mermaid-js/mermaid/issues/830))
* **(2022-10-7 updated to work with 0.3)**
"""
nbSave