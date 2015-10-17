# git-time-machine package

git-time-machine shows a pane on request at the bottom of the current editor that allows the user to travel back in time and see how a particular piece of code has changed accross revisions.   

git-time-machine attempts to track the lines of code in view in the editor as you go back in time so that you can understand how a piece of code you are working on has changed over the course of its git life.  Did someone previously try what I'm about to do here?

The pane at the bottom shows a time line with all of the revisions in which the current file was changed. The size of the revision marker is porportional to the ammount of lines changed in the file (sum of absolute values for added and deleted).  Hovering over a marker gives information about the revision.  Clicking on a marker shows you  that revision (uneditable) in the current editor.   

![A screenshot of your package](https://f.cloud.github.com/assets/69169/2290250/c35d867a-a017-11e3-86be-cd7c5bf3ff9b.gif)
