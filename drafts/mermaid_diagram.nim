import nimib

nbInit

nbText: """# Making Diagrams using [mermaid.js] 🧜‍♀️

Github has started yesterday to support [creation of diagrams]
in Markdown using [mermaid.js] and the [HN crowd] seemed to like it.
So I asked myself, how long does it take me to support
diagrams in Nimib using Mermaid?

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

nbText: "this is an implementation that depends on a [yet unmerged PR](https://github.com/pietroppeter/nimib/pull/78)"
nbCode:
  proc useMermaid(doc: var NbDoc) =
    nb.partials["head"] &= """<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>"""
    nb.partials["footer"] = """<script>mermaid.initialize({startOnLoad:true});</script>"""
    doc.partials["nbDiagram"] = """<div class="mermaid">
{{specs}}
</div>"""

  template nbDiagram(specs: string) =
    newNbBlock("nbDiagram", nb, nb.blk, body):
      nb.blk.context["specs"] = specs

nbText: "and here is an example of usage"

nb.useMermaid
nbDiagram: """graph LR
  A --- B
  B-->C[fa:fa-ban forbidden]
  B-->D(fa:fa-spinner);
"""
nbText: "This took less than 30 minutes from conception to realization"
nbText: """## notes

* I should add html highlighting to nimib
* find a way to add more stuff to `head` independently
  (here `head_other` template is used by plausible through a mustache template and had to append to head)
* I should add a `scripts` partial at the end of `body` in default template
  to allow for adding js scripts inside body

"""
nbSave