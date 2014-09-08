Q           = require "q"
redisCli    = null

REDIS_KEYS  =
  THREAD_DETAILS       : "thread:%s"
  THREAD_MESSAGES      : "thread:%s:messages"

class Thread
  id: null
  msgs: []
  type: ""
  constructor: (@id,@msgs,@type) ->

  @findThreadById: (id)->
  @findThreadByIds: (ids)->

module.exports = (dbConn) ->
  if not redisCli?
    redisCli = dbConn
  return Thread
