'use strict'

{exec} = require 'child_process'
fs = require 'fs'
crypto = require 'crypto'
wrench = require 'wrench'
mkdirp = require 'mkdirp'
sysPath = require 'path'
#rimraf = require 'rimraf'
helpers = require '../helpers'
logger = require '../logger'
#fs_utils = require '../fs_utils'

#-------------------------------------------------------------------------------

# Creates file if it doesn't exist and writes data to it.
# Would also create a parent directories if they don't exist.
#
# path - path to file that would be written.
# data - data to be written
# callback(error, path, data) - would be executed on error or on
#    successful write.
#
# Example
#
#   writeFile 'test.txt', 'data', (error) -> console.log error if error?
#
writeFile = (path, data, callback) ->
  logger.debug 'writer', "Writing file '#{path}'"
  write = (callback) -> fs.writeFile path, data, callback
  write (error) ->
    return callback null, path, data unless error?
    mkdirp (sysPath.dirname path), 0o755, (error) ->
      return callback error if error?
      write (error) ->
        callback error, path, data

# recurively find files matching regex patterns on a path
#
# @param root  (string) Root path to find files in.
# @param match (array) Array of RegExp objects to test files against.
# @param callback (function) callback(error, file)
#   - On error called with error set, file null
#   - On file found icalled with error null, file set (string)
#   - On scan complete called back with both error and file set to null
findFiles = (root, match, callback = (->)) ->
  matchFiles = (files) ->
    for f in files
      for p in match
        if p.test f
          callback null, f
          break

  wrench.readdirRecursive root, (error, files) ->
    # wrench returned error
    return callback error, null if error?

    # wrench recusive scan complete
    return callback null, null unless files?

    # wrench returned file list
    matchFiles files

# defaut gen file name function
genFileName = (basename, checksum, extension) ->
  "#{basename}_#{checksum[0..20]}#{extension}"

# default cachebust file generator
fileGenChecksum = (genFileNameFn = genFileName) ->
  getSha1 = (data) ->
    shaSum = crypto.createHash('sha1')
    shaSum.update(data).digest('hex')

  getBasename = (path) ->
    (/(.+)(?=\.\w+$)/).exec(path)[0]

  getExtension = (path) ->
    (/\.[a-zA-Z0-9]{1,}$/).exec(path)[0]

  genFileNameFn = _genFileName unless genFileNameFn?

  return (root, dest, filePath, callback) ->
    # read original file
    file = fs.readFileSync("#{root}/#{filePath}")

    # generate new filename
    basename  = getBasename filePath
    checksum  = getSha1 file
    extension = getExtension filePath

    genFilePath = genFileNameFn basename, checksum, extension

    # write new file
    writeFile "#{dest}/#{genFilePath}", file, (error) ->
      return callback error, null if error?

      # return generated file path
      callback null, genFilePath

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
createCachebustedAssets = (root, dest, match, fileGenFn, callback) ->
  genFiles = {}

  findFilesComplete = ->
    callback null, genFiles

  findFiles root, match, (error, file) ->
    # error: pass error back to callback
    return callback e, null if error?

    # finished
    return findFilesComplete() unless file? or error?

    # match: create new cachebust file and store details
    fileGenFn root, dest, file, (error, gfile) ->
      # error: pass error back to callback
      return callback error, null if error?

      genFiles[file] = gfile

module.exports = cacheit = (options, callback = (->)) ->
  config = helpers.loadConfig options.configPath

  {srcPath, outPath, assetFiles, sourceFiles} = config

  console.log [srcPath, outPath, assetFiles, sourceFiles]

  createCachebustedAssets srcPath, outPath, assetFiles, fileGenChecksum(), (e, f) ->
    return logger.error e if error?

    # TODO: create function to update sources (*.html) with new generated files
    console.log "cacheit::createCachebustedAssets: response", e, f
