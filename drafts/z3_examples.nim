import nimib

nbInit
nbText: """# Z3 Examples

All examples below come from z3-nim [tests](https://github.com/zevv/nimz3/blob/62a3ead5e02e04df787b65af453323bfa9413610/tests/test1.nim)

## Installing Z3
If you try to run the z3 examples without installing z3 you will
see an error such as `could not load libz3.so` (on windows it will mention `libz3.dll`).

`nim-z3` depends on z3 dynamic library which has to be recovered independently.
Releases with prebuilt libraries are available but being on a Mac M1 I had to build the library myself.

```
git clone https://github.com/Z3Prover/z3.git
cd z3
```

then (following instructions in [repo's readme](https://github.com/Z3Prover/z3#building-z3-using-make-and-gccclang))

```
python scripts/mk_make.py
cd build
make
sudo make install
```

The last command (`sudo make install`) did not work for me and I just copied
the generated `libz3.dylib` in the folder from where I am running this script
(a better way - which was what `make install` was trying to do - would be
to move it in folder in path, along with z3 executable and header files).
I also had to rename the library to `libz3.so`, since this is what z3-nim looks for.

For the examples to work you must first import the library:
"""
nbCode:
  import z3
nbText: "## De Morgan"
nbCode:
  z3:
    let x = Bool("x")
    let y = Bool("y")
    let exp = not (not (x and y )) <-> ((not x) or (not y))
    echo exp
    let s = Solver()
    s.assert (x and y) or (not x and y)
    if s.check() == Z3_L_TRUE:
      echo s.get_model()
nbText: "## tie or shirt?"
nbCode:
  z3:
    let tie = Bool("tie")
    let shirt = Bool("shirt")
    let s = Solver()
    s.assert (not tie) or shirt
    s.assert (not tie) or not(shirt)
    if s.check() == Z3_L_TRUE:
      echo s.get_model()

nbText: "## math school problem"
nbCode:
  z3:
    let x = Int("x")
    let y = Int("y")
    let z = Int("z")
    let s = Solver()
    s.assert 3 * x + 2 * y - z == 1
    s.assert 2 * x - 2 * y + 4 * z == -2
    s.assert x * -1 + y / 2 - z == 0
    echo s
    if s.check() == Z3_L_TRUE:
      echo s.get_model()

nbText: "## XKCD restaurant order"
nbCode:
  z3:
    let a = Int("a")
    let b = Int("b")
    let c = Int("c")
    let d = Int("d")
    let e = Int("e")
    let f = Int("f")

    let s = Solver()
    s.assert a*215 + b*275 + c*335 + d*355 + e*420 + f*580 == 1505
    s.assert a<100 and b<100 and c<100 and d<100 and e<100 and f<100
    s.assert a>=0 and b>=0 and c>=0 and d>=0 and e>=0 and f>=0
    if s.check() == Z3_L_TRUE:
      echo s.get_model()

nbText "## sudoku"
nbCode:
  # "Extreme" sudoku: http://www.sudokuwiki.org/Weekly_Sudoku.asp?puz=28

  let · = 0
  let sudoku = [
    [ ·, ·, ·, ·, ·, 8, 9, 4, · ],
    [ 9, ·, ·, ·, ·, 6, 1, ·, · ],
    [ ·, 7, ·, ·, 4, ·, ·, ·, · ],
    [ 2, ·, ·, 6, 1, ·, ·, ·, · ],
    [ ·, ·, ·, ·, ·, ·, 2, ·, · ],
    [ ·, 8, 9, ·, ·, 2, ·, ·, · ],
    [ ·, ·, ·, ·, 6, ·, ·, ·, 5 ],
    [ ·, ·, ·, ·, ·, ·, ·, 3, · ],
    [ 8, ·, ·, ·, ·, 1, 6, ·, · ],
  ]

  z3:
    let s = Solver()
    var cs: array[9, array[9, Z3_ast_int]]

    # Create sudoku cells

    for y, row in sudoku.pairs():
      for x, v in row.pairs():
        let c = Int($x & "," & $y)
        cs[y][x] = c
        if v != 0:
          s.assert c == v
        else:
          s.assert c >= 1 and c <= 9

    # Each row and col contains each digit only once

    for row in cs:
      s.assert distinc row

    for y in 0..8:
      var col: seq[Z3_ast_int]
      for x in 0..8:
        col.add cs[x][y]
      s.assert distinc(col)

    # Each 3x3 square contains each digit only once

    for x in [0, 3, 6]:
      for y in [0, 3, 6]:
        var sq: seq[Z3_ast_int]
        for dx in 0..2:
          for dy in 0..2:
            sq.add cs[x+dx][y+dy]
        s.assert distinc sq

    # Get model and print solution

    s.check_model:
      for row in cs:
        for c in row:
          stdout.write $eval(c) & " "
        stdout.write "\n"

nbText "## scopes"
nbCode:
  z3:
    let x = Int "x"
    let y = Int "y"
    let s = Solver()
    s.push:
      s.assert -x + y == 10
      s.assert x + y * 2 == 20
      echo s.check
    s.push:
      s.assert 3 * x + y == 10
      s.assert 2 * x + 2 * y == 21
      echo s.check

nbText "## simplify"
nbCode:
  z3:
    let x = Int "x"
    let y = Int "y"
    let e =  x + 2 * y + 3 * x - y - y
    echo e
    echo simplify e

nbText "## floating point"
nbCode:
  z3:
    let x = Float "x"
    let y = Float "y"
    let s = Solver()
    s.assert x * 2.0 == y
    s.assert x == 15.0
    if s.check() == Z3_L_TRUE:
      let model = s.get_model()
      echo eval(x)

nbText "## forall"
nbCode:
  z3:
    let s = Solver()
    let x = Int "x"
    let y = Int "y"
    s.assert y == 1
    s.assert forall([x], x * y == x)
    if s.check() == Z3_L_TRUE:
      echo s.get_model()

nbText "## exists"
nbCode:
  z3:
    let s = Solver()
    let x = Int "x"
    let y = Int "y"
    s.assert y == 20
    s.assert exists([x], x * y == 180)
    if s.check() == Z3_L_TRUE:
      echo s.get_model()

nbText "## planetary/epicyclic gear system"
nbCode:
  # Find the gear tooth count for a planetary gear system with a
  # ratio of 1:12

  z3:
    let R = Int("R") # ring teeth
    let S = Int("S") # sun teeth
    let P = Int("P") # planet teeth

    let Tr = Int("Tr")  # ring turns
    let Ts = Int("Ts")  # sun turns
    let Ty = Int("Ty")  # carrier turns

    let s = Solver()

    s.assert Ts == 12    # Sun speed
    s.assert Tr == 0     # Ring speed
    s.assert Ty == 1     # Y-carrier speed

    s.assert R >= 10 # Don't make gears too small
    s.assert P >= 10
    s.assert S >= 10

    # Planetary gears constraints
    s.assert (R + S) * Ty == R * Tr + Ts * S
    s.assert R == 2 * P + S

    s.check_model:
      echo model

nbText "## very simple optimize"
nbCode:
  z3:
    # this does not come from tests
    let s = Optimizer()
    let n = Int "n"
    s.assert n <= 3
    s.maximize n
    echo s

    # this code fails:
    # s.check() == Z3_L_TRUE
    #  echo s.get_model()

    # this code does not fail:
    echo s.check()
    echo s.get_model()

nbText "## optimize"
nbCode:
  # Pablo buys popsicles for his friends. The store sells single popsicles
  # for $1 each, 3-popsicle boxes for $2, and 5-popsicle boxes for $3. What
  # is the greatest number of popsicles that Pablo can buy with $8?
  z3:
    let s = Optimizer()
    let a = Int "a"
    let n = Int "n"
    let p1 = Int "p1"
    let p3 = Int "p3"
    let p5 = Int "p5"
    s.assert a == p1 * 1 + p3 * 2 + p5 * 3
    s.assert n == p1 * 1 + p3 * 3 + p5 * 5
    s.assert p1 >= 0 and p3 >= 0 and p5 >= 0
    s.assert a == 8
    s.maximize n
    echo s
    # this code fails:
    #if s.check() == Z3_L_TRUE:
    #  echo s.get_model()
    echo s.check()
    echo s.get_model()


nbSave