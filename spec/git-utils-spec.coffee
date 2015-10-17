
GitUtils = require '../lib/git-utils'
fs = require 'fs'
path = require 'path'

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
