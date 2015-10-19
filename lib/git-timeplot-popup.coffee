{$, View} = require "atom-space-pen-views"
moment = require 'moment'

module.exports = class GitTimeplotPopup extends View

  @content = (commitData, start, end) ->
    dateFormat = "MMM DD YYYY ha"
    @div class: "select-list popover-list git-timemachine-popup", =>
      @h5 "There were #{commitData.length} commits between"
      @h6 "#{start.format(dateFormat)} and #{end.format(dateFormat)}"
      @ul class: "list-group", =>
          for commit in commitData
              @li =>
                @div class: "commit", =>
                  @span "#{commit.hash} - "
                  @strong "#{commit.message}"
                  @div "Authored by #{commit.authorName} #{moment.unix(commit.authorDate).fromNow()}"


  initialize: (commitData) ->
    @appendTo atom.views.getView atom.workspace
    @mouseenter @_onMouseEnter
    @mouseleave @_onMouseLeave


  isMouseInPopup: () =>
    return @_mouseInPopup == true


  _onMouseEnter: (evt) =>
    # console.log 'mouse in popup'
    @_mouseInPopup = true
    return


  _onMouseLeave: (evt) =>
    # console.log 'mouse leave popup'
    @_mouseInPopup = false
    @hide()
    return
