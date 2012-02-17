cluster = require('cluster')
express = require('express')
routes = require('./routes')

app = module.exports = express.createServer()

app.configure(() ->
  app.use(express.logger())
  app.use(express.bodyParser())
  app.use(express.methodOverride())
  app.use(app.router)
  app.use(express.static(__dirname + '/public'))
)

app.configure('development', () ->
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))
)

app.configure('production', () ->
  app.use(express.errorHandler())
)

app.get('/', routes.index)
app.get('/seppuku', (req, res) ->
  res.send("It has been an honor to serve you, master.")
  process.send({jsonrpc: "2.0", method: 'kill', params: [process.pid]})
)

app.listen(3000, () ->
  # console.log("Express server listening on port %d in %s mode", 
  #   app.address().port, 
  #   app.settings.env)
  process.send({cmd: "starting", pid: process.pid})
)
