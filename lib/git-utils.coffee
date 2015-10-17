
{BufferedProcess} = require "atom"
_ = require('underscore-plus');
path = require "path"
fs = require "fs"

GitUtils = exports



# returns an array of javascript objects representing the commits that effected the requested file
# with line stats
GitUtils.getFileCommitHistory = (fileName, callback)->
  logItems = []
  commitObj = null

  stdout = (output) ->
    logLines = output.split("\n")
    for line in logLines
      if line[0] == '{'
        commitObj = JSON.parse(line)
        logItems.push commitObj
      else if commitObj? && (matches = line.match(/^(\d+)\s*(\d+).*/))
        # git log --num-stat appends line stats on separate line
        commitObj.linesAdded = Number.parseInt(matches[1])
        commitObj.linesDeleted = Number.parseInt(matches[2])
    return

  exit = (code) =>
    if code is 0 and logItems.length isnt 0
      callback logItems
    else
      callback []
    return

  return GitUtils._fetchFileHistory(fileName, stdout, exit)


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
