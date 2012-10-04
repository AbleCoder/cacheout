'use strict'

fs = require 'fs'
helpers = require '../helpers'
logger = require '../logger'

{generateAssets} = require '../generators/assets'

#-------------------------------------------------------------------------------

module.exports = cacheit = (options, callback = (->)) ->
  config = helpers.loadConfig options.configPath

  {srcPath, outPath, assetFiles, sourceFiles} = config

  #console.log [srcPath, outPath, assetFiles, sourceFiles]

  generateAssets srcPath, outPath, assetFiles, null, (e, f) ->
    return logger.error e if error?

    console.log "cacheit::generateAssets: response", e, f
    ###
    genCachebustSources root, dest, sourceFiles, (error, files) ->
      console.log "genCachebustSources: response", error, files
    ###
