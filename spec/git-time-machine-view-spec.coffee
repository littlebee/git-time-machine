
{$, View} = require "atom-space-pen-views"
Path = require 'path'

GitTimeMachineView = require '../lib/git-time-machine-view'


describe "GitTimeMachineView", ->

  describe "when open", ->
    [workspaceElement, activationPromise, timeMachineElement] = []

    beforeEach ->
      activationPromise = atom.packages.activatePackage('git-time-machine')
      workspaceElement = atom.views.getView(atom.workspace)
      atom.commands.dispatch workspaceElement, 'git-time-machine:toggle'
      waitsForPromise ->
        activationPromise
      runs ->
        timeMachineElement = workspaceElement.querySelector('.git-time-machine')
        # console.log timeMachineElement.outerHTML

    #it "should show placeholder when no file in editor", ->
    #  expect(timeMachineElement.querySelector('.placeholder')).toExist()
    #  return
    
    # current expected behavior is to not show time plot at all
    it "should not show timeplot if no file loaded", ->
      expect(timeMachineElement.innerHTML).toEqual ""

    describe "after opening a known file", ->
      beforeEach ->
        #console.log "current working directory: #{process.cwd()}"
        #console.log "current script directory: #{__dirname}"
        openPromise = atom.workspace.open("#{__dirname}/test-data/fiveCommits.txt")
        waitsForPromise ->
          return openPromise
        runs ->
          timeMachineElement = workspaceElement.querySelector('.git-time-machine')
          return

      it "should not be showing placeholder", ->
        expect(timeMachineElement.querySelector('.placeholder')).not.toExist()

      it "should be showing timeline", ->
        expect(timeMachineElement.querySelector('.timeplot')).toExist()

      it "total-commits should be five", ->
        totalCommits = $(timeMachineElement).find('.total-commits').text()
        expect(totalCommits).toEqual("5")
