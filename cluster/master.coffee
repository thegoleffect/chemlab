cluster = require('cluster')
CPUCOUNT = require('os').cpus().length
WorkerPool = require("./lib/workerpool")
Workers = new WorkerPool({maxCount: CPUCOUNT})

if cluster.isMaster
  Workers.spawnAll()
  process.on('exit', Workers.killAllSync)
else
  require("./app")