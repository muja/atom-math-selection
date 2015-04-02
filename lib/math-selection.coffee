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
  activate: (state) ->
    { allowUnsafeNewFunction } = require 'loophole'
    atom.workspaceView.eachEditorView (editorView) ->
      editorView.command 'math-selection:replace', ->
        editor = editorView.getEditor()
        editor.transact -> replaceSelections(editor)
      editorView.command 'math-selection:copy', ->
        copySelections(editorView.getEditor())

  deactivate: ->
