var zmq = require('zmq');
var socket = zmq.socket('pub');

socket.bind('tcp://127.0.0.1:3000', function(err){
  if (err) throw err;
  
  console.log('Producer bound to port 3000');
  setInterval(function(){
    console.log('publishing some work');
    socket.send('CHANNEL some work');
  }, 3000)
});