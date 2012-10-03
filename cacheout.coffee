exports.config =
  # path to web project root
  srcPath: 'public'

  # path to output generated files
  outPath: 'cached'

  # length of sha1 checksum
  checksumLen: 20

  # all files that match these patterns are considered assets
  assetFiles: [
    /^javascripts\/.*\.js/,
    /^stylesheets\/.*\.css/,
  ]

  # all files that match these patterns are updated with new asset filenames
  sourceFiles: [
    /^index.html/,
  ]
