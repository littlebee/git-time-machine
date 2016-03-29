
<a name="1.2.3"></a>
## [1.3.0](https://github.com/littlebee/git-time-machine/compare/1.2.6...1.3.0) (2016-03-87)
Now works on windows!  (I think).   Big thanks @feleij

### Bugs Fixed in this Release
* [45e1ad4](https://github.com/littlebee/git-time-machine/commit/45e1ad49c57451ecd5b0da70cb0fd3a2a14159be)  fix #6. should work on windows
* [61da16a](https://github.com/littlebee/git-time-machine/commit/61da16a41fb31e51bfaf503ecdd8d897fd76f1e0)  fix #6.  Make time machine ignore line endings / prefer line ending of code in editor being diff'd

### Other Commits
* [c0dc9d5](https://github.com/littlebee/git-time-machine/commit/c0dc9d58ccdbe9c3e4c6b801226dc0c68cb1a754) bump git-log-utils version

## [1.2.6](https://github.com/littlebee/git-time-machine/compare/1.2.5...1.2.6) (2016-03-78)
bug fixes

### Other Commits
* [55646c0](https://github.com/littlebee/git-time-machine/commit/55646c0dc07e882591b48cb56fdf114307217d5f) fix #22 - path errors on windows

## [1.2.5](https://github.com/littlebee/git-time-machine/compare/1.2.4...1.2.5) (2016-02-52)
The last apm publish failed attempting to right

## [1.2.4](https://github.com/littlebee/git-time-machine/compare/1.2.3...1.2.4) (2016-02-52)
No fundamental changes except to mention [git-log-utils](https://www.npmjs.com/package/git-log-utils) being moved to it's own package.  

### Other Commits
* [0e4737e](https://github.com/littlebee/git-time-machine/commit/0e4737e35eda9225d461f847e33dc5e12e8135d6) Merge branch 'master' of https://github.com/littlebee/git-time-machine
* [ee5033d](https://github.com/littlebee/git-time-machine/commit/ee5033dd5b5512e9af85810c198c2f5e122b9f28) Merge pull request #10 from raqystyle/fix/pop-over-background
* [d4c8230](https://github.com/littlebee/git-time-machine/commit/d4c8230be73087df7c1aa6f982af5d6afb02e344) Set the background of the popup. Used standard border colours (followed style guides)

## [1.2.3](https://github.com/littlebee/git-time-machine/compare/v1.2.2...v1.2.3) (2016-01-10)

### :bug:
* @kankaristo suggested fix for [issue #3](https://github.com/littlebee/git-time-machine/issues/3)
 ([c775744](https://github.com/littlebee/git-time-machine/commit/c775744)),  
* maybe fix [issue #5](https://github.com/littlebee/git-time-machine/issues/5)? (unreproducible) ([d3bb2b0](https://github.com/littlebee/git-time-machine/commit/d3bb2b0)),  
* closes [issue #4](https://github.com/littlebee/git-time-machine/issues/4). Changelog out of date. 


## [1.2.2](https://github.com/littlebee/git-time-machine/compare/v1.2.1...v1.2.2) (2016-01-05)
Reduce animated demo gif size so it will work on Atom.io.  


## [1.2.1](https://github.com/littlebee/git-time-machine/compare/v1.2.0...v1.2.1) (2016-01-05)

### :bug:
* fix [#2](https://github.com/littlebee/git-time-machine/issues/2) - should be able to handle multiple folders with different git repos in a single project


## 1.2.0 - Added SplitDiff package for viewing revisions

Revisions were previously viewed ala git-history package style - now shows diffs with sync'd scrolling.  

Thank you @aaronbushnell for the suggestion and thanks to @mupchrch for the split-diff package which I use as an npm git+ dependency (nice code!).  


## 1.0.0 - First Release

This should have been 0.1.0, but I caught it a little late.  This was the initial public release.