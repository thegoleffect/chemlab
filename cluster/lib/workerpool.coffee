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
    @dead = {}
    @undead = {}
    
    self = this
    cluster.on('death', (worker) ->
      self.respawn(worker)
    )
  
  spawnAll: () ->
    @spawn() for i in [1..@options.maxCount]
  
  spawn: () ->
    self = this
    w = cluster.fork()
    w.on('message', (msg) ->
      if msg.jsonrpc? and msg.jsonrpc == "2.0"
        console.log(msg.method, msg.params)
        return self[msg.method].apply(self, msg.params)
        
      console.log(msg)
    )
    return @workers[w.pid] = w
    
  respawn: (worker) ->
    # process.send({msg: "worker #{worker.pid} died", pid: worker.pid})
    if worker.pid in _.keys(@dead)
      delete @dead[worker.pid]
      
      if worker.pid in _.keys(@undead)
        delete @undead[worker.pid]
        spawn()
      else
        # Do something?
      
      console.log(@workers)
    else
      @kill(worker.pid) # TODO: fix the race condition here, use a kill queue or something
  
  kill: (pid = null, respawn = false) ->
    console.log('inside kill', pid) #
    throw "kill requires a process id (pid)" if not pid?
    throw "No such worker found @ pid = #{pid}" if not @workers[pid]?
    
    @dead[pid] = 1
    @undead[pid] = 1 if respawn
    @workers[pid].kill()
    
  killAllSync: () ->
    for own pid, thread of @workers
      @dead[pid] = 1
      @kill(pid)
      # TODO: check for cluster.on('death'), match pid
    process.exit(1) # TODO: move this
  

module.exports = WorkerPool