_ = require("underscore")
cluster = require("cluster")

class WorkerPool
  defaults: {
    maxCount: 2
  }
  
  constructor: (options = {}) ->
    # Object.merge(@defaults, @options) # .merge() comes from Sugar
    @options = _.extend({}, @defaults, options)
    @workers = {}
    
    self = this
    cluster.on('death', @bury)
    cluster.on('death', @spawn)
  
  list: () => _.keys(@workers)
  
  bury: (worker) =>
    console.log("burying #{worker.pid}")
    delete @workers[worker.pid]
    
    if _.keys(@workers).length == 0
      require("util").debug("all workers are dead, exiting")
      return process.exit(0)
  
  spawnAll: () =>
    @spawn() for i in [1..@options.maxCount]
  
  spawn: (worker = null) =>
    self = this
    w = cluster.fork()
    w.on('message', (msg) ->
      if msg.jsonrpc? and msg.jsonrpc == "2.0"
        console.log(msg.method, msg.params)
        return self[msg.method].apply(self, msg.params)
        
      console.log(msg)
    )
    return @workers[w.pid] = w
    
  # respawn: (worker) ->
    # self = this
    # console.log("@respawn() called:")
    # console.log("@workers ", _.keys(@workers))
    # console.log("@dead: ", @dead)
    # console.log("@undead: ", @undead)
    # # process.send({msg: "worker #{worker.pid} died", pid: worker.pid})
    # if worker.pid in _.keys(@dead)
    #   delete @dead[worker.pid]
    #   delete @workers[worker.pid]
      
    #   if worker.pid in _.keys(@undead)
    #     delete @undead[worker.pid]
    #     spawn()
    #   else
    #     # Do something?
      
    #   console.log(@workers)
    # else
    #   # @kill(worker.pid) # TODO: fix the race condition here, use a kill queue or something
    #   @dead[worker.pid] = 1
    #   @undead[worker.pid] = 1
    #   setTimeout((() ->
    #     self.kill(worker.pid) if not self.dead[worker.pid]?
    #   ), 1000)
  
  kill: (pid = null, respawn = false) =>
    console.log('inside kill', pid) #
    throw "kill requires a process id (pid)" if not pid?
    throw "No such worker found @ pid = #{pid}" if not @workers[pid]?
    
    # @dead[pid] = 1
    # @undead[pid] = 1 if respawn
    @workers[pid].kill()
    
  killAllSync: () =>
    for own pid, thread of @workers
      # @dead[pid] = 1
      @kill(pid)
      # TODO: check for cluster.on('death'), match pid
  
  end: () =>
    cluster.removeListener('death', @spawn)
    @killAllSync()
    process.exit(1) # TODO: move this
  

module.exports = WorkerPool