import nimib except toJson

nbInit

nbText: hlMd"""
# Serialization of object oriented types using [jsony](https://github.com/treeform/jsony)
## Background
In the process of refactoring Nimib we decided that we wanted to use inheritance to represent the different blocks.
We would have one base block that all other nimib blocks (i.e. image, code, etc) would inherit from.
The reason we want them to be of the same base is that we want to be able to store them in a single `seq`.
The problem then arises: how do we serialize and deserialize this `seq` now that we don't have the static type information anymore? (Putting them all in the same `seq` makes them all appear to be of the base type)
We somehow have to use the dynamic type information instead.  
In this document we will show one way of solving this problem that might turn out to be useful for nimib, but might be more generally interersting if you have
an hierarchy of types that you want to serialize and deserialize.

## OOP Type Hierarchy
Let's start off with defining the types we will be using in this document.
The scenario is that we have a `Controller` type that represents a generic game controller with at least an A and B button.
"""

nbCode:
  type Controller = ref object of RootObj
    a, b: bool
    kind: string

nbText: hlMd"""
The fields `a` and `b` stores whether the buttons A and B are pushed.
The `kind` field does not have anything to do with the controller but it is metadata we will need later on.
Let's define two specialized controllers, D-pad and Joy-stick:
"""

nbCode:
  type
    DpadController = ref object of Controller
      x, y: int
    JoyStickController = ref object of Controller
      angle, radius: float

nbText: hlMd"""
`x` and `y` represents the directions of the D-pad in both the x- and y-directions. For the joystick the `angle` and `radius` specifies the current position of the joystick. The details doesn't really matter in this example. What matters is that these two types have different fields and inherits from the same base type. 

## The problem
Let's create an instance of each type and echo them along with their serialized JSON-strings:  
"""

nbCode:
  import jsony
  let dpad = DpadController()
  let joystick = JoyStickController()
  echo dpad[]
  echo dpad.toJson()
  echo joystick[]
  echo joystick.toJson()

nbText: hlMd"""
As we can see, both types serialize just fine to JSON. SO what is the problem then? 
The problem arises when we put them both inside an homogenous data structure like a `seq[Controller]`:
"""

nbCodeInBlock:
  let list = @[dpad, joystick]
  echo typeof(list)
  echo list[0].toJson()

nbText: hlMd"""
Now all the specialized fields are gone! This is because `list` is a list of `Controller` objects for all the compiler knows.
So jsony will in good faith treat them as such and only include the fields from the base type. How irritating!

## [Dump-hooks](https://github.com/treeform/jsony#proc-dumphook-can-be-used-to-serialize-into-custom-representation)
Of course, we know that the type information is there somewhere. 
We just have to show the compiler and jsony that.
The type information is stored dynamically so we want to utilize dynamic dispatch to extract the type information somehow.
Let's start off with what jsony's dump-hooks are. They are functions we can define for a type to customize how it is serialized.
And that is exactly what we want to do! We want to hijack the serialization of the base type and do some dynamic dispatch to figure out exactly
which subtype the object is. What exactly do I mean by this dynamic dispatch? Basically we have to define a `method` for each type that returns the
serialized string of the object. This way, the compiler and jsony will know exactly which subtype it is dealing with:  
"""

nbCode:
  import strutils

  method customDump(c: Controller): string {.base.} =
    if c.isNil:
      "null"
    else:
      c.kind = nimIdentNormalize($type(c))
      c[].toJson()

  method customDump(c: DpadController): string =
    if c.isNil:
      "null"
    else:
      c.kind = nimIdentNormalize($type(c))
      c[].toJson()

  method customDump(c: JoyStickController): string =
    if c.isNil:
      "null"
    else:
      c.kind = nimIdentNormalize($type(c))
      c[].toJson()

  proc dumpHook(s: var string, v: Controller) =
    s.add v.customDump()

  let list = @[dpad, joystick]
  echo list.toJson()

nbText: hlMd"""
Wow it was able to serialize the object correctly now! Let's go through the code a bit more in detail.
We define the dump-hook for the `Controller` base type and call the `method` (and this is important) `customDump` on it. 
This will make Nim do the dynamic dispatch by looking for a suitible `method` that matches the type. The 3 `method`s are
carbon copies of each other, they just have to be defined for us to get the correct type information.
One more trick we use is the fact that our types are `ref object`s. This means we can avoid infinite recursion by serializing
the dereferenced object `c[]` and still get the same JSON.
"""

nbSave