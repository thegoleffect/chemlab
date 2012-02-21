var zmq = require('zmq');
var socket = zmq.socket('push');

socket.bindSync('tcp://127.0.0.1:3000');
console.log('Producer bound to port 3000');

setInterval(function(){
  console.log('sending work');
  socket.send('some work');
}, 3000)