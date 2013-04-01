$ = require('jquery')
SERVER_URL = 'http://localhost:8080/'

giantProblem = {
	"desc": "Wow",
	"gates": [],
	"params": {}
}

submitProblem = () ->
	console.log "[Client][REST] Submitting problem instance proposition to server"
	$.ajax
		type: 'POST'
		url: SERVER_URL + "problem"
		data: giantProblem
		dataType: "json"
		ContentType: "application/json; charset=UTF-8"
		success: (data) -> 
		console.log "[Client][REST] Submitted succesfully" 
		error: (evt) ->
			console.log "[Client][REST] Error submitting: #{evt}"

submitProblem()
	
		
