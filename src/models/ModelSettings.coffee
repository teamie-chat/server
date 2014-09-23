_               = require 'lodash'
Q               = require 'q'


RedisCliWrapper = (redisCli) ->
  return _.extend @, {
    origin: redisCli

    select: Q.nbind(redisCli.select,redisCli)
    on: Q.nbind(redisCli.on,redisCli)

    get: Q.nbind(redisCli.get,redisCli)
    set: Q.nbind(redisCli.set,redisCli)
    del: Q.nbind(redisCli.del,redisCli)
    hmset: Q.nbind(redisCli.hmset,redisCli)
    hgetall: Q.nbind(redisCli.hgetall,redisCli)
    incr: Q.nbind(redisCli.incr,redisCli)
    lpush: Q.nbind(redisCli.lpush,redisCli)
    lrange: Q.nbind(redisCli.lrange,redisCli)
    zrange: Q.nbind(redisCli.zrange,redisCli)
  }


class ModelSettings
  redisCli = null # the q-wrapped redisCli
  setRedisCli: (cli) ->
    RedisCliWrapper.prototype = cli
    redisCli = new RedisCliWrapper(cli)


  getRedisCli: () -> redisCli

module.exports = new ModelSettings()
