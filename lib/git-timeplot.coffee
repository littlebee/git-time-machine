
{$, View} = require "atom-space-pen-views"
_ = require 'underscore-plus'
moment = require 'moment'
d3 = require 'd3'

GitTimeplotPopup = require './git-timeplot-popup'
GitRevSelector = require './git-rev-selector'


module.exports = class GitTimeplot

  constructor: (parentElement) ->
    @$parentElement = $(parentElement)
    @$closeHandle = @$parentElement.find(".close-handle")
    @_debouncedRenderPopup = _.debounce(@_renderPopup, 50)
    @_debouncedHidePopup = _.debounce(@_hidePopup, 50)
    @_debouncedViewNearestRevision = _.debounce(@_viewNearestRevision, 100)
    @leftRevHash = null  
    @rightRevHash = null


  hide: () ->
    @popup?.remove()


  show: () ->
    #  nothing to do here


  # @commitData - array of javascript objects like those returned by GitUtils.getFileCommitHistory
  #               should be in reverse chron order
  # @zoom - 1 to n zoom factor
  # @onViewRevision - callback method called when a revision is selected in the timeplot. Also passed
  #               to GitRevSelector.   Sould probably be a constructor argument
  render: (@commitData, @zoom, @onViewRevision) ->
    @popup?.remove()

    @$element = @$parentElement.find('.timeplot')
    if @$element.length <= 0
      @$element = $("<div class='timeplot'>")
      @$parentElement.append @$element

    if @commitData.length <= 0
      @$element.html("<div class='placeholder'>No commits, nothing to see here.</div>")
      return;
      
    @$element.width(@zoom * 100 + '%')

    svg = d3.select(@$element.get(0))
    .append("svg")
    .attr("width", @$element.width())
    .attr("height", 100)

    @_renderAxis(svg)
    @_renderBlobs(svg)

    @_renderHoverMarker()
    @_renderRevMarkers()
    @_renderRevSelectors()
    @_bindMouseEvents()

    return @$element;
    
  
  setRevisions: (@leftRevHash, @rightRevHash) ->
    # we don't want to show the left rev marker or rev selector at all until a left @leftRevHash is set
    @leftRevHash = undefined unless @leftRevHash?
    # we want to show right rev selector and marker for "Local Revision" when @rightRevHash is not set 
    @rightRevHash = null unless @rightRevHash?
    
    @_renderRevMarkers()
    @_renderRevSelectors()


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
    .attr("r", (d) -> r(d.linesAdded + d.linesDeleted || 0))


  # hover marker is the gray vertical line that follows the mouse on the timeplot
  _renderHoverMarker: () ->
    @$hoverMarker = @$element.find('.hover-marker')
    unless @$hoverMarker.length > 0
      @$hoverMarker = $("<div class='hover-marker'>")
      @$element.append(@$hoverMarker)


  _renderRevMarkers: () ->
    @_renderRevMarker('left')
    @_renderRevMarker('right')
    
    if @_leftRev 
      # we don't show the red marker until we have a left revision
      @$element.find('.left-rev-marker').show()
    
    
  # whichRev should be 'left' or 'right'
  _renderRevMarker: (whichRev) ->
    $revMarker = @$element.find(".#{whichRev}-rev-marker")
    unless $revMarker.length > 0
      $revMarker = $("<div class='#{whichRev}-rev-marker'>")
      @$element.append($revMarker)
    
    revHash = @["#{whichRev}RevHash"]
    commit = @_findCommit(revHash)
    
    return if commit == undefined
    
    unless commit?
      # console.log "resetting revMarker", whichRev, revHash, commit
      $revMarker.show().css({left: @$element.width() - 10})
      return
    
    # console.log "setting revMarker", whichRev, revHash, commit
    $revMarker.show().css 
      left: @x(moment.unix(commit.authorDate).toDate())
      right: 'initial'
    
    
  _renderRevSelectors: () ->
    # have to allow suffient time for splitdiff to render
    _.delay =>
      @_renderRevSelector('left')
      @_renderRevSelector('right')
    , 1000
  
  
  # renders the select components in the SplitDiff bottom control panel
  _renderRevSelector: (leftOrRight) ->
    revHash = @["#{leftOrRight}RevHash"]
    commit = @_findCommit(revHash)
    @["#{leftOrRight}RevSelector"]?.destroy()
    @["#{leftOrRight}RevSelector"] = new GitRevSelector leftOrRight, commit,
      => @_onRevSelectorNextPreviousRev(leftOrRight, -1),
      => @_onRevSelectorNextPreviousRev(leftOrRight, +1)
    
    
  _onRevSelectorNextPreviousRev: (leftOrRight, offset) =>
    currentRevHash = @["#{leftOrRight}RevHash"]
    adjacentRevHash = @_findAdjacentRevHash(currentRevHash, offset)
    @_onViewRevision(adjacentRevHash, leftOrRight == 'right')
    
    
  _bindMouseEvents: () =>
    _this = @
    @$element.mouseenter (e) -> _this._onMouseenter(e)
    @$element.mousemove (e) -> _this._onMousemove(e)
    @$element.mouseleave (e) -> _this._onMouseleave(e)
    @$element.mousedown (e) -> _this._onMousedown(e)
    @$element.mouseup (e) -> _this._onMouseup(e)
    @$closeHandle.mouseenter (e) -> _this._onCloseHandleMouseenter(e)
    @$closeHandle.mouseleave (e) -> _this._onCloseHandleMouseleave(e)

  _onCloseHandleMouseenter: (evt) ->
    @isMouseInCloseHandle = true

  _onCloseHandleMouseleave: (evt) ->
    @isMouseInCloseHandle = false

  _onMouseenter: (evt) ->
    @isMouseInElement = true


  _onMousemove: (evt) ->
    relativeX = evt.clientX - @$element.offset().left
    if relativeX < @$hoverMarker.offset().left
      @$hoverMarker.css('left', relativeX)
    else
      @$hoverMarker.css('left', relativeX - @$hoverMarker.width())

    if @isMouseInCloseHandle
      @_hidePopup(force: true)
    else if @isMouseDown
      @_hidePopup(force: true)
      @_debouncedViewNearestRevision(evt.shiftKey)
    else
      @_debouncedRenderPopup()


  _onMouseleave: (evt) ->
    @isMouseInElement = false
    # debouncing gives a little time to get the mouse into the popup
    @_debouncedHidePopup();
    @isMouseDown = false


  _onMousedown: (evt) ->
    @isMouseDown = true
    @_hidePopup(force: true)
    @_debouncedViewNearestRevision(evt.shiftKey)


  _onMouseup: (evt) ->
    @isMouseDown = false
    
    
  _onViewRevision: (revHash, reverse) =>
    # pass along up the component stack. note that we don't update @leftRevHash and @rightRevHash until
    # the container component calls setRevisions in response to this 
    @onViewRevision(revHash, reverse)


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
    [commits, start, end] = @_filterCommitData(@commitData)
    @popup = new GitTimeplotPopup(commits, start, end, @_onViewRevision)

    left = @$hoverMarker.offset().left
    if left + @popup.outerWidth() + 10 > @$element.offset().left + @$element.width()
      @_popupRightAligned = true
      left -= (@popup.width() + 7)
    else
      @_popupRightAligned = false

    @popup.css
      left: left
      top: @$element.offset().top - @popup.height() - 10


  _hidePopup: (options={}) ->
    options = _.defaults options,
      force: false

    return if !options.force && (@popup?.isMouseInPopup() || @isMouseInElement)
    @popup?.hide().remove()


  # return commits for range of time at hover marker (mouse hover point +/- fix radius)
  _filterCommitData: () ->
    left = @$hoverMarker.offset().left
    relativeLeft = left - @$element.offset().left - 5
    tStart = moment(@x.invert(relativeLeft)).startOf('hour').subtract(1, 'minute')
    tEnd = moment(@x.invert(relativeLeft + 10)).endOf('hour').add(1, 'minute')
    
    commits = _.filter @commitData, (c) -> moment.unix(c.authorDate).isBetween(tStart, tEnd)
    # console.log("gtm: inspecting #{commits.length} commits betwee #{tStart.toString()} - #{tEnd.toString()}")
    return [commits, tStart, tEnd];
    
  
  _findCommit: (revHash, otherOutput={}) ->
    unless revHash?
      return revHash # returns either null or undefined, whichever revHash is set to
    
    return _.find @commitData, (d, index) -> 
      otherOutput.index = index
      d.id == revHash || d.hash == revHash
    

  # return the nearest commit to hover marker or previous
  _getNearestCommit: () ->
    [filteredCommitData, tStart, tEnd] = @_filterCommitData()
    if filteredCommitData?.length > 0
      return filteredCommitData[0]
    else
      return _.find @commitData, (c) -> moment.unix(c.authorDate).isBefore(tEnd)


  _viewNearestRevision: (reverse) ->
    nearestCommit =  @_getNearestCommit()
    if nearestCommit?
      @_onViewRevision(nearestCommit.id, reverse)
      
  
  # offset is the chronological order, however commitData is in rev chron order
  _findAdjacentRevHash: (revHash, offset) ->
    findOutput = {}
    commit = @_findCommit(revHash, findOutput)
    unless commit? 
      index = if offset <= 0 then 0 else @commitData.length - 1 
      return @commitData[index].id
    
    # @commitData is in reverse chronological order 
    return @commitData[findOutput.index - offset]?.id

