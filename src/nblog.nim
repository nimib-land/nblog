import nimib / themes
import nimib
import mustachepkg / values
import std / strformat

type
  Date* = object
    year*: int
    month*: int
    day*: int

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

proc pubDate*(nb: var NbDoc; year, month, day: int) =
  nb.context["pub_date"] = Date(year: year, month: month, day: day)
  let datetime = "2023-01-06"
  let date = "Jan 06, 2023"
  nbRawHtml: &"""<p><time datetime="{datetime}">{date}</time></p>"""