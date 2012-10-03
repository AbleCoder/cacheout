'use strict'

argumentum = require 'argumentum'
fs = require 'fs'
sysPath = require 'path'
commands = require './commands'
helpers = require './helpers'
#logger = require './logger'

# Reads package.json and extracts cacheout version from there.
# Returns string.
exports.readPackageVersion = readPackageVersion = ->
  content = fs.readFileSync sysPath.join __dirname, '..', 'package.json'
  (JSON.parse content).version

# Config for [argumentum](https://github.com/paulmillr/argumentum).
commandLineConfig =
  script: 'cacheout'
  commandRequired: yes
  commands:
    go:
      abbr: 'g'
      help: 'Generate cache busting asset file(s) and updated source file(s) for current project'
      options:
        tag:
          abbr: 't'
          help: 'optional tag to add to include in cache busting asset file (e.g. build number)'
          full: 'tag'
        configPath:
          abbr: 'c'
          help: 'path to config file'
          metavar: 'CONFIG'
          full: 'config'
      callback: commands.cacheit

  options:
    version:
      abbr: 'v'
      help: 'display cacheout version'
      flag: yes
      callback: readPackageVersion

# The function would be executed every time user run `bin/brunch`.
exports.run = ->
  argumentum.load(commandLineConfig).parse()
