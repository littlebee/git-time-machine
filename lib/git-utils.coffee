
{BufferedProcess} = require "atom"
_ = require('underscore-plus');
path = require "path"
fs = require "fs"

GitUtils = exports

###
  returns an array of javascript objects representing the commits that effected the requested file
  with line stats, that looks like this:
    [{
      "id": "1c41d8f647f7ad30749edcd0a554bd94e301c651",
      "authorName": "Bee Wilkerson",
      "relativeDate": "6 days ago",
      "authorDate": 1450881433,
      "message": "docs all work again after refactoring to bumble-build",
      "body": "",
      "hash": "1c41d8f",
      "linesAdded": 2,
      "linesDeleted": 2
    }, {
      ...
    }]
###  
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
    if line[0] == '{' && line[line.length-1] == '}'
      lastCommitObj = GitUtils._parseCommitObj(line)
      logItems.push lastCommitObj if lastCommitObj
    else if line[0] == '{'
      # this will happen when there are newlines in the commit message
      lastCommitObj = line
    else if _.isString(lastCommitObj)
      lastCommitObj += line
      if line[line.length-1] == '}'
        lastCommitObj = GitUtils._parseCommitObj(lastCommitObj)
        logItems.push lastCommitObj if lastCommitObj
    else if lastCommitObj? && (matches = line.match(/^(\d+)\s*(\d+).*/))
      # git log --num-stat appends line stats on separate line
      lastCommitObj.linesAdded = Number.parseInt(matches[1])
      lastCommitObj.linesDeleted = Number.parseInt(matches[2])
  return lastCommitObj


GitUtils._parseCommitObj = (line) ->
  encLine = line.replace(/\t/g, '  ') # tabs mess with JSON parse
  .replace(/\"/g, "'")           # sorry, can't parse with quotes in body or message
  .replace(/(\n|\n\r)/g, '<br>')
  .replace(/\r/g, '<br>')
  .replace(/\#\/dquotes\//g, '"')
  try
    return JSON.parse(encLine)
  catch
    console.warn "failed to parse JSON #{encLine}"
    return null



# note this is spied on by unit test. See spec/git-utils-spec.coffee
GitUtils._onFinishedParse = (code, logItems, callback) ->
  if code is 0 and logItems.length isnt 0
    callback logItems
  else
    callback []
  return


GitUtils._fetchFileHistory = (fileName, stdout, exit) ->
  format = ("""{"id": "%H", "authorName": "%an", "relativeDate": "%cr", "authorDate": %at, """ +
    """ "message": "%s", "body": "%b", "hash": "%h"}""").replace(/\"/g, "#/dquotes/")

  return new BufferedProcess {
    command: "git",
    args: [
      "-C",
      path.dirname(fileName),
      "log",
      "--pretty=format:#{format}",
      "--topo-order",
      "--date=local",
      "--numstat",
      fileName
    ],
    stdout,
    exit
  }
