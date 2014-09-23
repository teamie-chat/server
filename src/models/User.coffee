Util        = require "util"
Thread      = require "./Thread.js"
logger      = require "../logger.js"
Q           = require "q"
_           = require "lodash"

redisCli    = require("./ModelSettings").getRedisCli()
oriRedisCli = redisCli.origin

# TODO: put this constant in somewhere, it's reused in all models
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
      .then () ->
        return that
      .fail onError

  retrieve = (id) ->
    logger.debug "Retrieving user with id = ", id
    key = Util.format(REDIS_KEYS.USER_DETAILS,id)

    return redisCli
      .hgetall(key)
      .then (obj)->
        if (obj?)
          obj.id = parseInt(obj.id)
          return _.extend(new User(), obj) if obj?
        else
          return obj
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
  del = () ->
    return if not that.id?

    key = Util.format(REDIS_KEYS.USER_DETAILS,that.id)
    return redisCli
      .del(key)

  constructor: (@id,@name,@profileImage) ->
    throw new Error("RedisCli is not initialized yet, call ModelSettings to set the client") if not redisCli?
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

  delete: () ->
    return del()
      .then (res)-> true
      .fail onError

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
    throw new Error ("Not yet implemented")
  setSession: () ->
    throw new Error ("Not yet implemented")

  getThreadsIds: (start,end)->
    key = Util.format(REDIS_KEYS.USER_THREADS,@id)
    return redisCli
      .zrange(key,start,end)
      .fail onError

  @getUserById: (id) -> return retrieve(id)
  @getUserBySession: (session) -> new User()

module.exports = User
