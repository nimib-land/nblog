import nimib
import sugar, math, strutils

nbInit

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
nbCode:
  template splitWidget =
    nbKaraxCode:
      import sugar, math, strutils

      func splitFunc(nChars, nSplits: int): seq[int] =
        let nTh = nChars div nSplits
        result = collect(newSeq): # collect is nim equivalent of python list comprehension
          for x in 1 .. nSplits:  # it does not bother to be a one liner, but it can do more than <expr> <for_expr> <if_expr>
            nTh

      type SplitFunc = (int, int) -> seq[int]
      proc render(f: SplitFunc, nChars, nSplits: int; palette="xyz"): string =
        var i = 0
        for w in f(nChars, nSplits):
          for x in 1 .. w:
            result.add palette[i mod palette.len]
          inc i

      var
        nChars = 80
        nSplits = 3
        splitOutput = "output here"
      
      let
        idInputChars = "idInputChars"
        idInputSplits = "idInputSplits"
        idButton = "idButton"

      karaxHtml:
        label:
          text "Number of characters"
        input(`type`="range", min="20", max="120", value="80", id=idInputChars):
          proc oninput() =
            nChars = parseInt getVNodeById(idInputChars).getInputText
            dump nChars
        label:
          text "Number of splits"
        input(`type`="range", min="2", max="12", value="3", id=idInputSplits):
          proc oninput() =
            nSplits = parseInt getVNodeById(idInputSplits).getInputText
            dump nSplits
        button(id=idButton):
          text "Split and render"
          proc onClick() =
            dump splitOutput
            splitOutput = splitFunc.render(nChars, nSplits)
            dump splitOutput
        hr()
        span:
          text splitOutput

splitWidget

nbSave