import std/[parseopt, strutils]
import std/tables
export tables


type
  Context* = object of RootObj
    cmdArguments*: seq[string]
    cmdOptions*: Table[string, string]


proc initContext*(cmdArguments: seq[string] = @[], cmdOptions = initTable[string, string]()): Context =
  Context(cmdArguments: cmdArguments, cmdOptions: cmdOptions)

type
  Handler = proc(context: Context): int {.nimcall.}
  Command = tuple[route: string, handler: Handler]


proc parseCommands*(commands: openArray[Command], defaultHandler: Handler = nil): int =
  ##[ Parse command-line params, store the arguments and options in context, and invoke the matching handler.
  
  Returns the exit code that should be returned by your app to the caller.
  ]##

  var
    parser = initOptParser()
    cmdComponents: seq[string]
    handler = defaultHandler
    context: Context
    route = ""

  block findHandler:
    for (kind, key, val) in getopt(parser):
      case kind
      of cmdArgument:
        cmdComponents.add(key)
        route = cmdComponents.join(" ")
      of cmdShortOption, cmdLongOption:
        context.cmdOptions[key] = val
      of cmdEnd:
        break

      for command in commands:
        if command.route == route:
          handler = command.handler
          break findHandler

  if handler.isNil:
    quit("Command not found", 1)

  if len(parser.remainingArgs) > 0:
    for (kind, key, val) in getopt(parser.remainingArgs):
      case kind
      of cmdArgument:
        context.cmdArguments.add(key)
      of cmdShortOption, cmdLongOption:
        context.cmdOptions[key] = val
      of cmdEnd:
        break 

  handler(context) 
