
{$} = require "atom-space-pen-views"
_ = require 'underscore-plus'
moment = require 'moment'

GitRevSelectorPopup = require './git-revselector-popup'


module.exports = class GitRevSelector

  constructor: (leftOrRight, commit, @onPreviousRevision, @onNextRevision) ->
    $splitdiffElement = $(".tool-panel .split-diff-ui .mid")
    $splitdiffElement.find(".timemachine-rev-select.#{leftOrRight}-rev").remove()
    
    @$element = $("<div class='timemachine-rev-select #{leftOrRight}-rev'>")
    
    if leftOrRight == 'left'
      $splitdiffElement.prepend @$element
    else
      $splitdiffElement.append @$element
    
    if commit?
      @revPopup = new GitRevSelectorPopup(commit, leftOrRight, @$element)

    @render(leftOrRight, commit)
    

  render:  (leftOrRight, commit) ->
    @$element.text('')
    
    dateFormat = "MMM DD YYYY ha"
    commitLabel = ""
    if commit?
      # commitLabel = "#{commitDate} #{revHash}"  #takes up too much space with revHash
      commitLabel = moment.unix(commit.authorDate).format(dateFormat)

    return if commit == undefined
    else if commit == null
      @_renderLeftButton() 
      @_renderVersionLabel("Local Version")
      @_renderRightButton(disabled: true)
    else
      @_renderLeftButton()
      @_renderVersionLabel(commitLabel)
      @_renderRightButton()

  
  destroy: () ->
    @$element.remove()
    @revPopup?.remove()
    
  
  _renderLeftButton: (options={}) ->
    options = _.defaults options,
      click: @_onPreviousRevClick
    
    @_renderButton " < ", options
        
      
  _renderRightButton: (options={}) ->
    options = _.defaults options,
      click: @_onNextRevClick
    
    @_renderButton " > ", options
    

  _renderButton: (text, options={}) ->
    options = _.defaults options,
      class: 'btn btn-small'
      click: null
      disabled: false
    
    $button = $("<button class='#{options.class}'>#{text}</button>") 
    $button.attr('disabled', options.disabled)
    if options.click?
      $button.on 'click.gtmRevSelector', options.click
    
    @$element.append $button


  _renderVersionLabel: (label) ->
    @$element.append $("<span>#{label}</span>")


  _onPreviousRevClick: =>
    @onPreviousRevision?.apply(@, arguments)
    
  
  _onNextRevClick: =>
    @onNextRevision?.apply(@, arguments)
    
    