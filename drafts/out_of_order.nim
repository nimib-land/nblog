import nimib
import nimib / capture

nbInit

nbText """## A possible out of order API

One of the defining characteristics of
[Literate Programming](https://en.wikipedia.org/wiki/Literate_programming#Order_of_human_logic,_not_that_of_the_compiler)
is the possibility of running code in the order needed for exposition
and not the order required by the compiler.

Nimib does not provide this functionality natively but it can
be implemented in a rather straightforward way
(knowing a bit of the nimib internals).

Here I offer an example api and implementation
for `out of order` execution of code.

This is inspired by a new nice tool for literate programming in Nim
([NailIt](https://github.com/ZoomTen/nailit))
and the relative [forum discussion](https://forum.nim-lang.org/t/11327).

### Example of usage
"""

template nbCodeOutOfOrder(ident: untyped, body: untyped) =
  nbCodeSkip:
    body
  var `ident Blk` {. inject .} = nb.blk
  nb.blk.command = "nbCode"

  template `ident` =
    nbCode:
      body
    `ident Blk`.output = nb.blk.output
    `ident Blk`.context["output"] = nb.blk.output

  template `ident Hidden` =
    captureStdOut(`ident Blk`.output):
      body
    `ident Blk`.context["output"] = `ident Blk`.output

nbText "Here I call a function that I have not yet defined"

nbCodeOutOfOrder(callAdd):
  echo add(1, 2)

nbText "Let's call it again"

nbCodeOutOfOrder(callAddAgain):
  echo add(2, 3)

nbText "Here I implement the function"

nbCode:
  func add(a, b: int): int = a + b

nbText "I could decide to show the first call to add later"

callAdd()

nbText "but I could decide to not show it (you are not seeing the second call)"

callAddAgainHidden()

nbText """### Implementation

Click `Show Source` to see how this is implemented.

The internals are currently undergoing a major [reworking](https://github.com/pietroppeter/nimib/pull/235)
so this implementation might not work in the future.
"""

nbSave