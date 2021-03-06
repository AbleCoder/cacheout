'use strict'

fs = require 'fs'
logger = require '../logger'
fs_utils = require '../fs_utils'

#-------------------------------------------------------------------------------

# Create copy of asset files in `root` that match any of the regex patterns
# passed in `match` with cache busting filename in `dest` folder.
# . and return a
# dict with the original file path and the value being the new
# file path.
#
# root (string) Root path to search for asset files.
# dest (string) Path to create new cache busting asset files.
# callback (function) Function called on error or success, cb(error, genFiles)
#                 - On error called with error set, genFiles null
#                 - On success error null and genFiles set as dict
#                   original file path key and the value being the new
# fileGenFn (function) Function that generates cache busting file taking the
#                 following arguments:
#                     root (str) Root path searched in
#                     file (str) Path to file from `root`
exports.generateFileOnMatch = (root, dest, match, callback, onMatchFn) ->
  genFileCount = 0
  genFiles     = {}

  addGenFile = (origFile, genFile) ->
    genFiles[origFile] = genFile
    --genFileCount
    isGenFileDone()

  incGenFileCount = ->
    ++genFileCount

  isGenFileDone= ->
    if genFileCount < 1
      console.log "isGenFileDone", genFileCount
      return callback null, genFiles

  fs_utils.findFiles root, match, (error, file) ->
    # error: pass error back to callback
    return callback error, null if error?

    # match
    return onMatchFn root, dest, file, addGenFile, incGenFileCount if file?

    # finished
    isGenFileDone()
