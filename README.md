# git-time-machine package

git-time-machine is a package for [Atom](https://atom.io/) that allows you to travel back in time!  It shows visual plot of commits to the current file over time and you can click on it on the timeplot or hover over the plot and see all of the commits for a time range.

![Gratuitous animated screenshot](https://raw.githubusercontent.com/littlebee/git-time-machine/master/resources/timemachine.gif)

To open the timeplot, just use the keyboard shortcut <kbd>alt</kbd>+<kbd>t</kbd>.


## Troubleshooting

Unfortunately, git-time-machine, like the other Atom `git log` services,  needs to shell out to the command line git executable and parse its stdout.  We are working on getting this information another way, but that may take some time.  As you might imagine, this is problematic.

Some things to check:
- git command line utility needs to be in your path
- can you install and use git-log Atom package?
- it's been brought to my attention that some versions of git command line utilities (speculation: the version of git installed by github windows client) is not fully compatible with the official git client and doesn't support the pretty format needed to get the data to render the timeplot.  
- Windows users: make sure the 'git/bin' directory is in your PATH

Some users have reported seeing "Error: Command failed: git log --pretty=..."  on mac when xcode license agreement is needed.  Running `sudo xcodebuild -license` and accepting the agreement fixed the issued.

Recommend installing the official Git client from here: https://git-scm.com/downloads and make sure its binary is the one in your path.
