###
  this is the expected data for the first five commits of test-data/fiveCommits.txt.
  Only the keys in these objects are tested against the actual first five commits read
  from git log
###
module.exports = [{
  "id": "4d3547944bbac446b229838867bf60dd55289213",
  "authorName": "Bee",
  "authorDate": 1445053404,
  "message": "git-util-spec: fifth commit of spec/testData/fiveCommits.txt. only deleted a line",
  "hash": "4d35479",
  "linesAdded": 0,
  "linesDeleted": 2
}, {
  "id": "fa4aee05281c12f2ba8c92eb1100964f98901caa",
  "authorName": "Bee",
  "authorDate": 1445053316,
  "message": "git-util-spec: forth commit of spec/testData/fiveCommits.txt",
  "hash": "fa4aee0",
  "linesAdded": 1,
  "linesDeleted": 0
}, {
  "id": "010f49a2cf4fb08f7117782269ce8ede07e0797a",
  "authorName": "Bee",
  "authorDate": 1445053277,
  "message": "git-util-spec: third commit of spec/testData/fiveCommits.txt",
  "hash": "010f49a",
  "linesAdded": 2,
  "linesDeleted": 1
}, {
  "id": "3d03801db29c1f9d92550c8bfed32b21c08ced4c",
  "authorName": "Bee",
  "authorDate": 1445053179,
  "message": "git-util-spec: load correct fully qualified test file name. plus second commit of fiveCommits.txt",
  "hash": "3d03801",
  "linesAdded": 2,
  "linesDeleted": 0
}, {
  "id": "bb7b15fc68e681347185003ddb534366465c5b36",
  "authorName": "Bee",
  "authorDate": 1445052734,
  "message": "GitUtils.getFileCommitHistory should return valid data. +new failing test",
  "hash": "bb7b15f",
  "linesAdded": 7,
  "linesDeleted": 0
}]
