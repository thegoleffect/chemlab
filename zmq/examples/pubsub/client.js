var zmq = require('zmq');
var socket = zmq.socket('sub');

socket.connect('tcp://127.0.0.1:3000');
console.log('Subscriber bound to port 3000');
socket.subscribe("CHANNEL")

socket.on('message', function(msg){
  console.log('incoming data: %s', msg.toString());
})