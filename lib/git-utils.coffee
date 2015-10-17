
{BufferedProcess} = require "atom"
_ = require('underscore-plus');
path = require "path"
fs = require "fs"

GitUtils = exports



# returns an array of javascript objects representing the commits that effected the requested file
# with line stats
GitUtils.getFileCommitHistory = (fileName, callback)->
  logItems = []

  stdout = (output) ->
    logItems = logItems.concat output.split("\n")
    return

  exit = (code) =>
    if code is 0 and logItems.length isnt 0
      callback logItems
    else
      callback []

  GitUtils._fetchFileHistory(fileName, stdout, exit)


GitUtils._fetchFileHistory = (fileName, stdout, exit) ->
  format = "{\"author\": \"%an\",\"relativeDate\": \"%cr\",\"fullDate\": \"%ad\",\"message\": \"%s\",\"hash\": \"%h\"},"

  new BufferedProcess {
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
