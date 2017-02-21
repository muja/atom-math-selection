{ CompositeDisposable } = require 'atom'
math = require 'mathjs'
allowUnsafeNewFunction = null

replaceSelections = (editor) ->
  selections = editor.getSelections()
  for selection in selections
    if selection.isEmpty()
      selection.cursor.moveToEndOfLine()
      selection.selectToFirstCharacterOfLine()
      eol = true
    evaluated = allowUnsafeNewFunction ->
      try
        math.eval(selection.getText())
      catch e
        e
    editor.setTextInBufferRange(selection.getBufferRange(), String(evaluated))
    if eol
      selection.cursor.moveToEndOfLine()
      selection.selectToFirstCharacterOfLine()

# replace the selections, copy them, and reset the editor
copySelections = (editor) ->
  stack = editor.buffer.history.redoStack.slice()
  editor.transact -> replaceSelections(editor)
  editor.copySelectedText()
  editor.undo()
  editor.buffer.history.redoStack = stack

module.exports =
  activate: ->
    { allowUnsafeNewFunction } = require 'loophole'
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'math-selection:replace', ->
      if editor = atom.workspace.getActiveTextEditor()
        editor.transact -> replaceSelections(editor)
    @subscriptions.add atom.commands.add 'atom-workspace', 'math-selection:copy', ->
      if editor = atom.workspace.getActiveTextEditor()
        copySelections(editor)

  deactivate: ->
    @subscriptions.dispose()
