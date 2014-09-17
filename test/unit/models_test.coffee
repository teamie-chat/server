logger        = require "../../.app/logger.js"
_             = require 'lodash'
Q             = require 'q'
redis         = require 'redis'
redisConfig   =
  server: "localhost"
  port: 6379
  auth_pass: null
  database: 99
redisCli      = redis.createClient()

ModelLoader   = require '../../.app/models/ModelLoader.js'
ModelLoader.setRedisCli(redisCli)
User          = ModelLoader.model("User")

logger.transports.console.level = ""


# _.extend exports,
exports.test_usermodel = {
  setUp: (cb) -> cb()

  tearDown: (cb) ->
    redisCli.flushdb()
    redisCli.end()
    cb()
  createValidUser: (test) ->
    test.expect(3)

    user = new User()
    user.name = "Foo"
    user.profileImage = "Bar"
    user
      .save()
      .then (user)->
        test.equal user.name,'Foo', "Name == Foo"
        test.equal user.profileImage,'Bar', "profileIamge == Bar"
        test.equal typeof user.id, "number", "Id is numberic"
        test.done()
      .done()
}
