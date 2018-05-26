
{$, View} = require "atom-space-pen-views"
_ = require 'underscore-plus'

module.exports = class GitTimeplot
  className: 'gtm-hz-scroller'

  constructor: (@$parentElement)->
    @_debouncedOnScroll = _.debounce @_onScroll, 100
    
    @$element = @$parentElement.find(".#{@className}")
    unless @$element?.length > 0
      @$element = $("<div class='#{@className}'>")
      @$parentElement.append @$element
      @$element.on 'scroll.gtmHzScroller', @_debouncedOnScroll


  render: ->
    @_toggleTouchAreas()
    return @$element


  _onScroll: =>
    @_toggleTouchAreas()


  _toggleTouchAreas: ->
    @_toggleLeftTouchArea()
    @_toggleRightTouchArea()


  _toggleLeftTouchArea: ->
    $leftTouchArea = @$element.find('.gtm-left-touch-area')
    unless $leftTouchArea.length > 0
      $leftTouchArea = $('<div class="gtm-left-touch-area">')
      @$element.prepend($leftTouchArea)
    scrollLeft = @$element.scrollLeft()
    if scrollLeft == 0
      $leftTouchArea.hide()
    else
      $leftTouchArea.css({left: scrollLeft})
      $leftTouchArea.show()


  _toggleRightTouchArea: ->
    $rightTouchArea = @$element.find('.gtm-right-touch-area')
    unless $rightTouchArea.length > 0
      $rightTouchArea = $('<div class="gtm-right-touch-area">')
      @$element.append($rightTouchArea)
    
    relativeRight = @$element.scrollLeft() + @$element.width()
    if relativeRight >= @_getChildWidth() - 10
      $rightTouchArea.hide()
    else
      $rightTouchArea.show()
      $rightTouchArea.css({left: relativeRight - 20})


  _getChildWidth: ->
    @$element.find('.timeplot').outerWidth(true)
    



