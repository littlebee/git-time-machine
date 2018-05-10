{$, View} = require "atom-space-pen-views"
path = require('path')
_ = require('underscore-plus')
str = require('bumble-strings')
moment = require('moment')

GitLog = require 'git-log-utils'
GitTimeplot = require './git-timeplot'
GitRevisionView = require './git-revision-view'

NOT_GIT_ERRORS = ['File not a git repository', 'is outside repository', "Not a git repository"]

module.exports = class GitTimeMachineView
  constructor: (serializedState, options={}) ->
    @$element = $("<div class='git-time-machine'>") unless @$element
    if options.editor?
      @setEditor(options.editor)
      @render()

    @_bindWindowEvents()
    

  setEditor: (editor) ->
    return if !editor? || editor == @lastActivatedEditor || GitRevisionView.isActivating() 
      
    file = editor.getPath()
    return unless file?
    
    @lastActivatedEditor = editor
    @render()
    GitRevisionView.loadExistingRevForEditor(editor)


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
    return null unless editor?
    if editor.__gitTimeMachine?.sourceEditor?
      editor = editor.__gitTimeMachine.sourceEditor
    
    file = editor?.getPath()
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


  _bindWindowEvents: () ->
    $(window).on 'resize', @_onEditorResize


  _unbindWindowEvents: () ->
    $(window).off 'resize', @_onEditorResize


  _renderPlaceholder: () ->
    @$element.html("<div class='placeholder'>Select a file in the git repo to see timeline</div>")
    return


  _renderCloseHandle: () ->
    $closeHandle = $("<i class='close-handle icon icon-x clickable'></i>")
    @$element.append $closeHandle
    $closeHandle.on 'mousedown', (e)->
      e.preventDefault()
      e.stopImmediatePropagation()
      e.stopPropagation()
      # why not? instead of adding callback, our own event...
      atom.commands.dispatch(atom.views.getView(atom.workspace), "git-time-machine:toggle")
    atom.tooltips.add($closeHandle, { title: "Close Panel", delay: 0 })


  _renderTimeplot: (commits) ->
    @timeplot ||= new GitTimeplot(@$element)
    @timeplot.render(commits, @_onViewRevision)
    
    leftRevHash = null
    rightRevHash = null
    
    if @lastActivatedEditor.__gitTimeMachine?
      leftRevHash = @lastActivatedEditor.__gitTimeMachine.revisions?[0]?.revHash
      rightRevHash = @lastActivatedEditor.__gitTimeMachine.revisions?[1]?.revHash
    
    @timeplot.setRevisions(leftRevHash, rightRevHash)    
    
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
    leftRevHash = null
    rightRevHash = null
    
    if @lastActivatedEditor.__gitTimeMachine?
      leftRevHash = @lastActivatedEditor.__gitTimeMachine.revisions?[0]?.revHash ? null
      rightRevHash = @lastActivatedEditor.__gitTimeMachine.revisions?[1]?.revHash ? null
      
    if reverse
      rightRevHash = revHash
    else
      leftRevHash = revHash
    
    # order by created asc
    [leftRevHash, rightRevHash] = @_orderRevHashes(leftRevHash, rightRevHash)
    
    GitRevisionView.showRevision(@lastActivatedEditor, leftRevHash, rightRevHash, @_onRevisionClose)
    @timeplot.setRevisions(leftRevHash, rightRevHash)
    
    
      
  _onEditorResize: =>
    @render()
    
    
  _onRevisionClose: =>
    rightRevHash = leftRevHash = null
    @timeplot.setRevisions(leftRevHash, rightRevHash)
    
    
  _orderRevHashes: (revHashA, revHashB) ->
    unorderedRevs = [revHashA, revHashB]
    return unorderedRevs unless @commits?.length > 0
    
    orderedRevs = []
    for rev in @commits
      if rev.id in unorderedRevs || rev.hash in unorderedRevs
        orderedRevs.push rev.hash
        break if orderedRevs.length >= 2
        
    return orderedRevs.reverse()    
    
      
  
