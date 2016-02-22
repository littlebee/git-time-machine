
<a name="1.2.3"></a>
## [1.2.4](https://github.com/littlebee/git-time-machine/compare/1.2.3...1.2.4) (2016-02-52)
No fundamental changes except to mention [git-log-utils](https://www.npmjs.com/package/git-log-utils) being moved to it's own package.  

### Other Commits
* [48efec8](https://github.com/littlebee/git-time-machine/commit/48efec898a9bbbc079ed9f65c26062289437b70d) update git-log-utils to 0.1.3
* [b41a304](https://github.com/littlebee/git-time-machine/commit/b41a3049745e7a6d7c5dd830900f7a44774d4c36) cleanup console.log
* [98b864e](https://github.com/littlebee/git-time-machine/commit/98b864ebf66d473e0c559fbc6004982c7fc378cb) factor out git log utils to separate npm package. all tests passing

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