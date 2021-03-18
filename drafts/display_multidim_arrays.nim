import nimib, strformat

nbInit

nbText: """
# Display Multidimensional Arrays

I was testing nimib while trying to reproduce [arraymancer]() tutorial,
and I ran into some [issues](https://github.com/mratsim/Arraymancer/issues/500)
that arraymancer currently has when displaying tensors.
This got me to ask myself:

> How do I display a multidimensional array with 3 or 4 (or more) dimensions?

## Other languages

Let us look into how other languages (Python, R) do it.
I also get the opportunity of trying out the existing bridges.
"""

nbCode:
  import sequtils, nimpy, rnim

block:
  nbText: """
  ### Python

  Using [nimpy](https://github.com/yglukhov/nimpy)
  """ # todo: add a general overview how to use nimpy (based on my very limited experience?)
  nbCode:
    let np = pyImport("numpy")
    var a = np.arange(15)
    echo a
  nbText: "sometimes you see the `repr` of the array:"
  nbCode:
    let py = pyBuiltinsModule()
    # py.print(a) does not work
    echo py.repr(a)
  nbText: "let's go in two dimensions:"
  nbCode:
    a = a.reshape(3, 5)
    echo a
  nbText: "now three:"
  nbCode:
    a = np.arange(12).reshape(2, 2, 3)
    echo a
  nbText: "and four:"
  nbCode:
    a = np.arange(16).reshape(2, 2, 2, 2)
    echo a
  nbText: """and in fact [numpy has a very simple layout](https://numpy.org/doc/stable/user/quickstart.html#printing-arrays)
  when printing arrays

  > * the last axis is printed from left to right,
  > * the second-to-last is printed from top to bottom,
  > * the rest are also printed from top to bottom, with each slice separated from the next by an empty line.

  and this carries on with 5 or more dimensions:
  """
  nbCode:
    a = np.arange(32).reshape(2, 2, 2, 2, 2)
    echo a
  nbText: """
  Note that lists of matrices have one empty line between matrices,
  lists of lists of matrices have two empty lines between lists of matrices
  and lists of lists of lists of matrices have three empty lines between lists of lists of lists of matrices.
  """

#[
  Interesting resources for R:
    - http://www.johndcook.com/blog/r_language_for_programmers/
    - https://minimaxir.com/2017/06/r-notebooks/
    - https://github.com/hadley/r-internals
    - https://adv-r.hadley.nz/index.html
  And on arrays in particular:
    - https://rstudio.github.io/reticulate/articles/arrays.html
    - https://www.dummies.com/programming/r/how-to-create-an-array-in-r/
    - https://github.com/rstudio/reticulate
]#
block:
  nbText: fmt"""
  ### R

  Using [rnim](https://github.com/SciNim/rnim).

  First example in R would be: `array(1:15)`.
  """
  nbCode:
    let R = setupR()
    var a = R.array(toSeq(1 .. 15))
    echo R.print(a)
    ## echo a # only prints the type info without content
    ## discard R.print(a) # prints nothing
    echo R.str(a)
  nbText: """I do not know how to obtain a decent display, in R only the line before Type is shown.

  Two dimensions (R equivalent: `array(1:15, c(3, 5))`):
  """
  nbCode:
    a = R.array(toSeq(1 .. 15), @[3, 5])
    echo R.print(a)
  # here I suffer the fact that I am stripping the output. I really shouldn't!
  nbText: "now three:"
  nbCode:
    a = R.array(toSeq(1 .. 12), @[2, 2, 3])
    echo R.print(a)
  nbText: "and four:"
  nbCode:
    a = R.array(toSeq(1 .. 16), @[2, 2, 2, 2])
    echo R.print(a)

nbShow