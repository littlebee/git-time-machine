{$, View} = require "atom-space-pen-views"
moment = require 'moment'
_ = require 'underscore-plus'


module.exports = class GitRevSelectorPopup extends View

  @content = (commit, leftOrRight, $hoverElement) ->
    dateFormat = "MMM DD YYYY ha"
    @div class: "select-list popover-list git-timemachine-revselector-popup", =>
      authorDate = moment.unix(commit.authorDate)
      linesAdded = commit.linesAdded || 0
      linesDeleted = commit.linesDeleted || 0
      @div "data-rev": commit.id, =>
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


  initialize: (commit, @leftOrRight, @$hoverElement) ->
    # allows time to get mouse in popup
    @_debouncedHide ?= _.debounce @hide, 50 
    
    @appendTo atom.views.getView atom.workspace
    @_bindMouseEvents()
    @show()
    _.delay @hide, 5000
    
    
  _bindMouseEvents: ->
    @mouseenter @_onMouseEnterPopup
    @mouseleave @_onMouseLeavePopup
    @$hoverElement.mouseenter @_onMouseEnterHoverElement
    @$hoverElement.mouseleave @_onMouseLeaveHoverElement

    
  hide: () =>
    unless @_mouseInPopup || @_mouseInHoverElement
      super
      
    return @


  show: () =>
    super
    _.defer => @_positionPopup()
      
    return @


  remove: () =>
    super


  isMouseInPopup: () =>
    return @_mouseInPopup == true


  _positionPopup: ->
    clientRect = @$hoverElement.offset()
    if @leftOrRight == 'left'
      left = clientRect.left + @$hoverElement.width() - @width()
    else
      left = clientRect.left
    top = clientRect.top - @height() - 18
    @css({top: top, left: left})


  _onMouseEnterPopup: (evt) =>
    @_mouseInPopup = true
    return


  _onMouseLeavePopup: (evt) =>
    @_mouseInPopup = false
    @_debouncedHide()
    return
    
    
  _onMouseEnterHoverElement: (evt) =>
    @_mouseInHoverElement = true
    @show()
    

  _onMouseLeaveHoverElement: (evt) =>
    @_mouseInHoverElement = false
    @_debouncedHide()


