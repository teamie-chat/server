redis       = require "redis"
redisConfig = null
dbConn      = null

class ModelLoader
  setRedisConfig: (config) ->
    redisConfig = config
    dbConn = redis.createClient(config)
  model: (name) -> 
    require("./#{name}.js")(dbConn)

module.exports = new ModelLoader()
