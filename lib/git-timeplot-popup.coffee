moment = require 'moment'
{$, View} = require "atom-space-pen-views"

RevisionView = require './git-revision-view'


module.exports = class GitTimeplotPopup extends View

  @content = (commitData, editor, start, end) ->
    dateFormat = "MMM DD YYYY ha"
    @div class: "select-list popover-list git-timemachine-popup", =>
      @h5 "There were #{commitData.length} commits between"
      @h6 "#{start.format(dateFormat)} and #{end.format(dateFormat)}"
      @ul =>
        for commit in commitData
          authorDate = moment.unix(commit.authorDate)
          linesAdded = commit.linesAdded || 0
          linesDeleted = commit.linesDeleted || 0
          @li "data-rev": commit.hash, click: '_onShowRevision', =>
            @div class: "commit", =>
              @div class: "header", =>
                @div "#{authorDate.format(dateFormat)}"
                @div "#{commit.hash}"
                @div =>
                  @span class: 'added-count', "+#{linesAdded} "
                  @span class: 'removed-count', "-#{linesDeleted} "

              @div =>
                @strong "#{commit.message}"

              @div "Authored by #{commit.authorName} #{authorDate.fromNow()}"


  initialize: (commitData, @editor) ->
    @file = @editor.getPath()
    @appendTo atom.views.getView atom.workspace
    @mouseenter @_onMouseEnter
    @mouseleave @_onMouseLeave

    
  hide: () =>
    @_mouseInPopup = false
    super


  remove: () =>
    unless @_mouseInPopup
      super


  isMouseInPopup: () =>
    return @_mouseInPopup == true


  _onMouseEnter: (evt) =>
    # console.log 'mouse in popup'
    @_mouseInPopup = true
    return


  _onMouseLeave: (evt) =>
    @hide()
    return


  _onShowRevision: (evt) =>
    revHash = $(evt.target).closest('li').data('rev')
    RevisionView.showRevision(@editor, revHash)

