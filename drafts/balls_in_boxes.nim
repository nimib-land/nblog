import nimib
import sugar, math, strutils

#[
todo:
  - implement the good splitFunc
  - a way to show where we add stuff that breaks symmetry
    - for letters we capitalize the letter
    - for runes we change somehow the style? underline? change background color to a grey?
  - allow use of emoji in palette (use Runes!)
  - template for the inputs
  - vnode func for the output
  - move article to another draft (first post is just the app)
]#

nbInit

nbKaraxCode:
  import sugar, math, strutils, strformat

  func splitFunc(nChars, nSplits: int): seq[int] =
    let nTh = nChars div nSplits
    result = collect(newSeq): # collect is nim equivalent of python list comprehension
      for x in 1 .. nSplits:  # it does not bother to be a one liner
        nTh

  proc render(s: seq[int]; palette: kstring="xyz"): string =
    var i = 0
    for w in s:
      for x in 1 .. w:
        result.add palette[i mod palette.len]
      inc i

  var
    nChars = 80
    nSplits = 3
    height = 10
    palette: kstring = "xyz"
    splitOutput: seq[int] = @[]

  let
    idInputChars = "idInputChars"
    idInputSplits = "idInputSplits"
    idHeight = "idHeight"
    idPalette = "idPalette"

  karaxHtml:
    label:
      text "Number of characters: " & $nChars
    input(`type`="range", min="20", max="120", value="80", id=idInputChars):
      proc oninput() =
        nChars = parseInt getVNodeById(idInputChars).getInputText
    label:
      text "Number of splits: " & $nSplits
    input(`type`="range", min="2", max="12", value="3", id=idInputSplits):
      proc oninput() =
        nSplits = parseInt getVNodeById(idInputSplits).getInputText
    label:
      text "Height: " & $height
    input(`type`="range", min="1", max="20", value="10", id=idHeight):
      proc oninput() =
        height = parseInt getVNodeById(idHeight).getInputText
    label:
      text "Palette:"
    input(id=idPalette, value="xyz"):
      proc oninput() =
        palette = getVNodeById(idPalette).getInputText

    hr()
    tdiv:
      text fmt"{splitFunc(nChars, nSplits)} -> {sum(splitFunc(nChars, nSplits))}"
    for h in 1 .. height:
      tdiv:
        text render(splitFunc(nChars, nSplits), palette=palette)
    hr()

# add image of xkcd nerd snipe
nbText: """# Splitting the terminal aka balls in boxes

[@WillMcGugan] nerd sniped me and I had to take a fast lunch break to
solve his terminal splitting problem:
"""
# embed tweet
# add nbPython with python code
nbText: """
To solve it I need to implement a function like this:
"""
nbCodeInBlock:
  func splitScreen(nChars, nSplits: int): seq[int] =
    ## Given a terminal of nChars that must be split in nSplits equal parts,
    ## return the size of the equal parts
    discard
nbText: "The function proposed by Will, translated in Nim would be"
nbCode:
  func splitScreenNaive(nChars, nSplits: int): seq[int] =
    let nTh = nChars div nSplits
    result = collect(newSeq): # collect is nim equivalent of python list comprehension
      for _ in 1 .. nSplits:  # it does not bother to be a one liner, but it can do more than <expr> <for_expr> <if_expr>
        nTh

nbText: "and I have decided to separate the rendering part of the problem"
nbCode:
  type SplitFunc = (int, int) -> seq[int]
  proc render(f: SplitFunc, nChars, nSplits: int; palette="xyz"): string =
    var i = 0
    for w in f(nChars, nSplits):
      for _ in 1 .. w:
        result.add palette[i mod palette.len]
      inc i
  
  echo splitScreenNaive.render(80, 3)
  echo sum splitScreenNaive(80, 3)
nbText: """the problem is
that `splitScreenNaive` does not sum to 80 (or `nChars`) unless `nSplits` divides `nChars`!

I did run into a variation of this problem in my work that I call **balls in boxes**,
but before telling you my solution, I want to create a interactive widget that will
allow you to experiment with the solution.

For this I am using latest nimib release (0.3) and nim's karax reactive framework.
And I am not writting any Javascript. The code is as follows.
"""

nbSave