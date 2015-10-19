{$, View} = require "atom-space-pen-views"
_ = require('underscore-plus')

GitUtils = require './git-utils'
GitTimeplot = require './git-timeplot'

module.exports =
class GitTimeMachineView
  constructor: (serializedState, options={}) ->
    @render(options.file)


  setFile: (file) ->
    @render(file)


  render: (@file) ->
    @$element = $("<div class='git-time-machine'>") unless @$element
    unless @file?
      @_renderPlaceholder()
    else
      @$element.text("")
      @_renderTimeline()

    return @$element


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

  _renderTimeline: () ->
    @timeplot ||= new GitTimeplot(@$element)
    GitUtils.getFileCommitHistory @file, (commits) =>
      @timeplot.render(commits)
      @_renderStats(commits)
      return
    return


  _renderStats: (commits) ->
    @$element.append """
      <div class='stats'>
        <span class='total-commits'>#{commits.length}</span> total commits
      </div>
    """
    return
