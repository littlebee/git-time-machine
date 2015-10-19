
{$, View} = require "atom-space-pen-views"

GitTimeMachineView = require '../lib/git-time-machine-view'
GitUtils = require '../lib/git-utils'


describe "GitTimeMachineView", ->

  describe "when open", ->
    [workspaceElement, activationPromise, timeMachineElement] = []

    beforeEach ->
      workspaceElement = atom.views.getView(atom.workspace)
      activationPromise = atom.packages.activatePackage('git-time-machine')
      atom.commands.dispatch workspaceElement, 'git-time-machine:open'
      waitsForPromise ->
        activationPromise
      runs ->
        timeMachineElement = workspaceElement.querySelector('.git-time-machine')

    it "should show placeholder when no file in editor", ->
      expect(timeMachineElement.querySelector('.placeholder')).toExist()
      return


    describe "after opening a known file", ->
      beforeEach ->
        spyOn(GitUtils, '_onFinishedParse').andCallThrough()
        openPromise = atom.workspace.open('test-data/fiveCommits.txt')
        waitsForPromise ->
          return openPromise
        waitsFor ->
          GitUtils._onFinishedParse.calls.length > 0
        runs ->
          timeMachineElement = workspaceElement.querySelector('.git-time-machine')
          return

      it "should not be showing placeholder", ->
        expect(timeMachineElement.querySelector('.placeholder')).not.toExist()

      it "should be showing timeline", ->
        expect(timeMachineElement.querySelector('.timeline')).toExist()

      it "total-commits should be five", ->
        totalCommits = $(timeMachineElement).find('.total-commits').text()
        expect(totalCommits).toEqual("5")
