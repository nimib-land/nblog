import nimib
nbInit
setCurrentDir nb.thisDir
nbRawHtml:
  """<script src="https://cdnjs.cloudflare.com/ajax/libs/p5.js/1.4.2/p5.min.js" integrity="sha512-rCZdHNB0AePry6kAnKAVFMRfWPmUXSo+/vlGtrOUvhsxD0Punm/xWbEh+8vppPIOzKB9xnk42yCRZ5MD/jvvjQ==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>"""
nbText: """## Bouncing balls with an ECS
Yesterday (Nov 14th 2022) I went to a very nice meetup
here in Milan ([Open Source Saturday Milano](https://www.meetup.com/it-IT/open-source-saturday-milano/)).
You go there and you propose what you want to work on (some Open Source related activity).
People might be curious and tag along, or you might be interested in what others are doing.

I went with the idea of exploring Entity Component Systems (ECS), something I had never played with.
Initially the idea was to use [polymorph].
I wanted to try and see if I was able to make it work with Nim's js backend.
Unfortunately it appears polymorph has [some kind of issue with js backend](https://github.com/rlipsc/polymorph/issues/21),
so the two poor souls that were curious about Nim, saw me fail miserably in the task
and generously helped debugging
(of course it took a while to understand the issue was with polymorph and not with the code I was writing).
At the end of morning I pivoted to try using [EasyEss](https://github.com/EriKWDev/easyess),
a polymorph's inspired ECS by the author of [Nanim](https://github.com/EriKWDev/nanim).
Indeed EasyEss works with Nim's js backend so the day was saved!

Today I managed to complete a very small demo.
Code is not really cleaned up and it is the first time I play with an ECS.
For drawing to canvas it uses code from [bouncing_ball_p5js](bouncing_ball_p5js.html),
but probably a better option would be to use something like [jscanvas](https://github.com/planetis-m/jscanvas).

To test the different components/systems I am showing 4 balls:
- one ball bounces with gravity directed towards the roof
- a smaller ball bounces with gravity directed approximately towards the bottom right corner
- a bigger ball does not feel gravity and slowly drifts bouncing off the walls
- the biggest ball is subject to drag and stops after a few bounces
  - drag acts a bit weird when bouncing close to the walls
- the balls do not interact with each other

To see the code, click on Show source button in the bottom right corner of the page.

[polymorph]: https://github.com/rlipsc/polymorph
"""
nbJsFromCode:
  import easyess
  import p5, std / lenientops

  let
    width = 360.0
    height = 360.0

  comp:
    type
      Size = object
        r: float

      Position = object
        x: float
        y: float

      Velocity = object
        dx: float
        dy: float

      Bounce = object

      Gravity = object
        ddx: float
        ddy: float

      Drag = object
        coefficient: float

      Draw = object


  const
    systemsGroup = "systems"
    renderingGroup = "rendering"

  sys [Position, vel: Velocity], systemsGroup:
    func moveSystem(item: Item) =
      let
        (ecs, entity) = item
        oldPosition = position

      position.y += vel.dy
      item.position.x += item.velocity.dx

      when defined(debugMove):
        debugEcho "Moved " & ecs.inspect(entity) & " from ", oldPosition, " to ", position

  sys [pos: Position, vel: Velocity, Bounce, Size], systemsGroup:
    proc bounceOnWalls(item: Item) =
      if pos.x > width - size.r or pos.x < size.r:
        vel.dx = -vel.dx
      if pos.y > height - size.r or pos.y < size.r:
        vel.dy = -vel.dy

  sys [pos: Position, vel: Velocity, Gravity, Size], systemsGroup:
    proc fall(item: Item) =
      # apply gravity only if not falling
      if not (pos.y > height - size.r or pos.y < size.r):
        vel.dy += gravity.ddy
      if not (pos.x > width - size.r or pos.x < size.r):
        vel.dx += gravity.ddx

  sys [pos: Position, vel: Velocity, Drag, Size], systemsGroup:
    proc airResistance(item: Item) =
      if abs(vel.dy) > 0:
        vel.dy = vel.dy*drag.coefficient
      if abs(vel.dx) > 0:
        vel.dx = vel.dx*drag.coefficient


  sys [Position, Draw, Size], renderingGroup:
    proc drawBall(item: Item) =
      ellipse(position.x, position.y, 2*size.r)


  createECS(ECSConfig(maxEntities: 100))

  let
    ecs = newECS()

  proc setup() {. exportc .} =
    createCanvas(width, height)

  proc draw() {. exportc .} =
    background(0)
    ecs.runSystems()
    ecs.runRendering()

  var ballId = 1

  proc newBall(r, x, y, dx, dy, ddx, ddy: float; bounce, gravity, drag = false, coeff = 1.0): auto =
    let
      ball = ecs.newEntity("ball " & $ballId)
      item = (ecs, ball)

    item.addComponent(Size(r: r))
    item.addComponent(Position(x: x, y: y))
    item.addComponent(Velocity(dx: dx, dy: dy))
    if bounce:
      item.addComponent(Bounce())
    if gravity:
      item.addComponent(Gravity(ddx: ddx, ddy: ddy))
    if drag:
      item.addComponent(Drag(coefficient: coeff))
    item.addComponent(Draw())

    result = ball

  let
    ball1 = newBall(15.0, 50.0, 180.0, -2.0, 1.0, 0.0, 0.0, true, false)
    ball2 = newBall(10.0, 10.0, 60.0, 4.0, 0.0, 0.0, -1.0, true, true)
    ball3 = newBall(7.0, 180.0, 180.0, 5.0, 2.0, 0.3, 0.5, true, true)
    ball4 = newBall(20.0, 240.0, 40.0, -15.0, 0.0, 0.0, 0.5, true, true, true, 0.99)

setCurrentDir nb.initDir
nbSave
