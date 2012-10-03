'use strict'

{exec} = require 'child_process'
coffeescript = require 'coffee-script'
fs = require 'fs'
sysPath = require 'path'


exports.deepFreeze = deepFreeze = (object) ->
  Object.keys(Object.freeze(object))
    .map (key) ->
      object[key]
    .filter (value) ->
      typeof value is 'object' and value? and not Object.isFrozen(value)
    .forEach(deepFreeze)
  object


exports.loadConfig = (configPath = 'cacheout', options = {}) ->
  fullPath = sysPath.resolve configPath
  delete require.cache[fullPath]
  try
    {config} = require fullPath
  catch error
    throw new Error("couldn\'t load config #{configPath}. #{error}")
  deepFreeze config
  config
