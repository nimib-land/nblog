import nimib

template nbCodeDontRun*(body: untyped) = # adapted from nim conf slides, should add to nimib
  newNbCodeBlock("nbCode", body): # in slides a new command was used, not necessary
    discard

nbInit
nbText: "## Imperative to js hello loop"
nbText: "> For context see this forum thread [comment](https://forum.nim-lang.org/t/9554#62802)"
nbText: "The challenge is \"Try converting the following imperative script into Javascript:\""
nbCodeDontRun:
  echo "welcome to the hello program"
  echo "enter a name or the word 'exit':"
  var name = readLine(stdin)
  while (name != "exit"):
    echo "Hello, " & name
    echo "enter a name or the word 'exit':"
    name = readLine(stdin)
  echo "Thanks for playing"
nbText: "Below my solution using `nbKaraxCode`."
nbCode:
  template mySolution =
    nbKaraxCode:
      const
        helloId = "helloId"
        inputId = "inputId"
      var
        hello = "welcome to the hello program"
        name = ""
      karaxHtml:
        p(id=helloId):
          text hello
        label:
          text "enter a name or the word 'exit':"
        input(id = inputId, `type` = "text"):
          text name
        button:
          text "Enter"
          proc onClick() =
            name = $getVNodeById(inputId).getInputText
            hello = "Hello, " & name
nbText: "Did I end up with \"a very different looking program that has to handle state\"?"
nbText: "---"
mySolution
nbSave