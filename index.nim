import nimib, nimib / [paths, gits], os, strutils, strformat

nbInit

var
  listOfDrafts: string
  link: string
for file in walkDirRec(nbHomeDir):
  if not file.endswith(".html") or file.name.startsWith("index") or (not file.isGitTracked):
    continue
  link = file.relPath.replace(r"\", "/") # what an ugly hack.
  # without this (on windows) I get a %5C in place of \ in the href!
  # this should be fixed in nimib!
  listOfDrafts.add &"* [{link}]({link})\n"

nbText: """# ✍️🐳👑 nblog

A blog about nim ecosystem made with nimib.

Until nimib catches up with some features needed for a blog,
this will just be a loose collection of stuff in the drafts folder.
Some of those will be finished (waiting to be published) and some will really be drafts.

For ease of navigation, here is the list of stuff there:

""" & listOfDrafts
nbSave


# when I publish stuff I should redirect stuff from drafts to the published version (since I shared a link to the drafts).
# see here: https://stackoverflow.com/questions/18955195/can-i-redirect-a-local-static-html-page-to-an-online-resource