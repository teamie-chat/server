Thread          = require "./thread.js"
Q               = require "q"
redisCli        = null

REDIS_KEYS      =
  THREAD_DETAILS    : "thread:%s"
  THREAD_MESSAGES   : "thread:%s:messages"

THREAD_TYPES    =
  ONE_ONE_THREAD    : "oneOneThread"

ID_REGEXP       = "one.one.thread:%d:%d"

isValid = ->

class OneOneThread extends Thread
  user1Id: null
  user2Id: null
  type: "OneOneThread"
  constructor: (id,msgs,@user1Id,@user2Id) ->
    super id, msgs, THREAD_TYPES.ONE_ONE_THREAD

  @findThreadById: ->


module.exports = (dbConn) ->
  if not redisCli?
    redisCli = dbConn
  return Thread
