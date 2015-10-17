
{BufferedProcess} = require "atom"
_ = require('underscore-plus');
path = require "path"
fs = require "fs"

GitUtils = exports



# returns an array of javascript objects representing the commits that effected the requested file
# with line stats
GitUtils.getFileCommitHistory = (fileName, callback)->
  logItems = []
  lastCommitObj = null
  stdout = (output) -> lastCommitObj = GitUtils._parseGitLogOutput(output, lastCommitObj, logItems)
  exit = (code) -> GitUtils._onFinishedParse(code, logItems, callback)
  return GitUtils._fetchFileHistory(fileName, stdout, exit)


# Implementation

GitUtils._parseGitLogOutput = (output, lastCommitObj, logItems) ->
  logLines = output.split("\n")
  for line in logLines
    if line[0] == '{'
      lastCommitObj = JSON.parse(line)
      logItems.push lastCommitObj
    else if lastCommitObj? && (matches = line.match(/^(\d+)\s*(\d+).*/))
      # git log --num-stat appends line stats on separate line
      lastCommitObj.linesAdded = Number.parseInt(matches[1])
      lastCommitObj.linesDeleted = Number.parseInt(matches[2])
  return lastCommitObj


GitUtils._onFinishedParse = (code, logItems, callback) ->
  if code is 0 and logItems.length isnt 0
    callback logItems
  else
    callback []
  return


GitUtils._fetchFileHistory = (fileName, stdout, exit) ->
  format = """{"id": "%H", "authorName": "%an", "relativeDate": "%cr", "authorDate": %at, """ +
    """ "message": "%s", "body": "%b", "hash": "%h"}"""

  return new BufferedProcess {
    command: "git",
    args: [
      "-C",
      path.dirname(fileName),
      "log",
      "--pretty=format:#{format}",
      "--topo-order",
      "--date=local",
      "--numstat"
      fileName
    ],
    stdout,
    exit
  }
