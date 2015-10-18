{$, View} = require "atom-space-pen-views"

module.exports = class GitTimeplotPopup extends View

  @content = (commitData) ->
    @div class: "select-list popover-list git-timemachine-popup", =>
      @ul class: "list-group", =>
          for commit in commitData
              @li =>
                @div class: "commit", =>
                  @text "this is commit #{commit.id}"


  initialize: (commitData) ->
    @appendTo atom.views.getView atom.workspace
    @mouseenter @_onMouseEnter
    @mouseleave @_onMouseLeave


  isMouseInPopup: () =>
    return @_mouseInPopup == true

  _onMouseEnter: (evt) =>
    console.log 'mouse in popup'
    @_mouseInPopup = true
    return

  _onMouseLeave: (evt) =>
    console.log 'mouse leave popup'
    @_mouseInPopup = false
    @hide()
    return
