import std / [os, osproc, times]
import nimib / themes
import nimib except toJson
import mustachepkg / values
import std / strformat
import std / strutils
import jsony
import json

type
  Date* = object
    year*: int
    month*: range[1..12]
    day*: range[1..31]

proc useNblog*(nb: var NbDoc) =
  nb.useDefault
  nb.templateDirs = @["../templates"]

proc title*(nb: var NbDoc, title: string) =
  nb.context["title"] = title
  nbText: "# " & title

proc subtitle*(nb: var NbDoc, subtitle: string) =
  nb.context["title"] = nb.context["title"].castStr & " - " & subtitle
  nbText: "## " & subtitle

proc castValue*(date: Date): Value =
  let newValue = new(Table[string, Value])
  result = Value(kind: vkTable, vTable: newValue)
  newValue["year"] = date.year.castValue
  newValue["month"] = date.month.castValue
  newValue["day"] = date.day.castValue

proc castDate*(value: Value): Date =
  assert value.kind == vkTable
  assert value.vTable["year"].kind == vkInt
  result.year = int(value.vTable["year"].vInt)
  assert value.vTable["month"].kind == vkInt
  result.month = int(value.vTable["month"].vInt)
  assert value.vTable["day"].kind == vkInt
  result.day = int(value.vTable["day"].vInt)

proc toMon(month: range[1..12]): string =
  ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][month - 1]

proc pubDate*(nb: var NbDoc; year, month, day: int) =
  nb.context["pub_date"] = Date(year: year, month: month, day: day)
  let datetime = &"{year}-{month}-{day}"
  let date = &"{toMon(month)} {day:02}, {year}"
  nbRawHtml: &"""<p><time datetime="{datetime}">{date}</time></p>"""

proc dumpHook*(s: var string, v: Value)

proc dumpHook*(s: var string, v: Value) =
  case v.kind:
  of vkInt: s.add $(v.vInt)
  of vkFloat32: s.add $(v.vFloat32)
  of vkFloat64: s.add $(v.vFloat64)
  of vkString: s.add jsony.toJson(v.vString)
  of vkBool: s.add jsony.toJson(v.vBool)
  of vkProc: discard
  of vkSeq: s.add jsony.toJson(v.vSeq)
  of vkTable: s.add jsony.toJson(v.vTable[])

proc dumpHook*(s: var string, context: Context) =
  s.add jsony.toJson(context.values)

proc dumpHook*(s: var string, nb: NbDoc) =
  s.add "{\n"
  s.add "  \"data\": " & jsony.toJson(nb.context) & ",\n"
  s.add "  \"blocks\": " & jsony.toJson(nb.blocks) & "\n"
  s.add "}"

template nbSaveJson* =
  nb.nbCollectAllNbJs()
  writeFile(nb.filename.replace(".html", ".json"), jsony.toJson(nb))

proc parseHook*(s: string, i: var int, v: var Context) =
  var data: JsonNode
  parseHook(s, i, data)
  v = newContext(values = data.toValues)

type
  SimplifiedNbDoc = object
    data: Context
    blocks: seq[NbBlock]

proc parseHook*(s: string, i: var int, v: var NbDoc) =
  var simpleNb: SimplifiedNbDoc
  parseHook(s, i, simpleNb)
  v.context = simpleNb.data
  v.blocks = simpleNb.blocks

proc nbJsonToHtml*(filename: string) =
  nbInit(theme=useNblog)
  let nbJson = readFile(filename)
  let nb2 = jsony.fromJson(nbJson, NbDoc)
  nb.context = nb2.context
  nb.blocks = nb2.blocks
  nb.filename = filename.replace(".json", ".html") #todo: replace with a proper changeExt
  nbSave

proc build*(post: string, createJson = false): bool =
  # todo: do not hardcode all folders (and do not assume we are in docs)
  # I should split the build command in first building json
  # later building html (after reading all json)
  # although for nblog I need it only for index
  echo "[nblog] building " & post
  let postJson = post & ".json"
  if not postJson.fileExists or createJson:
    echo "[nblog] creating " & postJson
    let postSrc = "../posts/" & post & ".nim"
    if not postSrc.fileExists:
      echo "[nblog.error] source not found: " & postSrc
      return
    let runCmd = "nim r " & postSrc
    let exitCode = execCmd runCmd
    if exitCode != 0:
      echo "[nblog.error] error while running source: " & runCmd
      return
    if not postJson.fileExists:
      echo "[nblog.error] json not created: " & postJson
  nbJsonToHtml(postJson)
  return true

proc init*(post: string): bool =
  let postSrc = "../posts/" & post & ".nim"
  if postSrc.fileExists:
    echo "[nblog.error] files already exists: " & postSrc
    return
  let today = times.now()
  postSrc.writeFile(fmt"""
import nimib
import nblog

nbInit(theme = useNblog)
nb.title "{post}"
nb.subtitle "tell me more about {post}"
nb.pubDate {today.year}, {ord(today.month)}, {today.monthday}

nbText:
  "say something"

nbCode:
  echo "code something"

nbSaveJson
""")

when isMainModule:
  import climate
  nbInit # this puts me in docs folder
  # todo: better mechanism to list all posts
  let allPosts = @[
    "city_in_a_bottle",
    "arraymancer_tutorial"
  ]

  proc helpCmd(context: climate.Context): int =
    echo """
build               build all posts
build this that     build only posts "this" and "that"
build this --json   force creation of json when building (in case it was already created)
init new_post       init a new blogpost "new_post"
"""

  proc buildCmd(context: climate.Context): int = 
    let posts = block:
      if context.cmdArguments.len == 0:
        allPosts
      else:
        context.cmdArguments
    let createJson = "createJson" in context.cmdOptions or "json" in context.cmdOptions 
    for post in posts:
      if not build(post, createJson = createJson):
        inc result
  
  proc initCmd(context: climate.Context): int =
    let posts = block:
      if context.cmdArguments.len == 0:
        echo "todo: init a nblog"
        @[]
      else:
        context.cmdArguments
    for post in posts:
      if not init(post):
        inc result


  quit parseCommands(
    {
      "build": buildCmd,
      "init": initCmd,
    },
  defaultHandler=helpCmd)