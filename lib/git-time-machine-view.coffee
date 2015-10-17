$ = jQuery = require('jquery')
_ = require('underscore-plus')

GitUtils = require './git-utils'

module.exports =
class GitTimeMachineView
  constructor: (serializedState, options={}) ->
    @render(options.file)


  setFile: (file) ->
    render(file)


  render: (@file) ->
    @$element = $("<div class='git-time-machine'>") unless @$element
    unless @file?
      @_renderPlaceholder()
    else
      @_renderTimeline()

    return @$element


  # Returns an object that can be retrieved when package is activated
  serialize: ->


  # Tear down any state and detach
  destroy: ->
    @$element.remove()


  getElement: ->
    @$element.get(0)


  _renderPlaceholder: () ->
    @$element.html("<div class='placeholder'>Select a file in the git repo to see timeline</div>")


  _renderTimeline: () ->
      GitUtils.getFileCommitHistory @file, (commits) =>
        @$element.html("<div class='git-time-machine'>this is where the timeline goes.  there have been #{commits.length} commits to this file</div>")
