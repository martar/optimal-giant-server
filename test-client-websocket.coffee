io = require('socket.io-client')
fancyNickname = require('./fancy-nickname')
$ = require('jquery')
SERVER_URL = 'http://localhost:8080/'
        
wait = (milisec, fun) ->
	setTimeout(fun, milisec)
	
socket = io.connect(SERVER_URL)
socket.on 'connect', () ->
    socket.emit('set nickname', fancyNickname.gen())
	
socket.on 'ready', () ->
	getProblemInstance()
	
socket.on 'sendingProblemInstance', (giantInstance) ->
	console.log "[Client][Websocket] Got the problem instance from the server."
	console.dir giantInstance
	computation()
	
getProblemInstance = () ->
	socket.emit('getProblemInstance', {})
	
postProblemSolved = (result) ->
	socket.emit('postingProblemSolution', result)
	socket.disconnect();

	
computation = (data) ->
	console.log "[Client][Websocket] Starting computations.."
	wait 2000, ->
		console.log "[Client][Websocket] Finished computations."
		result = {
			"my_optimal_track": [],
			"time": 32.23
		}
		postProblemSolved(result)