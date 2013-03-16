io = require('socket.io-client')
fancyNickname = require('./fancy-nickname')

SERVER_URL = 'http://localhost:80'

socket = io.connect(SERVER_URL)
socket.on 'connect', () ->
    socket.emit('set nickname', fancyNickname.gen())
socket.on 'ready', (giantInstance) ->
	console.log "Thx for the gates and slope configuration, I will do my best to find the good track!"
	console.log giantInstance
	socket.emit('ack', "I will try to fint the track!")
	# all our computation
	result = {
		"my_optimal_track": [],
		"time": 32.23
	}
	socket.emit('solved', result)