import nimib, strformat
nbInit
nbText: """ # Creating a TOC with mustache

I am working on porting [mdbook](https://rust-lang.github.io/mdBook/)
to nim. It is called [nimiBook](https://github.com/pietroppeter/nimiBook).
This is motivated by the work being done in
[sciNim/getting-started](https://github.com/SciNim/getting-started).

An issue is how to generate the TOC.
Below I show a way to do it using mustache.
"""
nbCode:
  import mustache, json, tables
  var
    context: Context
    text: string
    partials: Table[string, string]
    data: JsonNode
nbText: """An example result:

```html
<ol class="chapter">
  <li class="chapter-item expanded ">
    <a href="./index.html" tabindex="0" class="active">
      <strong aria-hidden="true">1.</strong> Introduction
    </a>
  </li>
  <li class="chapter-item expanded ">
    <a href="./basics/index.html" tabindex="0">
      <strong aria-hidden="true">2.</strong> Basics
    </a>
  </li>
  <li>
    <ol class="section">
      <li class="chapter-item expanded ">
        <a href="./basics/plotting.html" tabindex="0">
          <strong aria-hidden="true">2.1.</strong> Plotting
        </a>
      </li>
      <li class="chapter-item expanded ">
        <a href="./basics/data_manipulation.html" tabindex="0">
          <strong aria-hidden="true">2.2.</strong> Data Manipulation
        </a>
      </li>
      <li class="chapter-item expanded ">
        <a href="./basics/models.html" tabindex="0">
          <strong aria-hidden="true">2.3.</strong> Models
        </a>
      </li>
    </ol>
  <li class="chapter-item expanded ">
    <a href="./misc/but/very/far/contributors.html" tabindex="0">Contributors</a>
  </li>
</ol>
```
"""
nbText: """The basic element is the list item which is this template:"""
nbCode:
  var listItem = """
<li class="chapter-item expanded ">
  <a href="{{path_to_root}}{{path_to_page}}" tabindex="0"{{#is_active}} class="active"{{/is_active}}>
    {{#id}}<strong aria-hidden="true">{{id}}</strong> {{/id}}{{label}}
  </a>
</li>
"""
nbText: fmt"""```html
{listItem}
```"""
nbText: "And given some data we can render `listItem` template:"
nbCode:
  var dataItem = %* {
    "path_to_root": "basics/",
    "path_to_page": "plotting.html",
    "is_active": false,
    "id": "2.1",
    "label": "Plotting"
  } 
  context = newContext(values=dataItem.toValues)
  echo listItem.render(context)
nbCode:
  context["is_active"] = true
  echo listItem.render(context)
nbCode:
  context["id"] = false
  echo listItem.render(context)
nbText: """But a list item can also contain a section:"""
nbCode:
  let section = """
<ol class="section">
  {{#items}}
    {{> list_item }}
  {{/items}}
</ol>
"""
nbText: fmt"""```html
{section}
```"""
nbText: "Let's test it with some data:"
nbCode:
  var dataSection = %* {
    "is_section": true,
    "items": [
      {
        "path_to_root": "basics/",
        "path_to_page": "plotting.html",
        "is_active": true,
        "id": "2.1",
        "label": "Plotting"
      },
      {
        "path_to_root": "basics/",
        "path_to_page": "data_manipulation.html",
        "is_active": false,
        "id": "2.2",
        "label": "Data Manipulation"
      },
      {
        "path_to_root": "basics/",
        "path_to_page": "models.html",
        "is_active": false,
        "id": "2.3",
        "label": "Models"
      }
    ]
  }
  context = newContext(partials={"list_item": listItem}.toTable, values=dataSection.toValues)
  echo section.render(context)
nbText: "And the idea is that a `list_item` is either a single item or a section:"
nbCode:
  listItem = """
{{#is_section}}
<li>
  <ol class="section">
  {{#items}}
    {{> list_item }}
  {{/items}}
  </ol>
</li>
{{/is_section}}
{{#label}}
  <li class="chapter-item expanded ">
    <a href="{{path_to_root}}{{path_to_page}}" tabindex="0"{{#is_active}} class="active"{{/is_active}}>
      {{#id}}<strong aria-hidden="true">{{id}}</strong> {{/id}}{{label}}
    </a>
  </li>
{{/label}}
"""
nbText: """Note that the partial is recursive!

We only need the final toc template:
"""
nbCode:
  let toc = """
<ol class="chapter">
{{#chapters}}
  {{> list_item}}
{{/chapters}}
</ol>
"""
nbCode:
  data = %* {"chapters": [
      {
        "is_section": false,
        "path_to_root": "./",
        "path_to_page": "introduction.html",
        "is_active": true,
        "id": "1.",
        "label": "Introduction"
      },
      {
        "is_section": false,
        "path_to_root": "./",
        "path_to_page": "basics/index.html",
        "is_active": false,
        "id": "2.",
        "label": "Basics"
      },
      {
        "is_section": true,
        "items": [
          {
            "is_section": false,
            "path_to_root": "./",
            "path_to_page": "basics/plotting.html",
            "is_active": true,
            "id": "2.1",
            "label": "Plotting"
          },
          {
            "is_section": false,
            "path_to_root": "./",
            "path_to_page": "basics/data_manipulation.html",
            "is_active": false,
            "id": "2.2",
            "label": "Data Manipulation"
          },
          {
            "is_section": false,
            "path_to_root": "./",
            "path_to_page": "basics/models.html",
            "is_active": false,
            "id": "2.3",
            "label": "Models"
          }
        ]
      },
      {
        "is_section": false,
        "path_to_root": "./",
        "path_to_page": "misc/but/very/far/contributors.html",
        "is_active": false,
        "label": "Contributors"
      }
  ]}
  context = newContext(partials={"list_item": listItem, "toc": toc}.toTable, values=data.toValues)
  echo "{{>toc}}".render(context)
nbText: """It works 🎉!  I have to be very careful. At first I did not put `is_section: false`
in the single items, and the rendering went into a loop.

How does this help in generating a toc for nimiBook?
Well, the idea is that from a user-defined file, every page is
able to create the `data` json above and put the `is_active` in the correct place.
The two partials `toc` and `list_item` are then fixed mustache templates.

The user-defined file could be a `SUMMARY.md` like
[the one found in mdbook](https://rust-lang.github.io/mdBook/format/summary.html).
"""
nbShow