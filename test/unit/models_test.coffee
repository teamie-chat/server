logger        = require "../../.app/logger.js"
_             = require 'lodash'
Q             = require 'q'
redis         = require 'redis'

redisConfig   =
  server: "localhost"
  port: 6379
  auth_pass: null
  database: 99

TEST_DB       = 11
DEBUG_LEVEL   = "debug"

Q.longStackSupport = true
logger.transports.console.level = DEBUG_LEVEL

oriRedisCli   = redis.createClient()


ModelSettings = require '../../.app/models/ModelSettings.js'
ModelSettings.setRedisCli(oriRedisCli)
redisCli = ModelSettings.getRedisCli()

onError = (err) -> logger.error typeof err

redisCli
  .on("error")
  .then(onError)
  .done()

User          = require '../../.app/models/User.js'
Thread        = require '../../.app/models/Thread.js'
OneOneThread  = require '../../.app/models/OneOneThread.js'

# a = new OneOneThread()
#
#
# a.user1Id = 1
#
# a.user2Id = 2
#
# a
#   .save()
#   .then((obj)->
#     logger.debug "Saved thread: ", obj
#   )
#   .then(()->
#      OneOneThread.getOneOneThreadByUsers(2,1)
#   )
#   .then((thread)->
#     logger.debug "Get thread: ", thread
#     tmp = new User()
#     tmp.id = 1
#     return tmp.getThreadsIds(0,-1)
#   )
#   .then (threads)->
#     logger.debug "Thread ids list: ", threads
#   .done()
#
# a
#   .sendMessage({
#     hoho: "heh1"
#   })
#   .then ()->
#     a
#       .sendMessage(
#         hoho: "heh2"
#       )
#   .then ()->
#     a.getMessages(0,1)
#   .then (msgs)->
#     logger.debug "Messages:", JSON.stringify(msgs)
#   .done()
#
# redisCli.flushdb()



exports.start = (test)->
  redisCli
    .on "connect"
    .then ()->
      return redisCli.select(TEST_DB)
    .then ()->
      redisCli.flushdb
      logger.log "Done set up"
      test.done()
    .done()

tmpUserId = null

exports.users = {
  createValidUser: (test) ->
    test.expect(3)

    user = new User()
    user.name = "Foo"
    user.profileImage = "Bar"
    user
      .save()
      .then (user)->
        test.equal user.name,'Foo', "Name == Foo"
        test.equal user.profileImage,'Bar', "Name == Bar"
        test.equal typeof user.id, "number", "Id is numberic"
        tmpUserId = user.id
      .fail onError
      .finally ()->
        test.done()
      .done()

  getUserByValidId: (test) ->
    test.expect(3)
    User
      .getUserById(tmpUserId)
      .then (user)->
        test.equal user.name,'Foo', "Name == Foo"
        test.equal user.profileImage,'Bar', "profileImage == Bar"
        test.equal user.id, tmpUserId, "Id is numberic"
        test.done()
      .done()
  getUserByIdNotFound: (test) ->
    test.expect(1)
    User
      .getUserById(1234)
      .then (user)->
        test.equal user, null, "No user with id 999"
        test.done()
      .done()
  deleteUser: (test) ->
    test.expect(1)
    User
      .getUserById(tmpUserId)
      .then (user)->
        return user.delete()
      .then (result)->
        test.equal result,true, "Delete user #{tmpUserId} successfully"
        test.done()
      .fail onError
      .done()
}


exports.tear = (test)->
  redisCli.flushdb()
  redisCli.end()
  test.done()

