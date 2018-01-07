_ = require 'underscore-plus'
path = require 'path'
fs = require 'fs'
str = require('bumble-strings')


{CompositeDisposable, BufferedProcess} = require "atom"
{$} = require "atom-space-pen-views"


module.exports = class GitRevisionView

  FILE_PREFIX: "TimeMachine - "
  
  # this is true when we are creating panes and editors for a revision. 
  @isActivating: -> 
    return @_isActivating

    
  @loadExistingRevForEditor: (editor) ->
    return unless editor.__gitTimeMachine?
    _.defer =>
      unless editor.isDestroyed()
        editor.__gitTimeMachine?.activateTimeMachineEditorForEditor(editor) 


  @showRevision: (sourceEditor, leftRevHash, rightRevHash) -> 
    if sourceEditor.__gitTimeMachine
      sourceEditor.__gitTimeMachine.showRevision(sourceEditor, leftRevHash, rightRevHash)
    else
      new GitRevisionView().showRevision(sourceEditor, leftRevHash, rightRevHash)
      

  leftRevEditor: null
  rightRevEditor: null
  sourceEditor: null
  
  activateTimeMachineEditorForEditor: (editor) ->
    return unless editor in [@leftRevEditor, @rightRevEditor, @sourceEditor]
    
    GitRevisionView._isActivating = true
    if editor == @leftRevEditor
      rightEditor = @rightRevEditor ? @sourceEditor
      @findEditorPane(rightEditor)[0].activateItem(rightEditor)
    else
      @findEditorPane(@leftRevEditor)[0].activateItem(@leftRevEditor)
    
    @splitDiff(@leftRevEditor, @rightRevEditor)
    GitRevisionView._isActivating = false
      

  
  showRevision: (@sourceEditor, leftRevHash, rightRevHash, options={}) ->
    options = _.defaults options,
      diff: false
    
    return unless leftRevHash? || rightRevHash?
    file = @sourceEditor.getPath()
    
    promises = for revHash in [leftRevHash, rightRevHash]
      @_loadRevision file, revHash
      
    Promise.all(promises).then (revisions)=>
      @revisions = revisions
      @_showRevisions revisions, options
      
    @sourceEditor.onDidDestroy => @_onDidDestroyTimeMachineEditor(@sourceEditor)
    @sourceEditor.__gitTimeMachine = @
      
    return @


  # returns the pane and it's index (left to right) in workspace.getPanes()
  findEditorPane: (editor) ->
    for pane, paneIndex in atom.workspace.getPanes()
      for item in pane.getItems()
        return [pane, paneIndex] if item == editor
    
    return [null, null]

  
  _loadRevision: (file, hash) ->
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


  _getInitialLineNumber: (editor) ->
    editorEle = atom.views.getView editor
    lineNumber = 0
    if editor? && editor != ''
      lineNumber = editorEle.getLastVisibleScreenRow()
      # console.log "_getInitialLineNumber", lineNumber

      # TODO: why -5?  this is what it took to actually sync the last line number
      #    between two editors
      return lineNumber - 5


  # revisions are the promise resolve from @_loadRevision()
  _showRevisions: (revisions, options={}) ->
    GitRevisionView._isActivating = true
    promises = for revision, index in revisions
      @_showRevision(revision, index == 0, options) 
  
    Promise.all(promises).then (editors) =>
      [@leftRevEditor, @rightRevEditor] = editors
      @rightRevEditor ?= @sourceEditor
      
      @splitDiff(@leftRevEditor, @rightRevEditor)
      GitRevisionView._isActivating = false


  
  _showRevision: (revision, isLeftRev, options={}) ->
    return new Promise (resolve, reject) =>
      if revision?
        {revHash, fileContents} = revision
      else
        revHash = fileContents = null    # show current revision
      
      # editor (current rev) may have been destroyed, workspace.open will find or
      # reopen it
      promise = atom.workspace.open @sourceEditor.getPath(),
        activatePane: false
        activateItem: false
        searchAllPanes: true
        
      promise.then (sourceEditor) =>
        @sourceEditor = sourceEditor
        
        unless revHash?
          resolve(sourceEditor)
          return
        
        promise = @_createEditorForRevision(revision, fileContents, isLeftRev)
        promise.then (newEditor) => 
          resolve(newEditor)
        
        
  _createEditorForRevision: (revision, fileContents, isLeftRev) ->
    file = @sourceEditor.getPath()
    return new Promise (resolve, reject) =>
      outputFilePath = @_getOutputFilePath(file, revision, isLeftRev)
      
      # sourceEditor here should always be the original source doc editor (current rev)
      [sourceEditorPane, paneIndex] = @findEditorPane(@sourceEditor)
      if isLeftRev 
        if paneIndex <= 0
          sourceEditorPane.splitLeft()
          leftPane = atom.workspace.getPanes()[0]
          leftPane.activate() unless leftPane == atom.workspace.getActivePane()
        else 
          leftPane = atom.workspace.getPanes()[paneIndex - 1]
          leftPane.activate()
      else
        sourceEditorPane.activate()
        
      promise = atom.workspace.open outputFilePath,
        activateItem: true
        searchAllPanes: false
        
      promise.then (newTextEditor) =>
        @_updateEditor(newTextEditor, revision.revHash, fileContents, isLeftRev)
        revision.sourceEditor = newTextEditor
        _.defer => sourceEditorPane.activate()
        resolve(newTextEditor)
        
        
  _getOutputFilePath: (file, revision, isLeftRev)->
    outputDir = "#{atom.getConfigDirPath()}/git-time-machine"
    fs.mkdirSync outputDir if not fs.existsSync outputDir
    leftOrRight = if isLeftRev then ' left: ' else ' right: '

    outputPath = "#{outputDir}/#{@FILE_PREFIX} #{path.basename(file)}"
      
    return outputPath
    
  
  _updateEditor: (newTextEditor, revHash, fileContents, isLeftRev) ->
    lineEnding = @sourceEditor.buffer?.lineEndingForRow(0) || "\n"
    # revHash == null = we are updating the current source sourceEditor (curent rev)
    if revHash? && fileContents?
      fileContents = fileContents?.replace(/(\r\n|\n)/g, lineEnding)
      newTextEditor.buffer.setPreferredLineEnding(lineEnding)
      # HACK ALERT: this is prone to eventually fail. Don't show user change
      #  "would you like to save" message between changes to rev being viewed
      newTextEditor.buffer.cachedDiskContents = fileContents
      newTextEditor.setText(fileContents)

    newTextEditor.onDidDestroy => @_onDidDestroyTimeMachineEditor(newTextEditor) 

    if isLeftRev
      @leftRevEditor = newTextEditor
      @rightRevEditor ?= @sourceEditor
    else
      @rightRevEditor = newTextEditor
      
    newTextEditor.__gitTimeMachine = @sourceEditor.__gitTimeMachine = @
    
    
    
    
  _onDidDestroyTimeMachineEditor: (editor) ->
    gitRevView = editor.__gitTimeMachine
    return unless gitRevView?

    if editor in [gitRevView.leftRevEditor, gitRevView.rightRevEditor]
      if editor != gitRevView.sourceEditor 
        filePath = editor.getPath()
        if filePath.match /\/git-time-machine\/TimeMachine \- /
          fs.unlink(filePath)
        else
          console.warn "cowardly refusing to delete non gtm temp file: #{filePath}"
      delete editor.__gitTimeMachine
    
    if editor == gitRevView.leftRevEditor
      unless gitRevView.rightRevEditor == gitRevView.sourceEditor
        gitRevView.rightRevEditor.destroy()
    else
      gitRevView.leftRevEditor.destroy()
    
    gitRevView.sourceEditor.__gitTimeMachine = null
    

  # starting in gtm 2.0; leftEditor = order version, rightEditor = new version
  splitDiff: (leftEditor, rightEditor) ->
    @constructor.SplitDiffService?.diffEditors(leftEditor, rightEditor)
    


    
    
