Util        = require "util"
Thread      = require "./Thread.js"
logger      = require "../logger.js"
Q           = require "q"
_           = require "lodash"

oriRedisCli    = null
redisCli    = null

REDIS_KEYS  =
  USER_ID_GEN         : "user:%d:generator"
  USER_DETAILS        : "user:%d"
  USER_THREADS        : "user:%d:threads"
  USER_SESSION        : "user:session:%s"

isValid = ->
  return true

class User
  
  that = null
  onError = (err) ->
    logger.error err
    throw err




  create = () ->

    return redisCli
      .incr(REDIS_KEYS.USER_ID_GEN)
      .then (id) ->
        that.id = id
        key = Util.format(REDIS_KEYS.USER_DETAILS,id)
        return redisCli.hmset(
          key
          "id", that.id
          "name", that.name
          "profileImage", that.profileImage
        )
      .then () -> that
      .fail onError

  retrieve = (id) ->
    logger.debug "Retrieving user with id = ", id
    key = Util.format(REDIS_KEYS.USER_DETAILS,id)

    return redisCli
      .hgetall(key)
      .fail onError

  update = (id) ->

    key = Util.format(REDIS_KEYS.USER_DETAILS,id)
    return redisCli
      .hmset(
        key
        "id", @id
        "name", @name
        "profileImage", @profileImage
      )
      .then () -> that
      .fail onError

  #delete is reserved
  del = (id) ->
    return

  constructor: (@id,@name,@profileImage) ->
    that = this
    return @

  # update or create this user
  # @return {promise} passing: user
  #
  save: () ->
    if not @id?
      logger.debug "Creating new user:", @
      return create()
    else
      logger.debug "Updating a user:", @
      return update()

  ###*
  subscribe to one or multiple threads
  @param paramType argName param
  @returns returnType return
  ###
  subscribe: (threads) ->
    threads = [threads] if not threads instanceof Array
    threadIds = threads.map (thread) -> thread.id if thread instanceof Thread

  unsubscribe: (threadId) ->
  getSession: () ->
  setSession: () ->

  @getUserById: (id) -> return retrieve(id)
  @getUserBySession: (session) -> 0

module.exports = (aRedisCli) ->
  throw Error("Redis client is not passed in") if !aRedisCli?

  redisCli = aRedisCli
  oriRedisCli = redisCli.origin

  return User
