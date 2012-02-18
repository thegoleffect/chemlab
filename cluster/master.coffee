cluster = require('cluster')
CPUCOUNT = require('os').cpus().length
WorkerPool = require("./lib/workerpool")
Workers = new WorkerPool({maxCount: CPUCOUNT})

if cluster.isMaster
  Workers.spawnAll()
  process.on("SIGINT", Workers.end)
  process.on('exit', Workers.end)
  
  setInterval((() ->
    console.log(Workers.list())
  ), 1000)
else
  require("./app")