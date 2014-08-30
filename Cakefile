fs            = require 'fs'
which         = require 'which'
{spawn, exec} = require 'child_process'

# ANSI Terminal Colors
bold          = '\x1B[0;1m'
red           = '\x1B[0;31m'
green         = '\x1B[0;32m'
reset         = '\x1B[0m'

log = (message, color, explanation) ->
  console.log color + message + reset + ' ' + (explanation or '')

#test
#TODO: to be implemented
test = (cb) ->
  log "No test implemented yet :(", red
  return

#build
build = (cb) ->
  options = ['-c', '-b', '-o', '.app', 'src']
  cmd = which.sync 'coffee'
  compiler = spawn cmd, options
  compiler.stdout.pipe process.stdout
  compiler.stderr.pipe process.stderr
  compiler.on "exit", (status) -> cb?() if status is 0

#define tasks
task 'build', 'Build project files', ->
  build -> log "Done.", green

task 'test', 'Build and run Mocha tests', ->
  build -> test -> log "Done.", green


task 'dev', 'Start dev env', ->

  options = ['-c', '-b', '-w', '-o', '.app', 'src']
  cmd = which.sync 'coffee'
  watchingCompiler = spawn cmd, options
  watchingCompiler.stdout.pipe process.stdout
  watchingCompiler.stderr.pipe process.stderr

  watcher  = spawn 'nodemon', ['-w','.app','-w','server.coffee','-x', 'coffee', 'server.coffee']
  watcher.stdout.pipe process.stdout
  watcher.stderr.pipe process.stderr
