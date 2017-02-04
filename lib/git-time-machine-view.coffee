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
    return if !editor? || editor == @lastActivatedEditor || GitRevisionView.isActivating 
      
    file = editor.getPath()
    return unless file?
    
    @lastActivatedEditor = editor
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


  gitCommitHistory: (editor=@lastActivatedEditor)->
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


  loadExistingRevForEditor: (editor=@lastActivatedEditor) ->
    return unless editor.__gitTimeMachine?
    
    _.defer =>
      return unless editor.__gitTimeMachine?
      sourceEditor = editor.__gitTimeMachine.sourceEditor
      
      @activateTimeMachineEditorForEditor(sourceEditor) unless editor.isDestroyed()
      
      leftEditor = sourceEditor.__gitTimeMachine.leftRevEditor 
      rightEditor = sourceEditor.__gitTimeMachine.rightRevEditor 
      GitRevisionView.splitDiff(leftEditor, rightEditor)
      GitRevisionView.syncScroll(leftEditor, rightEditor)
    
    
  destroyEditor: (editor=@lastActivatedEditor) ->
    return unless editor.__gitTimeMachine?
    sourceEditor = editor.__gitTimeMachine.sourceEditor
    
    if editor == sourceEditor
      leftRevEditor = sourceEditor.__gitTimeMachine.leftRevEditor
      rightRevEditor = sourceEditor.__gitTimeMachine.rightRevEditor
      
      revEditors = _.filter [leftRevEditor, rightRevEditor], (e) -> 
        e != sourceEditor && !e.isDestroyed()
        
      revEditor.destroy() for revEditor in revEditors

    
  # editor should be the source editor
  activateTimeMachineEditorForEditor: (sourceEditor) ->
    return unless sourceEditor.__gitTimeMachine?
    
    leftRevEditor = sourceEditor.__gitTimeMachine.leftRevEditor
    leftRevPane = GitRevisionView.findEditorPane(leftRevEditor)[0]
    leftRevPane?.activateItem(leftRevEditor) unless leftRevEditor == @lastActivatedEditor
    
    rightRevEditor = sourceEditor.__gitTimeMachine.rightRevEditor
    # the rightRevPane should always be the same pane as the source editor pane
    rightRevPane = GitRevisionView.findEditorPane(sourceEditor)[0]
    rightRevPane?.activateItem(rightRevEditor) unless rightRevEditor == @lastActivatedEditor


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
    @timeplot.render(commits, @_onViewRevision)
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

  
  _onViewRevision: (revHash, reverse) =>
    [leftRevHash, rightRevHash] = if reverse
      [@leftRevHash, revHash]
    else
      [revHash, @rightRevHash]
    
    # order by created asc
    [@leftRevHash, @rightRevHash] = @_orderRevHashes(leftRevHash, rightRevHash)
    
    GitRevisionView.showRevision(@lastActivatedEditor, @leftRevHash, @rightRevHash)
    @timeplot.setRevisions(@leftRevHash, @rightRevHash)
    
    
      
  _onEditorResize: =>
    @render()
    
    
  _orderRevHashes: (revHashA, revHashB) ->
    unorderedRevs = [revHashA, revHashB]
    return unorderedRevs unless @commits?.length > 0
    
    orderedRevs = []
    for rev in @commits
      if rev.id in unorderedRevs || rev.hash in unorderedRevs
        orderedRevs.push rev.hash
        break if orderedRevs.length >= 2
        
    return orderedRevs.reverse()    
    
      
  