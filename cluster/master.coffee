cluster = require('cluster')
WorkerPool = require("./lib/workerpool")

CPUCOUNT = require('os').cpus().length
Workers = new WorkerPool({maxCount: CPUCOUNT})

if cluster.isMaster
  Workers.spawnAll()
  
  process.on('exit', Workers.killall)
else
  require("./app")