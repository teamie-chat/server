Thread      = require "./Thread.js"
Q           = require "q"
_           = require "lodash"

redisCli    = null

REDIS_KEYS  =
  ID_GEN              : "user:%d:generator"
  USER_DETAILS        : "user:%d"
  USER_THREADS        : "user:%d:threads"
  USER_SESSION        : "user:session:%s"

isValid = ->
  return true

class User
  update = ->
  create = ->
  save = ->

  constructor: (@id,@name,@profileImage,@threads) ->
  save: () ->
    if @id?
      @id = ID_GEN
      create()
    else
      update()
  subscribe: (threadId) ->
  unsubscribe: (threadId) ->
  getSession: () ->
  setSession: () ->
  @getUserById: (id) ->

module.exports = (aRedisCli) ->
  redisCli = aRedisCli
  return User
