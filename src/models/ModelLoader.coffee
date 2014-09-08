redis       = require "redis"
redisConfig = null
dbConn      = null

ModelLoader = ->

ModelLoader.prototype.setRedisConfig = (config) ->
  redisConfig = config
  dbConn = redis.createClient(config)
ModelLoader.prototype.model = (name) ->
    require("./#{name}.js")(dbConn)


module.exports = new ModelLoader()
