import nimib / themes
import nimib except toJson
import mustachepkg / values
import std / strformat
import std / strutils
import jsony

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

