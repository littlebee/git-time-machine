{$, View} = require "atom-space-pen-views"
path = require('path')
_ = require('underscore-plus')
str = require('bumble-strings')
moment = require('moment')

GitLog = require 'git-log-utils'
GitTimeplot = require './git-timeplot'
GitRevisionView = require './git-revision-view'

NOT_GIT_ERRORS = ['File not a git repository', 'is outside repository', "Not a git repository"]

module.exports =
class GitTimeMachineView
  constructor: (serializedState, options={}) ->
    @$element = $("<div class='git-time-machine'>") unless @$element
    if options.editor?
      @setEditor(options.editor)
      @render()
      
    @_bindWindowEvents()


  setEditor: (editor) ->
    return if !editor? || editor == @editor || GitRevisionView.isActivating
    file = editor?.getPath()
    return unless file?
    
    @editor = editor
    @render()
    @loadExistingRevForEditor()


  render: () ->
    @commits = @gitCommitHistory()
    
    unless @commits?
      @_renderPlaceholder()
    else
      @$element.text("")
      @_renderCloseHandle()
      @_renderTimeplot(@commits)
      @_renderStats(@commits)

    return @$element


  # Returns an object that can be retrieved when package is activated
  serialize: ->
    return null


  # Tear down any state and detach
  destroy: ->
    @_unbindWindowEvents()
    @$element.remove()
    
    
  hide: ->
    @timeplot?.hide()   # so it knows to hide the popup


  show: ->
    @timeplot?.show()


  getElement: ->
    return @$element.get(0)


  gitCommitHistory: (editor=@editor)->
    # get the file name of the original file if on a timemachine editor
    file = editor?.__gitTimeMachine?.sourceEditor?.getPath() || editor?.getPath()
    return null unless file?
    
    try
      commits = GitLog.getCommitHistory file
    catch e
      if e.message?
        if str.weaklyHas(e.message, NOT_GIT_ERRORS)
          console.warn "#{file} not in a git repository"
          return null
      
      atom.notifications.addError String e
      console.error e
      return null

    return commits;


  loadExistingRevForEditor: (editor=@editor) ->
    return unless editor.__gitTimeMachine?
    
    _.defer =>
      return unless editor.__gitTimeMachine?
      
      [sourceEditor, revEditor] = [editor.__gitTimeMachine.sourceEditor, editor.__gitTimeMachine.leftRevEditor]
      unless sourceEditor.isDestroyed() || revEditor.isDestroyed()
        @activateTimeMachineEditorForEditor(editor) unless editor.isDestroyed()
        GitRevisionView.splitDiff(sourceEditor, revEditor)
        GitRevisionView.syncScroll(sourceEditor, revEditor)
    
    
  destroyEditor: (editor=@editor) ->
    return unless editor.__gitTimeMachine?
    [sourceEditor, revEditor] = [editor.__gitTimeMachine.sourceEditor, editor.__gitTimeMachine.leftRevEditor]
    sourceEditor.__gitTimeMachine = null
    revEditor.__gitTimeMachine = null
    if sourceEditor == editor
      revEditor.destroy()
    
    if @editor in [sourceEditor, revEditor]
      @editor = null 
    else
      if @editor.__gitTimeMachine?
        [sourceEditor, revEditor] = [@editor.__gitTimeMachine.sourceEditor, @editor.__gitTimeMachine.leftRevEditor]
        GitRevisionView.splitDiff(sourceEditor, revEditor)
        GitRevisionView.syncScroll(sourceEditor, revEditor)
      

    
  # search the pane left of the curent editor for a time machine rev editor
  activateTimeMachineEditorForEditor: (editor=@editor) ->
    # null unless in a Time Machine - ... tab
    returnEditor = null
    fileName = editor.getPath?()
    tmRevFileName = editor.__gitTimeMachine?.sourceEditor?.getPath()
    
    return null if !(fileName? || tmRevFileName?) || !editor.__gitTimeMachine?
    
    sourceEditor = editor.__gitTimeMachine.sourceEditor
    leftRevEditor = editor.__gitTimeMachine.leftRevEditor
    
    leftRevPane = GitRevisionView.findEditorPane(leftRevEditor)[0]
    leftRevPane?.activateItem(leftRevEditor)
    sourcePane = GitRevisionView.findEditorPane(sourceEditor)[0]
    sourcePane?.activateItem(sourceEditor)
    
    otherEditor = if sourceEditor == editor then leftRevEditor else sourceEditor
      
    return otherEditor
      

  _bindWindowEvents: () ->
    $(window).on 'resize', @_onEditorResize 
    
    
  _unbindWindowEvents: () ->
    $(window).off 'resize', @_onEditorResize


  _renderPlaceholder: () ->
    @$element.html("<div class='placeholder'>Select a file in the git repo to see timeline</div>")
    return


  _renderCloseHandle: () ->
    $closeHandle = $("<div class='close-handle'>X</div>")
    @$element.append $closeHandle
    $closeHandle.on 'mousedown', (e)->
      e.preventDefault()
      e.stopImmediatePropagation()
      e.stopPropagation()
      # why not? instead of adding callback, our own event...
      atom.commands.dispatch(atom.views.getView(atom.workspace), "git-time-machine:toggle")


  _renderTimeplot: (commits) ->
    @timeplot ||= new GitTimeplot(@$element)
    @timeplot.render(@editor, commits, @_onViewRevision)
    return


  _renderStats: (commits) ->
    content = ""
    if commits.length > 0
      byAuthor = _.indexBy commits, 'authorName'
      authorCount = _.keys(byAuthor).length
      durationInMs = moment.unix(commits[commits.length - 1].authorDate).diff(moment.unix(commits[0].authorDate))
      timeSpan = moment.duration(durationInMs).humanize()
      content = "<span class='total-commits'>#{commits.length}</span> commits by #{authorCount} authors spanning #{timeSpan}"
    @$element.append """
      <div class='stats'>
        #{content}
      </div>
    """
    return

  
  _onViewRevision: (@leftRevHash, reverse) =>
    GitRevisionView.showRevision(@editor, @leftRevHash, {reverse: reverse})
    
    
      
  _onEditorResize: =>
    @render()
    