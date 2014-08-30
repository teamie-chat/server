redis         = require "redis"

ChatApp = (config) ->
  @start = ->
    console.log "Chat server is listening on port #{config.port}"
  @stop = ->
    console.log "Chat server has stopped"

  return


module.exports = (config) ->
  return new ChatApp(config)
