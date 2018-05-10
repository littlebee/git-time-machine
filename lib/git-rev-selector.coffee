
{$, View} = require "atom-space-pen-views"
_ = require 'underscore-plus'
moment = require 'moment'

GitRevSelectorPopup = require './git-revselector-popup'


module.exports = class GitRevSelector extends View

  @content = (leftOrRight, commit) ->
    dateFormat = "MMM DD YYYY ha"
    commitLabel = ""
    
    if commit?
      # commitLabel = "#{commitDate} #{revHash}"  #takes up too much space with revHash
      commitLabel = moment.unix(commit.authorDate).format(dateFormat)

    @div class: "timemachine-rev-select #{leftOrRight}-rev", =>
      if commit == undefined 
        return ""
      else if commit == null
        @leftButton() 
        @span "Local Version"
        @rightButton disabled: true
      else
        @leftButton()
        @span commitLabel
        @rightButton()

  
  @leftButton: (options={}) ->
    options = _.defaults options,
      click: '_onPreviousRevClick'
    
    @button " < ", options
        
      
  @rightButton: (options={}) ->
    options = _.defaults options,
      click: '_onNextRevClick'
    
    @button " > ", options
    

  @button: (text, options) ->
    options = _.defaults options,
      class: 'btn btn-small'
    
    @tag 'button', text, options

      
  initialize: (leftOrRight, commit, @onPreviousRevision, @onNextRevision) ->
    $splitdiffElement = $(".tool-panel .split-diff-ui .mid")
    $splitdiffElement.find(".timemachine-rev-select.#{leftOrRight}-rev").remove()
    if leftOrRight == 'left'
      $splitdiffElement.prepend @
    else
      $splitdiffElement.append @
    
    @revPopup?.hide().remove()
    if commit?
      @revPopup = new GitRevSelectorPopup(commit, leftOrRight, @)


  detached: ->
    @revPopup?.remove()


  _onPreviousRevClick: ->
    @onPreviousRevision?.apply(@, arguments)
    
  
  _onNextRevClick: ->
    @onNextRevision?.apply(@, arguments)