redis         = require "redis"

chatApp = (config) ->
  this.start = ->
    console.log "Chat server is listening on port #{config.port}"
  this.stop = ->
    console.log "Chat server has stopped"

  return


module.exports = (config) ->
  return new chatApp(config)
