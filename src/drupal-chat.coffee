redis         = require "redis"
logger        = require "./logger.js"

###*
Initialize a new chat server instance
@constructor
@param {object} configs chat server port, redis and drupal server
###
ChatApp = (config) ->
  @start = ->
    logger.info "Chat server is listening on port #{config.port}"
  @stop = ->
    logger.warn "Chat server has stopped"

  return


module.exports = (config) ->
  return new ChatApp(config)
