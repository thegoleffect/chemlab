var zmq = require('zmq');
var socket = zmq.socket('pull');

socket.connect('tcp://127.0.0.1:3000');
console.log('Consumer bound to port 3000');

socket.on('message', function(msg){
  console.log('work: %s', msg.toString());
})