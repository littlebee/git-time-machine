GitTimeMachineView = require './git-time-machine-view'
{TextEditor, CompositeDisposable} = require 'atom'

module.exports = GitTimeMachine =
  gitTimeMachineView: null
  timelinePanel: null
  subscriptions: null

  activate: (state) ->
    @gitTimeMachineView = new GitTimeMachineView(state.gitTimeMachineViewState,
      file: atom.workspace.getActiveTextEditor()?.getPath())
    @timelinePanel = atom.workspace.addBottomPanel(item: @gitTimeMachineView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-time-machine:open': => @open()
    atom.workspace.onDidChangeActivePaneItem (editor) => @_onDidChangeActivePaneItem()


  deactivate: ->
    @timelinePanel.destroy()
    @subscriptions.dispose()
    @gitTimeMachineView.destroy()


  serialize: ->
    gitTimeMachineViewState: @gitTimeMachineView.serialize()


  open: ->
    # console.log 'GitTimeMachine was opened!'
    if @timelinePanel.isVisible()
      @timelinePanel.hide()
    else
      @timelinePanel.show()


  _onDidChangeActivePaneItem: (editor) ->
    editor = atom.workspace.getActiveTextEditor()
    @gitTimeMachineView.setFile(editor?.getPath())
    return

    
