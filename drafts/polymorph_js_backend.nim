import nimib

nbInit
nbText: """
Trying to use [polymorph] with nim js backend.
It does not work. File created to submit an issue.

The following code is executed by nimib
both using c backend and js backend.

If you open the browser console you will see that with js backend:
- it starts with Pos (0, 0) instead of (1, 1) (and wrong velociy)
- at each step neither move nor gravity are applied, only bounce is applied.

[polymorph]: https://github.com/rlipsc/polymorph
"""
#[ this template is broken because nbCode's code reading does not work! fun to see!
template nbJsAndCode(body: untyped) =
  nbCode:
    body
  nbJsFromCode:
    body
]#
nbCode:
  import polymorph

  # Parse some types as components.
  register defaultCompOpts:
    type
      Pos = object
        x, y: float
      Vel = object
        x, y: float
      Gravity = object
        strength: float
      Bounce = object   # A dataless 'tag' component.

  makeSystem "move", [Pos, Vel]:
    # Calculate basic movement.
    all:
      echo "move"
      pos.x += vel.x
      pos.y += vel.y

  makeSystem "gravity", [Vel, Gravity]:
    # Apply a gravity force to 'Vel'.
    all:
      vel.y -= gravity.strength

  makeSystem "bounce", [Pos, Vel, Bounce]:
    all:
      # Correct 'Pos.y' to never goes below zero, enacting a simple bounce
      # to 'Vel.y' if this occurs.
      if pos.y <= 0.0:
        pos.y = 0.0
        vel.y = abs(vel.y) * 0.5

  # Generate the framework and system procedures.
  makeEcsCommit "run"

  let
    ball = newEntityWith(
      Pos(x: 0.0, y: 0.0),
      Vel(x: 1.0, y: 1.0),
      Gravity(strength: 1.0),
      Bounce()
    ) 

  for i in 0 ..< 4:
    run()
    echo ball


nbJsFromCode:
  import polymorph

  # Parse some types as components.
  register defaultCompOpts:
    type
      Pos = object
        x, y: float
      Vel = object
        x, y: float
      Gravity = object
        strength: float
      Bounce = object   # A dataless 'tag' component.

  makeSystem "move", [Pos, Vel]:
    # Calculate basic movement.
    all:
      echo "move"
      pos.x += vel.x
      pos.y += vel.y

  makeSystem "gravity", [Vel, Gravity]:
    # Apply a gravity force to 'Vel'.
    all:
      vel.y -= gravity.strength

  makeSystem "bounce", [Pos, Vel, Bounce]:
    all:
      # Correct 'Pos.y' to never goes below zero, enacting a simple bounce
      # to 'Vel.y' if this occurs.
      if pos.y <= 0.0:
        pos.y = 0.0
        vel.y = abs(vel.y) * 0.5

  # Generate the framework and system procedures.
  makeEcsCommit "run"

  let
    ball = newEntityWith(
      Pos(x: 0.0, y: 0.0),
      Vel(x: 1.0, y: 1.0),
      Gravity(strength: 1.0),
      Bounce()
    ) 

  for i in 0 ..< 4:
    run()
    echo ball
nbSave