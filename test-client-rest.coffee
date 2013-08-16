io = require('socket.io-client')
fancyNickname = require('./fancy-nickname')
$ = require('jquery')

SERVER_URL = 'http://giant-server.herokuapp.com:80/' ? 'http://localhost:5000/'

        
wait = (milisec, fun) ->
	setTimeout(fun, milisec)
	
getProblemInstance = () ->
	console.log "[Client][REST]  Quering for problem instance.."
	$.ajax
		type: 'GET'
		url: SERVER_URL + "slalom"
		dataType: "json"
		success: (data) -> 
			console.log "[Client][REST] Got the problem instance from the server."
			console.dir data
			computation(data)
		error: (evt) ->
			console.log "[Client][REST]  Error getting the prolem instance: #{evt}"

getResult = () ->
	console.log "[Client][REST]  Quering for result instance.."
	$.ajax
		type: 'GET'
		url: SERVER_URL + "result"
		dataType: "json"
		success: (data) -> 
			console.dir data
		error: (evt) ->
			console.log "[Client][REST]  Error getting the result instance: #{evt}"
			console.dir evt
			
postProblemSolved = (result) ->
	console.log "[Client][REST] Sendng result to server"
	console.dir result
	$.ajax
		type: 'POST'
		url: SERVER_URL + "slalom"
		data: result
		dataType: "json"
		ContentType: "application/json; charset=UTF-8"
		success: (data) -> 
			console.log "[Client][REST] Result posted succesfully"
			console.dir data
		error: (evt) ->
			console.log "[Client][REST] Error posting the result: #{evt}"

			
computation = (data) ->
	console.log "[Client][REST] Starting computations.."
	wait 2000, ->
		console.log "[Client][REST] Finished computations."
		result = {
			"my_optimal_track": [],
			"time": 32.23
		}
		result.problem_instance = data.id
		postProblemSolved(result)
	

	
# getProblemInstance()
getResult()	
		
