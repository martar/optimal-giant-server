$ = require('jquery')
SERVER_URL = 'http://localhost:8080/'

giantProblem = {
	"giantGates" : [[3,10],[-5,30],[4,50],[-4,65],[-16,80],[-6,100],[-13,120],[-10,135]]
		# masks that point out which gates are the closed gates(1) and which are reguklar, open gates(0)
	"closedGates" : [0,0,0,0,0,0,0,0]
}

###
UWAGA!! Podczas przesy³ania problemu przez submitProblem nie wiem dlaczego nastêuje konwersja wszystkich intów na stringi. 
I to powoduje, ¿e wszystko jest Ÿle..
Nie znalaz³am w ³¹twy sposób dlaczego tak siê dzieje ani jak temu zaradziæ, wiec submituje taki oto payload po prostu z palca do COuchdb
(A raczej przez HTTP Clienta w Chromie)
 {
	"giantGates" : [[3,10],[-5,30],[4,50],[-4,65],[-16,80],[-6,100],[-13,120],[-10,135]],
	"closedGates" : [0,0,0,0,0,0,0,0],
        "type" : "GIANT_PROBLEM",
        "status" : "NOT_SOLVED"
}

###

submitProblem = () ->
	console.log "[Client][REST] Submitting problem instance proposition to server"
	console.log giantProblem
	$.ajax
		type: 'POST'
		url: SERVER_URL + "problem"
		data: giantProblem
		dataType: "json"
		ContentType: "application/json; charset=UTF-8"
		success: (data) -> 
			console.log data
			console.log "[Client][REST] Submitted succesfully" 
		error: (evt) ->
			console.log "[Client][REST] Error submitting: #{evt}"

submitProblem()
	
		
