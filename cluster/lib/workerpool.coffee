_ = require("underscore")
cluster = require("cluster")

class WorkerPool
  defaults: {
    maxCount: 2
  }
  
  constructor: (options = {}) ->
    # Object.merge(@defaults, @options)
    @options = _.extend({}, @defaults, options)
    @workers = {}
  
  spawnAll: () ->
    for i in [1..@options.maxCount]
      w = cluster.fork()
      @workers[w.pid] = w
      
      w.on('message', (msg) ->
        console.log(msg)
      )
    cluster.on('death', @respawn)
    
  respawn: (worker) ->
    process.send({msg: "worker #{worker.pid} died", pid: worker.pid})
    delete @workers[worker.pid]
    
    w = createWorker()
    @workers[w.pid] = w
    
  killall: () ->
    for own pid, thread of @workers
      thread.kill()
  

module.exports = WorkerPool