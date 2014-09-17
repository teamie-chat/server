Q           = require "q"
redis       = require "redis"
dbConn      = null

# ModelLoader loads models in drupal chat by injecting a redis client into them. 
# The redis client is transformed by q so their methods return promises instead of callback.
#
class ModelLoader
  
  # wrap all callback-style redisCli methods
  # in promise-style ones
  # @param {object} redisCli the redis cli
  # @return {object} and object with all query methods redis cli has, with origin refers to the original redisCli
  #
  redisQTransformer = (redisCli) -> {
      origin: redisCli
      flushdb: redisCli.flushdb

      get: Q.nbind(redisCli.get,redisCli)
      set: Q.nbind(redisCli.set,redisCli)
      hmset: Q.nbind(redisCli.hmset,redisCli)
      hgetall: Q.nbind(redisCli.hgetall,redisCli)
      incr: Q.nbind(redisCli.incr,redisCli)
    }


  # set redis client
  # @param {object} cli redis client connection
  # @return {object} this model loader instance
  #
  setRedisCli: (redisCli) ->
    dbConn = redisCli
    return @


  # inject the redis client into the model and return it, to be called after setRedisCli only
  # @param {string} name the model name
  # @return {object} the model class
  #
  model: (name) ->
    throw Error("Redis Client is not set, call setRedisCli first") if not dbConn?
    require("./#{name}.js")(redisQTransformer(dbConn))

  # inject the redis client into the models and return it, to be called after setRedisCli only
  # @param {array} names the model names
  # @return {object} an array of model classes
  #
  models: (names) ->
    throw Error("Redis Client is not set, call setRedisCli first") if not dbConn?

    names = [names] if names instanceof String
    models = []
    names.forEach (name) -> models.push(require("./#{name}.js")(redisQTransformer(dbConn)))
    return models

module.exports = new ModelLoader()
