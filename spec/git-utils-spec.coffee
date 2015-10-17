
GitUtils = require '../lib/git-utils'
fs = require 'fs'
path = require 'path'

expectedCommits = require './test-data/fiveCommitsExpected'



describe "GitUtils", ->
  describe "when loading file history for known file in git", ->
    beforeEach ->
      projectRoot = __dirname
      testFileName = path.join projectRoot, 'test-data', 'fiveCommits.txt'
      @testdata = null

      GitUtils.getFileCommitHistory testFileName, (commits) =>
        @testdata = commits
        return

      waitsFor =>
        return @testdata?

    it "should have 5 commits", ->
      expect(@testdata.length).toEqual(5)

    it "first 5 commits should match last known good", ->
      for knownCommit, index in expectedCommits
        actualCommit = @testdata[index]
        for key, value of knownCommit
          expect(actualCommit[key]).toEqual(value)
