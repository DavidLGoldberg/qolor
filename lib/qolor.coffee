QolorView = require './qolor-view'
{CompositeDisposable} = require 'atom'

module.exports = Qolor =
  qolorView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @qolorView = new QolorView(state.qolorViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @qolorView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'qolor:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @qolorView.destroy()

  serialize: ->
    qolorViewState: @qolorView.serialize()

  toggle: ->
    console.log 'Qolor was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
