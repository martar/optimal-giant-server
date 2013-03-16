io = require('socket.io').listen(80)


giantProblem = {
	"desc": "Dear client, this is a giant problem for you to solve",
	"gates": [],
	"params": {}
}

io.sockets.on 'connection', (socket) ->
  socket.on 'set nickname', (name) ->
    socket.set 'nickname', name, () ->
      socket.emit('ready', giantProblem)

  socket.on 'ack', (message) ->
    socket.get 'nickname', (err, name) ->
      console.log('Client started computation: ', name)
      console.log(message)
	  
  socket.on 'solved', (message) ->
    socket.get 'nickname', (err, name) ->
      console.log('Client solved computation: ', name)
      console.log(message)
	  
  socket.on 'failed to solve', (message) ->
    socket.get 'nickname', (err, name) ->
      console.log('Client failed to solve computation: ', name)
      console.log(message)