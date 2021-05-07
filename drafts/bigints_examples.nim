import nimib, strformat
# add timings
nbInit
nbUseLatex
nbText """
# Bigints Examples
see <https://github.com/def-/nim-bigints/tree/master/examples>"""

nbCode:
  import bigints, sugar

# todo: add toc
nbText "## Rosetta code"
nbText """### [Arbitrary-precision integers](http://rosettacode.org/wiki/Arbitrary-precision_integers_(included))

$$5^{4^{3^2}}$$
"""
nbCode:
# a way to keep this as a separate scope? go the nim way: wrap it in scope!
  var x = 5.pow 4.pow 3.pow 2
  var s = $x

  echo s[0 .. 19] & "..." & s[^20 .. ^1]
  echo s.len, " digits"

nbText """
### Combinations and permutations
Solution for [Combinations_and_permutations](http://rosettacode.org/wiki/Combinations_and_permutations)"""

nbCode:
  proc perm(n, k: int32): BigInt = # note the spacing on next documentation comment
    result = initBigInt 1  ## I could also use `one` (a const)
    var
      k = n - k
      n = n
    while n > k:
      result *= n
      dec n
  
  proc comb(n, k: int32): BigInt =
    result = perm(n, k)
    var k = k
    while k > 0:
      result = result div k
      dec k

  # implemented walrus-like, it will be rendered over 3 lines
  dump (let combinations = comb(1000, 969); combinations)
  dump (let permutations = perm(1000, 969); permutations)

nbText fmt"""
`combinations` has {($combinations).len} digits  
`permutations` has {($permutations).len} digits"""  # I used trailing spaces here

nbSave
