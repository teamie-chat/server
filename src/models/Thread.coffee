Util            = require "util"
logger          = require "../logger.js"
Q               = require "q"
_               = require "lodash"

redisCli        = require("./ModelSettings").getRedisCli()
oriRedisCli     = redisCli.origin

REDIS_KEYS  =
  THREAD_DETAILS       : "thread:%s"
  THREAD_MESSAGES      : "thread:%s:messages"

onError = (err) ->
  logger.error err
  throw err

class Thread
  id: null
  type: ""
  constructor: (id,type) ->


  sendMessage: (msg) ->
    # return if not msg instanceof Message
    return if not @id? or not msg?

    serializedMsg = JSON.stringify(msg)
    key = Util.format(REDIS_KEYS.THREAD_MESSAGES,@id)

    return redisCli
      .lpush(key,serializedMsg)
      .fail onError

  getMessages: (start,end) ->
    key = Util.format(REDIS_KEYS.THREAD_MESSAGES,@id)
    return redisCli
      .lrange(key,start,end)
      .then (msgs)->
        return _.map msgs,(msg)->JSON.parse(msg)
      .fail onError


  @findThreadById: (id)->
  @findThreadByIds: (ids)->

module.exports = Thread
