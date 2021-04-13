import nimib

nbInit
nbDoc.useLatex
nbText: """# Bernoulli and beyond with [alea](https://github.com/andreaferretti/alea)

Someone in the nim-science chat today asked about if there is a library with a [categorical distribution](https://en.wikipedia.org/wiki/Categorical_distribution).

I got curious on how to implement this with [alea](https://github.com/andreaferretti/alea), so that I can learn a bit how alea works.

## Alea

In alea first we need to initialize a random number generator to sample from the distributions:
""" # where today is 2021-04-12
nbCode:
  import random/xorshift
  import alea
  import math, sugar, strutils

  var rng = wrap(initXorshift128Plus(1337))
nbText: """
We will carry around this random number generator and use it for every operation with random variables.
It represents the probability space $\Omega$ in the [definition](https://en.wikipedia.org/wiki/Random_variable)
of the random variable $X$:

$$X: \Omega \to E$$

Where $E$ (a measurable space), will be represented by a generic type $T$.

Note that I was not able to use the rng suggested by alea, I got some gcc error due to the usage of urandom.

This is the code that did not work for me:

```nim
import random/urandom, random/mersenne
import alea

var rng = wrap(initMersenneTwister(urandom(16)))
```

I decide to pick another rng (and actually remove the call from urandom that was causing the error) from the documentation
of [nim-random](https://github.com/oprypin/nim-random). I probably should file an issue.
""" # I need a nbSkip to have code highlighting in non-executing code
# Also, why alea does not use the random generators in stdlib? they were not ready when alea was coded?

nbText: """### Bernoulli distribution

Bernoulli distribution is already available.

Every distribution comes with a `sample` proc which has as first argument the random number generator.
`alea` also provides a `take` template to create a sequence with `n` samples.
"""
nbCode:
  let
    p = 0.9
    b = bernoulli(p)
  echo rng.sample b
  block:
    let s = take(rng, b, 10)
    echo s

# hey, using stdout directly I do not catch the echo anymore! I did not expect this!
#    stdout.write $(rng.sample b) & " "
#  stdout.writeLine ""
nbText: r"We can also compute the mean ($p$), variance ($p(1-p)$) and standard deviation ($\sqrt(p (1 - p))$)"
nbCode:
  echo rng.mean b
  echo rng.variance b
  echo p*(1 - p)
  echo rng.stddev b
  echo sqrt(p*(1 - p))

nbText: """### Choice distribution

A categorical distribution that is already implemented in alea is the one where the categories have equal probability:
"""
nbCode:
  let dice = choice(@[1, 2, 3, 4, 5, 6])
  block:
    let s = take(rng, dice, 10)
    echo s

nbText: """Note that the `mean` will not work for `dice` since it is implemented only for `RandomVar[float]`.

In order to have a mean I could do like this:
""" # I wish I had the runtime error capture!
nbCode:
  let fdice = choice(@[1.0, 2, 3, 4, 5, 6])
  echo rng.mean fdice

nbText: """### Categorical distribution

Finally, to [define a custom distribution](https://github.com/andreaferretti/alea#defining-custom-distributions)
I just need to define:

  1. an object that contains the parameters of the distribution
  2. a constructor to add initial validation
  3. a `sample` proc

Here is the generic object for a categorical distribution (on float numbers):
"""
nbCode:
  type
    Categorical* = object
      p*: seq[float]
      e*: seq[float]  ## categorical values
nbText: """This implementation is a bit fragile, since `p` and `e` should always have same length,
and I will be able to ensure that only through the constructor:
"""
nbCode:
  proc categorical*(s: seq[tuple[e, p: float]]): Categorical =
    var tot = 0.0
    for (e, p) in s:
      assert p >= 0 and p <= 1
      result.e.add e
      result.p.add p
      tot += p
    assert tot > 0  
    if tot != 1.0:
      echo "probabilities do not add to 1.0, they will be normalized to sum to 1"
      let w = 1.0 / tot
      for i in 0 .. result.p.high:
        result.p[i] = result.p[i] * w
nbText: """and we can already use this to create a biased dice, for example one that has double chance to output an odd number than an even number:"""
nbCode:
  let oddDice = categorical(@[(1.0, 0.2), (2.0, 0.1), (3.0, 0.2), (4.0, 0.1), (5.0, 0.2), (6.0, 0.1)])
nbText: "Now to close the loop I need to implement the `sample` proc:"
nbCode:
  proc sample*(rng: var Random, c: Categorical): float =
    var tot = 0.0
    let r = rng.random() ## a number between 0 and 1
    for i in 0 .. c.e.high - 1:
      tot += c.p[i]
      if r <= tot:
        return c.e[i]
    return c.e[^1]
nbText: "Let's test this:"
nbCode:
  block:
    let s = take(rng, oddDice, 20)
    echo s
  echo rng.mean(oddDice)
nbText: "And the output seems reasonable (I could probably overload the mean and try to use it to compute an exact mean."

nbText: """
## Conclusions

It was rather straightforward to implement a categorical distribution in alea.
We do get limited functionality by doing this, basically the ability to sample and compute some moments.
I did not use them, but in alea there is the possibilty of [composing operations](https://github.com/andreaferretti/alea#operations-on-random-variables)
on top of random variables
and [conditioning](https://github.com/andreaferretti/alea#conditioning-random-variables) between them.

Something which is probably missing in alea and it could be nice to add is the possibility of
computing probability density function and cumulative distribution functions.

For reference here are the apis of other scientific languages:

  - Python: <https://docs.scipy.org/doc/scipy/reference/tutorial/stats.html>
  - R: <https://cran.r-project.org/web/views/Distributions.html>
  - Julia: <https://github.com/JuliaStats/Distributions.jl>
"""

nbSave
# I should add to nimib the possibility to find project dir without looking for nimble but looking for git root directory
# a blog like this does not need to have a nimble file to have a well defined project directory.
