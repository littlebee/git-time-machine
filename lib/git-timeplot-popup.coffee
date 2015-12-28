path = require "path"
moment = require 'moment'
fs = require 'fs'
_ = require 'underscore-plus'
{$, View} = require "atom-space-pen-views"
{BufferedProcess} = require "atom"

module.exports = class GitTimeplotPopup extends View

  @content = (commitData, start, end) ->
    dateFormat = "MMM DD YYYY ha"
    @div class: "select-list popover-list git-timemachine-popup", =>
      @div class: "controls", =>
        @label "Show Diffs: "
        @input type: "checkbox", outlet: "showDiffCheck"
      @h5 "There were #{commitData.length} commits between"
      @h6 "#{start.format(dateFormat)} and #{end.format(dateFormat)}"
      @ul class: "list-group", =>
        for commit in commitData
          authorDate = moment.unix(commit.authorDate)
          linesAdded = commit.linesAdded || 0
          linesDeleted = commit.linesDeleted || 0
          @li "data-rev": commit.hash, click: '_onShowRevision', =>
            @div class: "commit", =>
              @div class: "header", =>
                @div "#{authorDate.format(dateFormat)}"
                @div "#{commit.hash}"
                @div =>
                  @span class: 'added-count', "+#{linesAdded} "
                  @span class: 'removed-count', "-#{linesDeleted} "

              @div =>
                @strong "#{commit.message}"

              @div "Authored by #{commit.authorName} #{authorDate.fromNow()}"


  initialize: (commitData) ->
    @appendTo atom.views.getView atom.workspace
    @file = atom.workspace.getActiveTextEditor()?.getPath()
    @mouseenter @_onMouseEnter
    @mouseleave @_onMouseLeave


  isMouseInPopup: () =>
    return @_mouseInPopup == true


  _onMouseEnter: (evt) =>
    # console.log 'mouse in popup'
    @_mouseInPopup = true
    return


  _onMouseLeave: (evt) =>
    # console.log 'mouse leave popup'
    @_mouseInPopup = false
    @hide()
    return


  _onShowRevision: (evt) =>
    revHash = $(evt.target).closest('li').data('rev')
    @showRevision(revHash, diff: @showDiffCheck.is(':checked'))

  ###
    The following lines shamelessly stolen from git-history package,  lib/git-history-view
    with modifications:
    - show diff is check box on the popup, not a config

  ###
  showRevision: (revHash, options={}) ->
    options = _.defaults options,
      diff: false

    fileContents = ""
    stdout = (output) =>
        fileContents += output

    exit = (code) =>
        if code is 0
            outputDir = "#{atom.getConfigDirPath()}/.git-history"
            fs.mkdir outputDir if not fs.existsSync outputDir
            outputFilePath = "#{outputDir}/#{revHash}-#{path.basename(@file)}"
            outputFilePath += ".diff" if options.diff
            fs.writeFile outputFilePath, fileContents, (error) ->
                if not error
                    options = {split: "right", activatePane: yes}
                    atom.workspace.open(outputFilePath, options)
        else
            atom.notifications.addError "Could not retrieve history for #{path.basename(@file)}"

    @_loadRevision revHash, stdout, exit


  _loadRevision: (hash, stdout, exit, options={}) ->
    options = _.defaults options,
      diff: false;

    repo = r for r in atom.project.getRepositories() when @file.replace(/\\/g, '/').indexOf(r?.repo.workingDirectory) != -1
    diffArgs = [
        "-C",
        repo.repo.workingDirectory,
        "diff",
        "-U9999999",
        "#{hash}:#{atom.project.relativize(@file).replace(/\\/g, '/')}",
        "#{atom.project.relativize(@file).replace(/\\/g, '/')}"
    ]
    showArgs = [
        "-C",
        path.dirname(@file),
        "show",
        "#{hash}:#{atom.project.relativize(@file).replace(/\\/g, '/')}"
    ]
    new BufferedProcess {
        command: "git",
        args: if options.diff then diffArgs else showArgs,
        stdout,
        exit
    }
