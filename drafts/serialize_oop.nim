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

Now we can turn our object into JSON, but how do we turn the JSON back to object again?

## [Parse-hooks](https://github.com/treeform/jsony#proc-parsehook-can-be-used-to-do-anything)
As you might have guessed, parse-hooks are functions that allows us to customize how types are parsed from JSON to that type.
And in our case, we want to take the JSON of `Controller`, `DpadController` or `JoyStickController` and return the correct object type. How can we determine which of the types the JSON object has though? This is where the `kind` field comes in. As you saw in `customDump` above, we set this field to the string representation of the type name. So if we read this field from the JSON, we can figure out which type it is! Brilliant! Now how do we do that? Let's start off with reading the `kind` field:
"""

nbCodeInBlock:
  proc parseHook(s: string, i: var int, v: var Controller) =
    var c = Controller()
    parseHook(s, i, c[])
    let kind = c.kind

nbText: hlMd"""
Here we use the same trick as before, we exploit that `Controller` is a `ref object`
so we can use the `parseHook` of the dereferenced type instead.
Here we parsed the object as if it was of the base type `Controller`,
but that is okay as `kind` can be accessed there.

The idea now is to use the `kind` as a key to a `Table` of parsing functions.
In there, we define a parsing function for each subtype of `Controller`.
And the key here is that inside these functions, we will know the exact type of
the object. So then we can just let jsony do its thing.
"""

nbCode:
  var parseFuncs: Table[string, proc (s: string, i: var int): Controller]

  proc parseDpad(s: string, i: var int): Controller =
    var v: DpadController
    new v
    parseHook(s, i, v[])
    return v

  parseFuncs[nimIdentNormalize($DpadController)] = parseDpad

nbText: hlMd"""
As you can imagine, the only part we have to change for the different types is `var v: DpadController`.
So this could be easily done in a template instead to reduce boilerplate: 
"""

nbCode:
  template addControlParser(typeName: untyped) =
    parseFuncs[nimIdentNormalize($typeName)] =
      proc (s: string, i: var int): Controller =
        var v: typename
        new v
        parseHook(s, i, v[])
        return v

  addControlParser(Controller)
  addControlParser(DpadController)
  addControlParser(JoyStickController)

nbText: hlMd"""
With all the parse-functions defined, we can update our parse-hook
to take the changes into account:
"""

nbCode:
  # Updated parseHook
  proc parseHook(s: string, i: var int, v: var Controller) =
    var c = Controller()
    # parseHook modifies `i`, so store it so we can re-parse this object below
    let current_i = i
    parseHook(s, i, c[])
    i = current_i # reset i
    let kind = c.kind
    v = parseFuncs[kind](s, i)

nbText: hlMd"""
Now let's try it out!
"""

nbCodeInBlock:
  let jsonText = """{"x":1,"y":-1,"a":false,"b":false,"kind":"Dpadcontroller"}"""
  echo jsonText.fromJson(Controller).DpadController[]

nbText: hlMd"""
Yippie! It worked! Even though we loaded it as a `Controller`,
it has the correct value for the `x` and `y` fields!


## Template-ize everything!
So, now that we have solved this problem, can we also make it easier to use?
Having to define a lot of function for each type get tedious quite quickly.
The good news is that we can boil everything down into a single template call.
Look at this:
"""

nbCode:
  template registerController(typeName: untyped) =
    parseFuncs[nimIdentNormalize($typeName)] =
      proc (s: string, i: var int): Controller =
        var v: typename
        new v
        parseHook(s, i, v[])
        return v

    method customDump(c: typeName): string =
      if c.isNil:
        "null"
      else:
        echo "kind: ", nimIdentNormalize($type(c)), type(c)
        c.kind = nimIdentNormalize($type(c))
        c[].toJson()
    
nbText: """
Now we can simply define a new subtype and with a single call to this template,
we will be able to serialize and deserialize it correctly! 
"""

nbCode:
  type DpadControllerWithPress = ref object of DpadController
      isDpadPressed: bool

  registerController(DpadControllerWithPress)

nbSave