$ = require('jquery')
SERVER_URL = 'http://giant-server.herokuapp.com:80/' ? 'http://localhost:5000/'


giantProblem = {
	"giantGates" : [[3,10],[-5,30],[4,50],[-4,65],[-16,80],[-6,100],[-13,120],[-10,135]]
		# masks that point out which gates are the closed gates(1) and which are reguklar, open gates(0)
	"closedGates" : [0,0,0,0,0,0,0,0]
	"hasLeftSidePollGates" : [0,1,0,0,1,0,1,0]
}

giantProblem2 = {
	"giantGates" : [[3,10],[-5,30],[4,50],[4,60],[4,70],[-6,100],[13,120],[-10,135]]
		# masks that point out which gates are the closed gates(1) and which are reguklar, open gates(0)
	"closedGates" : [0,0,1,1,1,0,0,0]
	"hasLeftSidePollGates" : [0,1,0,1,0,1,0,1]
}

giantProblem3 = {
	"giantGates" : [[3,10],[-5,30],[4,50],[4,60],[4,70],[-6,100],[-5,110],[10,135]]
		# masks that point out which gates are the closed gates(1) and which are reguklar, open gates(0)
	"closedGates" : [0,0,1,1,1,0,0,0]
	"hasLeftSidePollGates" : [0,1,0,1,0,1,1,0]
}

submitProblem = () ->
	console.log "[Client][REST] Submitting problem instance proposition to server"
	$.ajax
		type: 'POST'
		url: SERVER_URL + "problem"
		data: giantProblem3
		dataType: "json"
		ContentType: "application/json; charset=UTF-8"
		success: (data) -> 
			console.log data
			console.log "[Client][REST] Submitted succesfully" 
		error: (evt) ->
			console.log "[Client][REST] Error submitting: #{evt}"

submitProblem()
	
		
