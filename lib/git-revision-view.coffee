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
  
  # this is true when we are creating panes and editors for a revision. 
  @isActivating = false
  
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
  @showRevision: (editor, leftRevHash, rightRevHash, options={}) ->
    options = _.defaults options,
      diff: false
    
    return unless leftRevHash? || rightRevHash?
    
    editor = editor.__gitTimeMachine.sourceEditor if editor.__gitTimeMachine?.sourceEditor?
    file = editor.getPath()
    
    promises = for revHash in [leftRevHash, rightRevHash]
      @_loadRevision file, revHash
      
    Promise.all(promises).then (revisions)=>
      @_showRevisions(file, editor, revisions, options)


  # returns the pane and it's index (left to right) in workspace.getPanes()
  @findEditorPane: (editor) ->
    for pane, paneIndex in atom.workspace.getPanes()
      for item in pane.getItems()
        return [pane, paneIndex] if item == editor
    
    return [null, null]


  @_loadRevision: (file, hash) ->
    return new Promise (resolve, reject) =>
      unless hash?
        resolve(null)
        return
         
      fileContents = ""
      stdout = (output) ->
          fileContents += output
      exit = (code) =>
        if code is 0
          resolve 
            revHash: hash
            fileContents: fileContents
        else
          atom.notifications.addError "Could not retrieve revision for #{path.basename(file)} (#{code})"
          reject(code)

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


  @_showRevisions: (file, editor, revisions, options={}) ->
    @isActivating = true
    promises = for revision, index in revisions
      @_showRevision(file, editor, revision, index == 0, options) 
  
    Promise.all(promises).then =>
      [leftRevision, rightRevision] = revisions
      return unless leftRevision?.editor?
      rightRevEditor = if rightRevision? then rightRevision.editor else editor
      
      @splitDiff(leftRevision.editor, rightRevEditor)
      @syncScroll(leftRevision.editor, rightRevEditor)
      @isActivating = false


  
  @_showRevision: (file, editor, revision, isLeftRev, options={}) ->
    return new Promise (resolve, reject) =>
      if revision?
        {revHash, fileContents} = revision
      else
        revHash = fileContents = null    # show current revision
      
      # editor (current rev) may have been destroyed, workspace.open will find or
      # reopen it
      promise = atom.workspace.open file,
        activatePane: false
        activateItem: true
        searchAllPanes: true
        
      promise.then (sourceEditor) =>
        unless revHash?
          @_updateEditor(editor, sourceEditor, revHash, null, false)
          revision?.editor = sourceEditor
          resolve(sourceEditor)
          return
        
        promise = @_createEditorForRevision(file, sourceEditor, revision, fileContents, isLeftRev)
        promise.then (newEditor) => resolve(newEditor)
        
        
  @_createEditorForRevision: (file, editor, revision, fileContents, isLeftRev) ->
    return new Promise (resolve, reject) =>
      outputFilePath = @_getOutputFilePath(file, revision)
      tempContent = "Loading..." + editor.buffer?.lineEndingForRow(0)
      fs.writeFileSync outputFilePath, tempContent
      
      @_destroyPreviousRevEditor(editor, revision, isLeftRev)
    
      # editor here should always be the original source doc editor (current rev)
      [pane, paneIndex] = @findEditorPane(editor)
      if isLeftRev 
        if paneIndex <= 0
          pane.splitLeft()
          leftPane = atom.workspace.getPanes()[0]
          leftPane.activate() unless leftPane == atom.workspace.getActivePane()
        else 
          leftPane = atom.workspace.getPanes()[paneIndex - 1]
          leftPane.activate()
      else
        pane.activate()
        
      promise = atom.workspace.open outputFilePath,
        activateItem: true
        searchAllPanes: false
      promise.then (newTextEditor) =>
        @_updateEditor(newTextEditor, editor, revision.revHash, fileContents, isLeftRev)
        revision.editor = newTextEditor
        resolve(newTextEditor)
        
        
  @_destroyPreviousRevEditor: (editor, revision, isLeftRev) ->
    return unless editor.__gitTimeMachine?
    
    if isLeftRev 
      editorToDestroy = editor.__gitTimeMachine.leftRevEditor
      editor.__gitTimeMachine.leftRevEditor = null
      editor.__gitTimeMachine.leftRev = null
    else
      # right rev could be the current.  don't destroy the source editor
      unless editor.__gitTimeMachine.rightRevHash == null
        editorToDestroy = editor.__gitTimeMachine.rightRevEditor
      editor.__gitTimeMachine.rightRevEditor = null
      editor.__gitTimeMachine.rightRev = null
      
    editorToDestroy?.destroy()
  
  
  @_getOutputFilePath: (file, revision)->
    outputDir = "#{atom.getConfigDirPath()}/git-time-machine"
    fs.mkdirSync outputDir if not fs.existsSync outputDir
    return "#{outputDir}/#{@FILE_PREFIX}#{revision.revHash[-6..]} #{path.basename(file)}"

  
  @_updateEditor: (newTextEditor, editor, revHash, fileContents, isLeftRev) ->
    lineEnding = editor.buffer?.lineEndingForRow(0) || "\n"
    # revHash == null = we are updating the current source editor (curent rev)
    if revHash? && fileContents?
      fileContents = fileContents?.replace(/(\r\n|\n)/g, lineEnding)
      newTextEditor.buffer.setPreferredLineEnding(lineEnding)
      newTextEditor.setText(fileContents)
    
    metadata = _.extend {}, editor.__gitTimeMachine ? {},
      sourceEditor: editor
      
    if isLeftRev
      metadata.leftRevEditor = newTextEditor
      metadata.leftRevHash = revHash
    else
      metadata.rightRevEditor = newTextEditor
      metadata.rightRevHash = revHash

    newTextEditor.__gitTimeMachine = metadata
    newTextEditor.onDidDestroy => @_onDidDestroyTimeMachineEditor(newTextEditor) 
    editor.__gitTimeMachine = metadata
    
    # HACK ALERT: this is prone to eventually fail. Don't show user change
    #  "would you like to save" message between changes to rev being viewed
    if revHash?
      newTextEditor.buffer.cachedDiskContents = fileContents
      
    return metadata

    
  @_onDidDestroyTimeMachineEditor: (editor) ->
    filePath = editor.getPath()
    return unless str.startsWith(path.basename(filePath), @FILE_PREFIX)
    fs.unlink(filePath)
  

  @splitDiff: (leftEditor, rightEditor) ->
    editors =
      editor1: leftEditor    # the older revision
      editor2: rightEditor           # current rev

    # TODO : not sure why these seem reversed but the display is correct with green on the right
    SplitDiff._setConfig 'leftEditorColor', 'red  e'
    SplitDiff._setConfig 'rightEditorColor', 'green'
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
  @syncScroll: (leftEditor, rightEditor) ->
    # without the delay, the scroll position will fluctuate slightly beween
    # calls to editor setText
    _.delay =>
      return if leftEditor.isDestroyed() || rightEditor.isDestroyed()
      leftEditor.scrollToBufferPosition({row: @_getInitialLineNumber(rightEditor), column: 0})
    , 50
    
    
