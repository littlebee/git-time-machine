
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
      @$element.on 'scroll.gtmHzScroller', @_onScroll



  render: (@initialScrollLeft=0) ->
    @_toggleTouchAreas()
    @$element.scrollLeft(@initialScrollLeft)
    return @$element


  scrollFarRight: () ->
    @$element.scrollLeft(@_getChildWidth() - @$element.width())


  scrollFarLeft: () ->
    @$element.scrollLeft(0)


  getScrollLeft: () ->
    return @$element.scrollLeft()


  getScrollRight: () ->
    return @$element.scrollLeft() + @$element.width()


  _onScroll: =>
    @_toggleTouchAreas()
    
    
  _onTouchClick: (which) =>
    switch(which)
     when "left" then @scrollFarLeft()
     when "right" then @scrollFarRight()


  _toggleTouchAreas: ->
    @_toggleTouchArea('left')
    @_toggleTouchArea('right')


  _toggleTouchArea: (which)->
    $touchArea = @$element.find(".gtm-touch-area.gtm-#{which}")
    unless $touchArea.length > 0
      $touchArea = $("<div class='gtm-touch-area gtm-#{which}'>")
      $touchArea.on "click.gtmTouchArea", => @_onTouchClick(which)
      @$element.prepend($touchArea)
    
    scrollLeft = @getScrollLeft()
    relativeRight = @getScrollRight()
    
    {shouldHide, areaLeft} = switch which
      when 'left'
        shouldHide: scrollLeft == 0
        areaLeft: scrollLeft
      when 'right'
        shouldHide: relativeRight >= @_getChildWidth() - 10
        areaLeft: relativeRight - 20
    
    if shouldHide
      $touchArea.hide()
    else
      $touchArea.css({left: areaLeft})
      $touchArea.show()


  _getChildWidth: ->
    @$element.find('.timeplot').outerWidth(true)
    



