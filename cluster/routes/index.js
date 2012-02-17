
/*
 * GET home page.
 */

exports.index = function(req, res){
  process.send({logLevel: "debug", cmd: "req", pid: process.pid})
  res.send("Ohai.")
};