import nimib, os

nbInit
nbDoc.darkMode
setCurrentDir nbThisDir.string
nbText: """ # Mustache Specs

Autogenerate a document containing the results of [nim-mustache](https://github.com/soasme/nim-mustache)
running [mustache specs v1.2.1](https://github.com/mustache/spec/releases/tag/v1.2.1).

"""# I should use [jsony](https://github.com/treeform/jsony)
nbCode:
  import mustache
  import json
  import strformat
  import tables
  const specfiles = ["interpolation.json", "sections.json", "inverted.json", "comments.json", "delimiters.json", "partials.json"]

  var
    specs = newJObject()
    tmpl: string
    tests: JsonNode
    data: JsonNode
    context: Context
    partials: Table[string, string]

  for specfile in specfiles:
    echo "📃 " & specfile
    specs[specfile] = parseFile(specfile)
    tests = specs[specfile]["tests"]
    assert tests.kind == JArray
    for test in tests.mitems:
      assert test.kind == JObject
      tmpl = test["template"].getStr
      data = test["data"]
      partials = initTable[string, string]()
      if "partials" in test:
        for key, val in test["partials"]:
          partials[key] = val.getStr
      context = newContext(searchDirs = @[], partials=partials, values=data.toValues)
      test["output"] = % tmpl.render(context)
      if test["output"].getStr == test["expected"].getStr:
        test["ok"] = % "✅"
        echo "  ✅ ", test["name"].getStr
      else:
        test["ok"] = % "❌"
        echo "  ❌ ", test["name"].getStr

  proc specsToMarkdown(specs: JsonNode): string =
    var partials: string
    for specfile, spec in specs.pairs:
      result.add "## " & specfile & "\n\n"
      result.add spec["overview"].getStr & "\n"
      for test in spec["tests"]:
        partials = ""
        if "partials" in test:
          assert test["partials"].kind == JObject
          partials = "Partials:\n\n```\n"
          for key, val in test["partials"]:
            partials.add &"{key}: {$val}\n"
          partials.add "```\n"
        result.add fmt"""
### {test["ok"].getStr} {test["name"].getStr}

{test["desc"].getStr}

Template:

```
{test["template"].getStr}
```

Data:

```
{$(test["data"])}
```

{partials}Expected:

```
{test["expected"].getStr}
```

Output:

```
{test["output"].getStr}
```

"""

nbText: specs.specsToMarkdown

nbSave