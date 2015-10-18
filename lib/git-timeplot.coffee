
$ = jQuery = require 'jquery'
_ = require 'underscore-plus'
moment = require 'moment'
d3 = require 'd3'

module.exports = class GitTimeplot

  constructor: (@element) ->
    @$element = $(@element)


  # commitData - array of javascript objects like those returned by GitUtils.getFileCommitHistory
  render: (commitData) ->
    @$timeplot = @$element.find('.timeplot')
    if @$timeplot.length <= 0
      @$timeplot = $("<div class='timeplot'>")
      @$element.append @$timeplot

    if commitData.length <= 0
      @$timeplot.html("<div class='placeholder'>No commits, nothing to see here.</div>")
      return;

    svg = d3.select(@$timeplot.get(0))
    .append("svg")
    .attr("width", @$element.width())
    .attr("height", 100)

    @_renderAxis(svg, commitData)
    @_renderBlobs(svg, commitData)
    @_renderHoverMarker(svg, commitData)

    return @$timeplot;


  _renderAxis: (svg, commitData) ->
    w = @$element.width()
    h = 100
    left_pad = 20
    pad = 20
    minDate = moment.unix(commitData[commitData.length-1].authorDate).toDate()
    maxDate = moment.unix(commitData[0].authorDate).toDate()
    minHour = d3.min(commitData.map((d)->moment.unix(d.authorDate).hour()))
    maxHour = d3.max(commitData.map((d)->moment.unix(d.authorDate).hour()))

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


  _renderBlobs: (svg, commitData) ->
    max_r = d3.max(commitData.map((d)->return d.linesAdded + d.linesDeleted))
    r = d3.scale.linear()
    .domain([0, max_r])
    .range([3, 15])

    svg.selectAll("circle")
    .data(commitData)
    .enter()
    .append("circle")
    .attr("class", "circle")
    .attr("cx", (d)=> @x(moment.unix(d.authorDate).toDate()))
    .attr("cy", (d)=> @y(moment.unix(d.authorDate).hour()))
    .transition()
    .duration(500)
    .attr("r", (d) -> r(d.linesAdded + d.linesDeleted))


  # hover marker is the green vertical line that follows the mouse on the timeplot
  _renderHoverMarker: (svg, commitData) ->
    @$hoverMarker = @$element.find('.hover-marker')
    unless @$hoverMarker.length > 0
      @$hoverMarker = $("<div class='hover-marker'>")
      @$element.append(@$hoverMarker)

    _this = @
    @$element.mousemove (e) -> _this._onHoverMarkerMousemove(e)


  _onHoverMarkerMousemove: (evt) ->
    relativeX = evt.clientX - @$element.offset().left
    if relativeX < @$hoverMarker.offset().left
      @$hoverMarker.css('left', relativeX)
    else
      @$hoverMarker.css('left', relativeX - @$hoverMarker.width())




  # why does atom keep removing extra lines at end of file?  super annoying
