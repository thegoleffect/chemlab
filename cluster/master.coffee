cluster = require('cluster')

if cluster.isMaster
  WorkerPool = require("./lib/workerpool")
  Workers = new WorkerPool()
  
  Workers.start()
  process.on("SIGINT", Workers.end)
  process.on('exit', Workers.end)
  
  setInterval((() ->
    console.log(Workers.list())
  ), 1000)
else
  require("./app") # TODO: make this parametric?