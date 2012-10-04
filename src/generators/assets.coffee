'use strict'

fs = require 'fs'
crypto = require 'crypto'
logger = require '../logger'
fs_utils = require '../fs_utils'

generators = require './index'


#-------------------------------------------------------------------------------

# defaut gen file name function
genFileName = (basename, checksum, extension) ->
  "#{basename}_#{checksum[0..20]}#{extension}"

#-------------------------------------------------------------------------------

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
    fs_utils.writeFile "#{dest}/#{genFilePath}", file, (error) ->
      return callback error, null if error?

      # return generated file path
      callback null, genFilePath


exports.generateAssets = (root, dest, match, fileGenFn = fileGenChecksum(), callback = (->)) ->
  generators.generateFileOnMatch root, dest, match, callback, (root, dest, file, addGenFile) ->
    # match: create new cachebust file and store details
    fileGenFn root, dest, file, (error, gfile) ->
      # error: pass error back to callback
      return callback error, null if error?

      addGenFile file, gfile
