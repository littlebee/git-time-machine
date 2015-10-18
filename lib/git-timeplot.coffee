
$ = jQuery = require 'jquery'
_ = require 'underscore-plus'
moment = require 'moment'
d3 = require 'd3'

GitTimeplotPopup = require './git-timeplot-popup'



module.exports = class GitTimeplot

  constructor: (@element) ->
    @$element = $(@element)
    @_debouncedRenderPopup = _.debounce(@_renderPopup, 50)
    @_debouncedHidePopup = _.debounce(@_hidePopup, 50)


  hide: () ->
    @popup?.remove()


  show: () ->
    #  nothing to do here


  # @commitData - array of javascript objects like those returned by GitUtils.getFileCommitHistory
  render: (@commitData) ->
    @popup?.remove()

    @$timeplot = @$element.find('.timeplot')
    if @$timeplot.length <= 0
      @$timeplot = $("<div class='timeplot'>")
      @$element.append @$timeplot

    if @commitData.length <= 0
      @$timeplot.html("<div class='placeholder'>No commits, nothing to see here.</div>")
      return;

    svg = d3.select(@$timeplot.get(0))
    .append("svg")
    .attr("width", @$element.width())
    .attr("height", 100)

    @_renderAxis(svg)
    @_renderBlobs(svg)

    @_renderHoverMarker()

    return @$timeplot;


  _renderAxis: (svg) ->
    w = @$element.width()
    h = 100
    left_pad = 20
    pad = 20
    minDate = moment.unix(@commitData[@commitData.length-1].authorDate).toDate()
    maxDate = moment.unix(@commitData[0].authorDate).toDate()
    minHour = d3.min(@commitData.map((d)->moment.unix(d.authorDate).hour()))
    maxHour = d3.max(@commitData.map((d)->moment.unix(d.authorDate).hour()))

    @x = d3.time.scale().domain([minDate, maxDate]).range([left_pad, w-pad])
    @y = d3.scale.linear().domain([minHour, maxHour]).range([10, h-pad*2])

    xAxis = d3.svg.axis().scale(@x).orient("bottom")
    yAxis = d3.svg.axis().scale(@y).orient("left").ticks(0)

    svg.append("g")
    .attr("class", "axis")
    .attr("transform", "translate(0, #{h-pad})")
    .call(xAxis);

    svg.append("g")
    .attr("class", "axis")
    .attr("transform", "translate(#{left_pad-pad}, 0)")
    .call(yAxis);


  _renderBlobs: (svg) ->
    max_r = d3.max(@commitData.map((d)->return d.linesAdded + d.linesDeleted))
    r = d3.scale.linear()
    .domain([0, max_r])
    .range([3, 15])

    svg.selectAll("circle")
    .data(@commitData)
    .enter()
    .append("circle")
    .attr("class", "circle")
    .attr("cx", (d)=> @x(moment.unix(d.authorDate).toDate()))
    .attr("cy", (d)=> @y(moment.unix(d.authorDate).hour()))
    .transition()
    .duration(500)
    .attr("r", (d) -> r(d.linesAdded + d.linesDeleted))


  # hover marker is the green vertical line that follows the mouse on the timeplot
  _renderHoverMarker: () ->
    @$hoverMarker = @$element.find('.hover-marker')
    unless @$hoverMarker.length > 0
      @$hoverMarker = $("<div class='hover-marker'>")
      @$element.append(@$hoverMarker)

    _this = @
    @$element.mouseenter (e) -> _this._onMouseenter(e)
    @$element.mousemove (e) -> _this._onMousemove(e)
    @$element.mouseleave (e) -> _this._onMouseleave(e)


  _onMouseenter: (evt) ->
    @isMouseInElement = true


  _onMousemove: (evt) ->
    relativeX = evt.clientX - @$element.offset().left
    if relativeX < @$hoverMarker.offset().left
      @$hoverMarker.css('left', relativeX)
    else
      @$hoverMarker.css('left', relativeX - @$hoverMarker.width())

    @_debouncedRenderPopup()

  _onMouseleave: (evt) ->
    @isMouseInElement = false
    # debouncing gives a little time to get the mouse into the popup
    @_debouncedHidePopup();


  _renderPopup: () ->
    # reposition the marker to match the position of the current popup
    if @popup?.isMouseInPopup()
      left = @popup.offset().left - @$element.offset().left
      if @_popupRightAligned
        left += (@popup.width() + 7)
      @$hoverMarker.css 'left': left
      return

    return unless @isMouseInElement

    @popup?.hide().remove()
    @popup = new GitTimeplotPopup(@commitData)

    left = @$hoverMarker.offset().left
    if left + @popup.outerWidth() + 10 > @$element.offset().left + @$element.width()
      @_popupRightAligned = true
      left -= (@popup.width() + 7)
    else
      @_popupRightAligned = false

    @popup.css
      left: left
      top: @$element.offset().top - @popup.height() - 10


  _hidePopup: () ->
    return if @popup?.isMouseInPopup() || @isMouseInElement
    @popup?.hide().remove()








  # why does atom keep removing extra lines at end of file?  super annoying
