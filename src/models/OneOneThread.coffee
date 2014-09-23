Util            = require "util"
Thread          = require "../models/Thread.js"

logger          = require "../logger.js"
Q               = require "q"
_               = require "lodash"

redisCli        = require("./ModelSettings").getRedisCli()
oriRedisCli     = redisCli.origin

REDIS_KEYS      =
  THREAD_DETAILS    : "thread:%s"
  THREAD_MESSAGES   : "thread:%s:messages"
  USER_ID_GEN         : "user:%d:generator"
  USER_DETAILS        : "user:%d"
  USER_THREADS        : "user:%d:threads"
  USER_SESSION        : "user:session:%s"

THREAD_TYPES    =
  ONE_ONE_THREAD    : "oneOneThread"

ID_FORMAT       = "one.one.thread:%d:%d"

# validate a thread
# @param {thread} the one.one.thread to check
# @return {array} return array of erros messages
#
isValid = (thread)->
  err = []
  err.push "User1 Id is invalid" if typeof thread.user1Id isnt "number"
  err.push "User2 Id is invalid" if typeof thread.user2Id isnt "number"

  return err

onError = (err) ->
  logger.error err
  throw err

class OneOneThread extends Thread

  update = () ->

    if isValid(@).length
      return

    min = _.min [@user1Id,@user2Id]
    max = _.max [@user1Id,@user2Id]
    @id = Util.format(ID_FORMAT,min,max)
    threadKey = Util.format(REDIS_KEYS.THREAD_DETAILS,@id)
    user1ThreadKey = Util.format(REDIS_KEYS.USER_THREADS,@user1Id)
    user2ThreadKey = Util.format(REDIS_KEYS.USER_THREADS,@user2Id)
    that = @

    Q
      .ninvoke(
        redisCli
          .multi()
          .hmset(
            threadKey
            "id", @id
            "user1Id", @user1Id
            "user2Id", @user2Id
            "type", @type
          )
          .zadd(
            user1ThreadKey
            new Date().getTime()
            @id
          )
          .zadd(
            user2ThreadKey
            new Date().getTime()
            @id
          ),"exec")
      .then ()-> that
      .fail onError

  constructor: (id, @user1Id,@user2Id) ->
    super id, THREAD_TYPES.ONE_ONE_THREAD

  Object.defineProperties @prototype,
    user1Id:
      get: -> @_user1Id
      set: (uid) ->
        return if typeof uid isnt "number"
        throw new Error "User1 id is already set to #{@user1Id?}" if @user1Id?

        @_user1Id = uid
        @id = Util.format(ID_FORMAT,@user1Id,@user2Id) if @user2Id?
        return @_user1Id
  Object.defineProperties @prototype,
    user2Id:
      get: -> @_user2Id
      set: (uid) ->
        return if typeof uid isnt "number"
        throw new Error "User2 id is already set" if @user2Id?

        @_user2Id = uid
        @id = Util.format(ID_FORMAT,@user1Id,@user2Id) if @user1Id?
  Object.defineProperties @prototype,
    type:
      get: -> THREAD_TYPES.ONE_ONE_THREAD
      set: (type) -> THREAD_TYPES.ONE_ONE_THREAD

  # save this thread
  # @return {OneOneThread} this thread
  #
  save: () ->
    return update.call(@)

  # static methods
  @getOneOneThreadByUsers: (user1Id,user2Id)->
    min = _.min [user1Id,user2Id]
    max = _.max [user1Id,user2Id]
    id = Util.format(ID_FORMAT,min,max)
    key = Util.format(REDIS_KEYS.THREAD_DETAILS,id)
    redisCli
      .hgetall(key)
      .then (obj)->
        if (obj?)
          obj.user1Id = parseInt(obj.user1Id)
          obj.user2Id = parseInt(obj.user2Id)
          tmp = new OneOneThread()
          return _.extend(tmp, obj)

        else
          throw new Error ("Thread now found")
      .fail onError



module.exports = OneOneThread
