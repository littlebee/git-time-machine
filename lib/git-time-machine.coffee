GitTimeMachineView = require './git-time-machine-view'
{CompositeDisposable} = require 'atom'

module.exports = GitTimeMachine =
  gitTimeMachineView: null
  timelinePanel: null
  subscriptions: null

  activate: (state) ->
    @gitTimeMachineView = new GitTimeMachineView state.gitTimeMachineViewState
    @timelinePanel = atom.workspace.addBottomPanel(item: @gitTimeMachineView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-time-machine:toggle': => @toggle()
    atom.workspace.onDidChangeActivePaneItem (editor) => @_onDidChangeActivePaneItem()


  deactivate: ->
    @timelinePanel.destroy()
    @subscriptions.dispose()
    @gitTimeMachineView.destroy()


  serialize: ->
    gitTimeMachineViewState: @gitTimeMachineView.serialize()


  toggle: ->
    # console.log 'GitTimeMachine was opened!'
    if @timelinePanel.isVisible()
      @gitTimeMachineView.hide()
      @timelinePanel.hide()
    else
      @timelinePanel.show()
      @gitTimeMachineView.show()
      @gitTimeMachineView.setEditor atom.workspace.getActiveTextEditor()


  _onDidChangeActivePaneItem: (editor) ->
    editor = atom.workspace.getActiveTextEditor()
    if @timelinePanel.isVisible()
      @gitTimeMachineView.setEditor(editor)
    return
