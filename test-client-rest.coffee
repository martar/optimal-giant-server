io = require('socket.io-client')
fancyNickname = require('./fancy-nickname')
$ = require('jquery')
SERVER_URL = 'http://localhost:8080/'

        
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
			computation(data)
		error: (evt) ->
			console.log "[Client][REST]  Error getting the prolem instance: #{evt}"

postProblemSolved = (result) ->
	console.log "[Client][REST]  Sendng result to server"
	$.ajax
		type: 'POST'
		url: SERVER_URL + "slalom"
		data: result
		dataType: "json"
		ContentType: "application/json; charset=UTF-8"
		success: (data) -> 
			console.log "[Client][REST] Result posted succesfully: #{data}" 
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
		postProblemSolved(result)
	

	
getProblemInstance()
	
		
