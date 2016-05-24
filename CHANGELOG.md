
<a name="1.2.3"></a>
## [1.5.3](https://github.com/littlebee/git-time-machine/compare/1.5.2...1.5.3) (2016-05-145)
Upgrade split diff dependency and fix deprecation.  Thanks Alhadis and Michael!   Very much appreciated.

### Other Commits
* [d968cb3](https://github.com/littlebee/git-time-machine/commit/d968cb37bc05825f266115a4858e086caf0ce80a) Merge pull request #61 from Alhadis/master
* [a9ffea7](https://github.com/littlebee/git-time-machine/commit/a9ffea79e896f2dd7d8bc6d7fe93354ae1dd2402) Fix deprecation notice in package's entry point
* [d8da44c](https://github.com/littlebee/git-time-machine/commit/d8da44c63740139c90579bbea46a92363d7b6a14) updates split diff dependency to v0.8.3

## [1.5.2](https://github.com/littlebee/git-time-machine/compare/1.5.1...1.5.2) (2016-04-121)


### Other Commits
* [756d05a](https://github.com/littlebee/git-time-machine/commit/756d05a14dc9fb7c74a94c6e95cd189fdcd5e3c1) add horz scroll syncing (#57). config options coming in 2.0
* [7c35f9b](https://github.com/littlebee/git-time-machine/commit/7c35f9b850e2db989120c6c0a0c3a16a1784f0d1) add trouble shooting section to README
* [07aa7d1](https://github.com/littlebee/git-time-machine/commit/07aa7d1a71e2acb563e9cfeae21bd280f1f5db50) Adds keyboard shortcut to README.md
* [0259ad6](https://github.com/littlebee/git-time-machine/commit/0259ad65d873daadf036370d1ba9275521ec202b) update split-diff to 0.7.5. fixes #38

## [1.5.1](https://github.com/littlebee/git-time-machine/compare/1.5.0...1.5.1) (2016-04-116)
Improvements and upgrades to split-diff, differencing view.  Thank you @DSpeckhals.

## [1.5.0](https://github.com/littlebee/git-time-machine/compare/1.4.1...1.5.0) (2016-04-116)
Improvements and upgrades to split-diff, differencing view.  Thank you @DSpeckhals.

### Bugs Fixed in this Release
* [e7e874e](https://github.com/littlebee/git-time-machine/commit/e7e874e5aa9c5e38e249bbd1fb93fd5f21d5966b)  (unreported) fix error on file name containing parens. +show no error on file not in a git repo

### Other Commits
* [2fbfc94](https://github.com/littlebee/git-time-machine/commit/2fbfc94e1ff84ecde415395ea4bafcda12238b66) fix regression from pr #45.  revision view should sync to initial scroll position. +more sensible colors
* [c238cd6](https://github.com/littlebee/git-time-machine/commit/c238cd6c6a2d4c5a4e5dcf3fd6f22e3cdc3108a7) Merge branch 'master' of https://github.com/littlebee/git-time-machine into development
* [143fa0e](https://github.com/littlebee/git-time-machine/commit/143fa0e4ef916d0170e4745d54529ebf822ef309) was able to repro and fix #5
* [9fd54ae](https://github.com/littlebee/git-time-machine/commit/9fd54ae923092e7295df202a20705ef3f518de85) Merge pull request #45 from DSpeckhals/upgrade-split-diff
* [b218251](https://github.com/littlebee/git-time-machine/commit/b2182517b324c0b3f5affb2418ecd0d55c26bc13) Upgrade split-diff package, fix blob render error
* [5056e43](https://github.com/littlebee/git-time-machine/commit/5056e43d8282687b3939a99591301721f3ee931b) Merge pull request #44 from DSpeckhals/optimize-loading
* [f6de733](https://github.com/littlebee/git-time-machine/commit/f6de733dc17ac33133ee2b01b7337d882797b643) Load Git file data only when timeline is visible

## [1.4.1](https://github.com/littlebee/git-time-machine/compare/1.4.0...1.4.1) (2016-03-89)
A few more bug fixes; see below.  

### Other Commits
* [992d13a](https://github.com/littlebee/git-time-machine/commit/992d13a942be9ddccace3aafbbd0ffc818630843) fixes #25 - better handling of files outside the repository
* [6e9bd2f](https://github.com/littlebee/git-time-machine/commit/6e9bd2f1b3a4a358a58ae24fc7f45d65b8554b1c) fixes #30 - should be able to handle directories and files with spaces in name

## [1.4.0](https://github.com/littlebee/git-time-machine/compare/1.3.0...1.4.0) (2016-03-89)
A few more bug fixes and tweaks from the community for this release (see below).  Plus a close button for closing the timeplot that I was going to save for 2.0, but.... there you go. 

### Other Commits
* [2bbdd89](https://github.com/littlebee/git-time-machine/commit/2bbdd89960777ebdfb57478428165585d016b6df) Merge branch 'development' of https://github.com/littlebee/git-time-machine into development
* [060292a](https://github.com/littlebee/git-time-machine/commit/060292ab48bd52254b2d13cc7e0bfb261dc742e8) Merge pull request #27 from igorrafael/development
* [b9e37a6](https://github.com/littlebee/git-time-machine/commit/b9e37a6bda57b71e68d7986f61f4e4a105ee7ae8) Fixed error on older git versions. Removed usage of git argument '-C' which is not available on all git versions (eg: 1.8.3.1). The path is instead passed via Atom's BufferedProcess constructor options.
* [31cbbbb](https://github.com/littlebee/git-time-machine/commit/31cbbbb0e8b206f8800a49fa98700025ff962f34) move git log fetch and try catch out to it's own method
* [e7b2741](https://github.com/littlebee/git-time-machine/commit/e7b274162bd777ae7d1bde25e0ce848f43ddf1f9) merge from master
* [6e7376b](https://github.com/littlebee/git-time-machine/commit/6e7376b6f0c1ac53ad2efe7b7c15c5d9d08b1e12) Merge pull request #35 from melvinsh/patch-1
* [d412781](https://github.com/littlebee/git-time-machine/commit/d4127819257dd4c83a1acbb60ad3aef334d8164d) Fix spec description
* [9c30cf2](https://github.com/littlebee/git-time-machine/commit/9c30cf28dd7cbea51848547bfce6925475ceaa3f) Merge pull request #37 from stevelacy/master
* [dbec7e3](https://github.com/littlebee/git-time-machine/commit/dbec7e329762e6f5bc0b1ccc37b8e97bff796ad2) Catch errors - Use Atom core error notifications - close #36 close #34 close #33 close #32 close #31 close #29

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