_ = require 'underscore-plus'
path = require 'path'
fs = require 'fs'
str = require('bumble-strings')


{CompositeDisposable, BufferedProcess} = require "atom"
{$} = require "atom-space-pen-views"

SplitDiff = require 'split-diff'


module.exports =
class GitRevisionView

  @FILE_PREFIX = "TimeMachine - "
  ###
    This code and technique was originally from git-history package,
    see https://github.com/jakesankey/git-history/blob/master/lib/git-history-view.coffee

    Changes to permit click and drag in the time plot to travel in time:
    - don't write revision to disk for faster access and to give the user feedback when git'ing
      a rev to show is slow
    - reuse tabs more - don't open a new tab for every rev of the same file

    Changes to permit scrolling to same lines in view in the editor the history is for

    thank you, @jakesankey!

  ###
  @showRevision: (editor, revHash, options={}) ->
    options = _.defaults options,
      diff: false

    file = editor.getPath()

    fileContents = ""
    stdout = (output) =>
        fileContents += output
    exit = (code) =>
      if code is 0
        @_showRevision(file, editor, revHash, fileContents, options)
      else
        atom.notifications.addError "Could not retrieve revision for #{path.basename(file)} (#{code})"

    @_loadRevision file, revHash, stdout, exit


  # returns the pane and it's index (left to right) in workspace.getPanes()
  @findEditorPane: (editor) ->
    for pane, paneIndex in atom.workspace.getPanes()
      for item in pane.getItems()
        return [pane, paneIndex] if item == editor
    
    return [null, null]


  # returns the baseFileName of the original file or null if the editor is not a TimeMachine opened revision
  @isTimeMachineRevisionEditor: (editor) ->
    fileName = editor.getFileName?()
    return null unless fileName?
    matches = fileName.match new RegExp("^#{@FILE_PREFIX}(.*)")
    return matches?[1] || null
    

  @_loadRevision: (file, hash, stdout, exit) ->
    showArgs = [
      "show",
      "#{hash}:./#{path.basename(file)}"
    ]
    # console.log "calling git"
    new BufferedProcess {
      command: "git",
      args: showArgs,
      options: { cwd:path.dirname(file) },
      stdout,
      exit
    }


  @_getInitialLineNumber: (editor) ->
    editorEle = atom.views.getView editor
    lineNumber = 0
    if editor? && editor != ''
      lineNumber = editorEle.getLastVisibleScreenRow()
      # console.log "_getInitialLineNumber", lineNumber

      # TODO: why -5?  this is what it took to actually sync the last line number
      #    between two editors
      return lineNumber - 5


  @_showRevision: (file, editor, revHash, fileContents, options={}) ->
    outputDir = "#{atom.getConfigDirPath()}/git-time-machine"
    fs.mkdir outputDir if not fs.existsSync outputDir
    outputFilePath = "#{outputDir}/#{@FILE_PREFIX}#{path.basename(file)}"
    outputFilePath += ".diff" if options.diff
    tempContent = "Loading..." + editor.buffer?.lineEndingForRow(0)
    
    
    fs.writeFile outputFilePath, tempContent, (error) =>
      if not error
        # editor (current rev) may have been destroyed, workspace.open will find or
        # reopen it
        promise = atom.workspace.open file,
          activatePane: false
          activateItem: true
          searchAllPanes: true
        promise.then (editor) =>
          [pane, paneIndex] = @findEditorPane(editor)
          if paneIndex == 0
            pane.splitLeft()
          else
            atom.workspace.activatePreviousPane()
            
          promise = atom.workspace.open outputFilePath,
            activateItem: true
            searchAllPanes: false
          promise.then (newTextEditor) =>
            @_updateNewTextEditor(newTextEditor, editor, revHash, fileContents)
            pane.activate()
            




  @_updateNewTextEditor: (newTextEditor, editor, revHash, fileContents) ->
    lineEnding = editor.buffer?.lineEndingForRow(0) || "\n"
    fileContents = fileContents.replace(/(\r\n|\n)/g, lineEnding)
    newTextEditor.buffer.setPreferredLineEnding(lineEnding)
    newTextEditor.setText(fileContents)

    # HACK ALERT: this is prone to eventually fail. Don't show user change
    #  "would you like to save" message between changes to rev being viewed
    newTextEditor.buffer.cachedDiskContents = fileContents

    @splitDiff(editor, newTextEditor)
    @syncScroll(editor, newTextEditor)
    @_affixTabTitle newTextEditor, revHash



  @_affixTabTitle: (newTextEditor, revHash) ->
    # speaking of hacks this is also hackish, there has to be a better way to change to
    # tab title and unlinking it from the file name
    $el = $(atom.views.getView(newTextEditor))
    $tabTitle = $el.parents('atom-pane').find('li.tab.active .title')
    titleText = $tabTitle.text()
    if titleText.indexOf('@') >= 0
      titleText = titleText.replace(/\@.*/, "@#{revHash}")
    else
      titleText += " @#{revHash}"

    $tabTitle.text(titleText)


  @splitDiff: (editor, newTextEditor) ->
    editors =
      editor1: newTextEditor    # the older revision
      editor2: editor           # current rev

    SplitDiff._setConfig 'rightEditorColor', 'green'
    SplitDiff._setConfig 'leftEditorColor', 'red'
    SplitDiff._setConfig 'diffWords', true
    SplitDiff._setConfig 'ignoreWhitespace', true
    SplitDiff._setConfig 'syncHorizontalScroll', true

    SplitDiff.editorSubscriptions = new CompositeDisposable()
    SplitDiff.editorSubscriptions.add editors.editor1.onDidStopChanging =>
      SplitDiff.updateDiff(editors) if editors?
    SplitDiff.editorSubscriptions.add editors.editor2.onDidStopChanging =>
      SplitDiff.updateDiff(editors) if editors?
    SplitDiff.editorSubscriptions.add editors.editor1.onDidDestroy =>
      editors = null;
      SplitDiff.disable(false)
    SplitDiff.editorSubscriptions.add editors.editor2.onDidDestroy =>
      editors = null;
      SplitDiff.disable(false)

    SplitDiff.updateDiff editors


  # sync scroll to editor that we are show revision for
  @syncScroll: (editor, newTextEditor) ->
    # without the delay, the scroll position will fluctuate slightly beween
    # calls to editor setText
    _.delay =>
      return if newTextEditor.isDestroyed()
      newTextEditor.scrollToBufferPosition({row: @_getInitialLineNumber(editor), column: 0})
    , 50
    
  
  
    
      
    
    
