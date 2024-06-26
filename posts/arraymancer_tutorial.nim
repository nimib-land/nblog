import nimib
import nblog

nbInit(theme = useNblog)
nb.title "Arraymancer Tutorial - First steps"
nb.subtitle "A remake of the original tutorial using nimib"
nb.pubDate 2021, 3, 12

nbText: """
> original tutorial: <https://mratsim.github.io/Arraymancer/tuto.first_steps.html>
>
> I will note differences with the original in quoted sections.

## Tensor properties

Tensors have the following properties:
- `rank`: 0 for scalar (cannot be stored), 1 for vector, 2 for matrices, *N* for *N* dimensional arrays
- `shape`: a sequence of the tensor dimensions along each axis

Next properties are technical and there for completeness:
- `stride`: a sequence of numbers of steps to get the next item along a dimension
- `offset`: the first element of the tensor
"""
# order of variable names (d, c, e, ..., a, b) I guess it reflects the original order of the sections.
nbCode:
  import arraymancer, sugar, sequtils

  let d = [[1, 2, 3], [4, 5, 6]].toTensor()

  echo d

nbText: """> message changed, it was: `Tensor of shape 2x3 of type "int" on backend "Cpu"`"""

nbCode:
  dump d.rank
  dump d.shape
  dump d.strides ## [x,y] => next row is x elements away in memory while next column is 1 element away.
  dump d.offset
nbText: "> echo of shape and strides changed (dropped @)"

nbText: """
## Tensor creation
The canonical way to initialize a tensor is by converting a seq of seq of ... or an array of array of ...
into a tensor using `toTensor`.
`toTensor` supports deep nested sequences and arrays, even sequences of array of sequences.
"""

nbCode:
  let c = [
            [
              [1,2,3],
              [4,5,6]
            ],
            [
              [11,22,33],
              [44,55,66]
            ],
            [
              [111,222,333],
              [444,555,666]
            ],
            [
              [1111,2222,3333],
              [4444,5555,6666]
            ]
          ].toTensor()
  echo c
nbText: "> I am not sure where the additional pipes come from, maybe a bug?"
nbText: """
`newTensor` procedure can be used to initialize a tensor of a specific
shape with a default value. (0 for numbers, false for bool...)

`zeros` and `ones` procedures create a new tensor filled with 0 and
1 respectively.

`zeros_like` and `ones_like` take an input tensor and output a
tensor of the same shape but filled with 0 and 1 respectively.
"""
nbCode:
  let e = newTensor[bool]([2, 3])
  dump e
nbCode:
  let f = zeros[float]([4, 3])
  dump f
nbCode:
  let g = ones[float]([4, 3])
  dump g
nbCode:
  let tmp = [[1,2],[3,4]].toTensor()
  let h = tmp.zeros_like
  dump h
nbCode:
  let i = tmp.ones_like
  dump i

nbText: """
## Accessing and modifying a value

Tensors value can be retrieved or set with array brackets.
"""
# need to import sequtils to have toSeq
nbCode:
    var a = toSeq(1..24).toTensor().reshape(2,3,4)
    echo a
nbCode:
    dump a[1, 1, 1]
    echo a
nbCode:
    a[1, 1, 1] = 999
    echo a
nbText: """
## Copying

Warning ⚠: When you do the following, both tensors `a` and `b` will share data.
Full copy must be explicitly requested via the `clone` function.
"""
block: # using a block I can reuse a
  nbCode:
    let a = toSeq(1..24).toTensor().reshape(2,3,4)
    var b = a
    var c = clone(a)
  nbText: """
  Here modifying `b` WILL modify `a`.

  > adding an example of modification and an example of clone:
  """
  # still in block scope in order to reuse b
  nbCode:
    dump a[1, 0, 0]
    c[1, 0, 0] = 0
    dump a[1, 0, 0]
    b[1, 0, 0] = 0
    dump a[1, 0, 0]
nbText: """
This behaviour is the same as Numpy and Julia,
reasons can be found in the following
[under the hood article](https://mratsim.github.io/Arraymancer/uth.copy_semantics.html).
"""

nbSaveJson
