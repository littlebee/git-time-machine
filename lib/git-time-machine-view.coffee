{$, View} = require "atom-space-pen-views"
path = require('path')
_ = require('underscore-plus')
str = require('bumble-strings')
moment = require('moment')

nodegit = require('atom').GitRepositoryAsync.Git
GitLogUtils = require('libgit2-log-utils')
gitLogUtils = new GitLogUtils(nodegit)

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


  setEditor: (editor) ->
    return unless editor != @editor
    file = editor?.getPath()
    return unless file? && !str.startsWith(path.basename(file), GitRevisionView.FILE_PREFIX)
    [@editor, @file] = [editor, file]
    @render()


  render: () ->
    gitLogUtils.getCommitHistory(@file)
    .then (commits) =>
      unless @file? && commits?.length > 0
        @_renderPlaceholder()
      else
        @_renderPanel(commits)

    .catch (error) ->
      if error.weaklyHas(error, NOT_GIT_ERRORS)
        console.warn "#{file} not in a git repository"
      else
        throw error

    return @$element

  _renderPanel: (commits) ->
    @$element.text("")
    @_renderCloseHandle()
    @_renderStats(commits)
    @_renderTimeline(commits)

  # Returns an object that can be retrieved when package is activated
  serialize: ->
    return null


  # Tear down any state and detach
  destroy: ->
    return @$element.remove()


  hide: ->
    @timeplot?.hide()   # so it knows to hide the popup


  show: ->
    @timeplot?.show()


  getElement: ->
    return @$element.get(0)


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



  _renderTimeline: (commits) ->
    @timeplot ||= new GitTimeplot(@$element)
    @timeplot.render(@editor, commits)
    return


  _renderStats: (commits) ->
    content = ""
    if commits.length > 0
      byAuthor = _.indexBy commits, 'author'
      authorCount = _.keys(byAuthor).length
      durationInMs = moment(commits[commits.length - 1].authorDate).diff(moment(commits[0].authorDate))
      timeSpan = moment.duration(durationInMs).humanize()
      content = "<span class='total-commits'>#{commits.length}</span> commits by #{authorCount} authors spanning #{timeSpan}"
    @$element.append """
      <div class='stats'>
        #{content}
      </div>
    """
    return
