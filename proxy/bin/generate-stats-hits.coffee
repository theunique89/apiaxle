#!/usr/bin/env coffee

_ = require "lodash"
async = require "async"
sinon = require "sinon"

{ Stats } = require "../../base/app/model/redis/stats"
{ ApiaxleProxy } = require "../apiaxle-proxy"

rand = ( arr ) ->
  index = Math.floor( ( Math.random() * arr.length ) )
  return arr[index]

api = new ApiaxleProxy()
api.script ( finish ) ->
  listers = []

  listers.push ( cb ) -> api.model( "apifactory" ).range 0, 1000, cb
  listers.push ( cb ) -> api.model( "keyfactory" ).range 0, 1000, cb

  async.series listers, ( err, [ apis, keys ] ) ->
    stats = api.model "stats"

    from = ( Date.now() - 172800000 ) # two days
    real = Date.now()                 # before we fiddle the clock

    clock = sinon.useFakeTimers from

    possible_types = [ "cached", "uncached", "error" ]
    possible_status = [ 200, 400, 404 ]

    key_pack = []

    for i in [ from..real ] by 5000
      redis_key = [ rand( apis ),
                    rand( keys ),
                    rand( possible_types ),
                    rand( possible_status ) ]

      do ( redis_key ) ->
        key_pack.push ( cb ) ->
          stats.hit redis_key..., ( err ) ->
            clock.tick 5000
            console.log( real - Date.now(), redis_key )
            return cb err, redis_key

    async.series key_pack, finish
