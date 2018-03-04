moment = require 'moment'
{$, View} = require "atom-space-pen-views"

module.exports = class GitTimeplotPopup extends View

  @content = (commitData, start, end) ->
    dateFormat = "MMM DD YYYY ha"
    commitVerb = if commitData.length > 0 then "were" else "was"
    commitSuffix = if commitData.length > 0 then "s" else ""
    @div class: "select-list popover-list git-timemachine-popup", =>
      @div class: 'rev-scroller', =>
        @h5 "There #{commitVerb} #{commitData.length} commit#{commitSuffix} between"
        @h6 "#{start.format(dateFormat)} and #{end.format(dateFormat)}"
        @ul =>
          for commit in commitData
            authorDate = moment.unix(commit.authorDate)
            linesAdded = commit.linesAdded || 0
            linesDeleted = commit.linesDeleted || 0
            @li "data-rev": commit.id, click: '_onRevisionClick', =>
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
      @div class: 'helper-text', =>
        @div class: 'click-help', =>
          @b "click"
          @span " to select left revision"
        
        @div class: 'shift-click-help', =>
          @b "shift+click"
          @span " to select right revision"
        

  initialize: (commitData, start, end, @onViewRevision) ->
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


  _onRevisionClick: (evt) =>
    revHash = $(evt.target).closest('li').data('rev')
    @onViewRevision(revHash, evt.shiftKey)
