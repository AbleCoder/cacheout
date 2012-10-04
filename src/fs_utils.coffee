'use strict'

fs = require 'fs'
mkdirp = require 'mkdirp'
sysPath = require 'path'
wrench = require 'wrench'

logger = require './logger'

#-------------------------------------------------------------------------------

# recurively find files matching regex patterns on a path
#
# @param root  (string) Root path to find files in.
# @param match (array) Array of RegExp objects to test files against.
# @param callback (function) callback(error, file)
#   - On error called with error set, file null
#   - On file found icalled with error null, file set (string)
#   - On scan complete called back with both error and file set to null
exports.findFiles = (root, match, callback = (->)) ->
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
exports.writeFile = (path, data, callback) ->
  logger.debug 'writer', "Writing file '#{path}'"
  write = (callback) -> fs.writeFile path, data, callback
  write (error) ->
    return callback null, path, data unless error?
    mkdirp (sysPath.dirname path), 0o755, (error) ->
      return callback error if error?
      write (error) ->
        callback error, path, data
