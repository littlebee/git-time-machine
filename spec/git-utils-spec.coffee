
GitLog = require 'git-log-utils'
fs = require 'fs'
path = require 'path'

expectedCommits = require './test-data/fiveCommitsExpected'

describe "GitLogUtils", ->
  describe "when loading file history for known file in git", ->
    beforeEach ->
      @addMatchers toHaveKnownValues: (expected) ->
        pass = true
        messages = ""
        for key, value of expected
          matches = @actual[key] == value
          unless matches
            if pass
              messages += "Commit #{@actual.hash}: "
            else
              messages += "; "
            messages += "#{key} expected: #{value} actual: #{@actual[key]}"
            pass = false
        if pass
          @message = -> "Expected commit #{@actual.hash} to not equal #{JSON.stringify(@expected)}"
        else
          @message = -> messages
        return pass

      projectRoot = __dirname
      testFileName = path.join projectRoot, 'test-data', 'fiveCommits.txt'
      @testdata = GitLog.getCommitHistory testFileName


    it "should have 5 commits", ->
      expect(@testdata.length).toEqual(5)


    it "first 5 commits should match last known good", ->
      for expectedCommit, index in expectedCommits
        actualCommit = @testdata[index]
        expect(actualCommit).toHaveKnownValues(expectedCommit)
