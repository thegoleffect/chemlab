_ = require("underscore")
cluster = require("cluster")
CPUCOUNT = require('os').cpus().length

class WorkerPool
  defaults: {
    maxCount: 2
  }
  
  constructor: (@maxCount = CPUCOUNT) ->
  # constructor: (options = {}) ->
    # Object.merge(@defaults, @options) # .merge() comes from Sugar
    # @options = _.extend({}, @defaults, options)
    @workers = {}
    
    cluster.on('death', @bury)
    cluster.on('death', @spawn)
    
    console.log("== Functions in WorkerPool ==")
    for own key, value of this
      console.log(key) if typeof value == "function"
    console.log("== /Functions in WorkerPool ==")
  
  list: () => _.keys(@workers)
  
  bury: (worker) =>
    console.log("burying #{worker.pid}")
    delete @workers[worker.pid]
    
    # TODO: needs better generalization:  @is_shutting_down
    #    potential for all workers to be killed but going to be spawned = exit
    if _.keys(@workers).length == 0
      require("util").debug("all workers are dead, exiting")
      return process.exit(0)
  
  reaper: () =>
    # Population Control: (un)gracefully restart long running workers
    @reapTimer = setInterval(() =>
      @reap()
    , @defaults.reapTime)
  
  reap: () =>
    # TODO: 
    # for own pid, thread of @workers
      
  start: () =>
    @spawn() for i in [1..@maxCount]
  
  spawn: (worker = null) =>
    self = this
    w = cluster.fork()
    w.on('message', (msg) ->
      # TODO: flesh out further, add in support for biz-logic fns? 
      #   perhaps: supply msg handler through class instantiation
      if msg.jsonrpc? and msg.jsonrpc == "2.0"
        console.log(msg.method, msg.params)
        return self[msg.method].apply(self, msg.params)
        
      console.log(msg)
    )
    return @workers[w.pid] = w
  
  kill: (pid = null, respawn = false) =>
    throw "kill requires a process id (pid)" if not pid?
    throw "No such worker found @ pid = #{pid}" if not @workers[pid]?
    
    @workers[pid].kill()
    
  killAll: () =>
    @kill(pid) for own pid, thread of @workers
  
  end: () =>
    cluster.removeListener('death', @spawn)
    @killAll()

module.exports = WorkerPool