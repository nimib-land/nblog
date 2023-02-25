import nimib / themes
import nimib / types

proc useNblog*(doc: var NbDoc) =
  doc.useDefault
  doc.templateDirs = @["../templates"]