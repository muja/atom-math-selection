MathSelectionView = require './math-selection-view'
{CompositeDisposable} = require 'atom'

module.exports = MathSelection =
  mathSelectionView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @mathSelectionView = new MathSelectionView(state.mathSelectionViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @mathSelectionView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'math-selection:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @mathSelectionView.destroy()

  serialize: ->
    mathSelectionViewState: @mathSelectionView.serialize()

  toggle: ->
    console.log 'MathSelection was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
