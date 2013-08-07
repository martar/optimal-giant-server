express = require 'express'
socket = require 'socket.io'
cradle = require 'cradle'

app = express.createServer()

app.configure () ->
	app.use(express.static(__dirname + '/'))
  
app.use(express.bodyParser())

server = app.listen(process.env.PORT || 5000)
io = socket.listen(server)

DATABASE_NAME = "giant"
GIANT_PROBLEM_TYPE = "GIANT_PROBLEM"
SOLVED_STATUS = "SOLVED"
NOT_SOLVED_STATUS = "NOT_SOLVED"

DB_URL = process.env.DB_URI  ? "127.0.0.1"
# DB_URL = 'https://giant:ala123@giant.cloudant.com'
DB_PORT = process.env.DB_PORT  ? "5984"
# DB_PORT = 443

db = new(cradle.Connection)(DB_URL, DB_PORT, {
	cache: true,
	raw: false
}).database(DATABASE_NAME)

db.exists (err, exists) ->
	if (err)
		console.log "[Server][CouchDB] Error checking for db existance #{err}" 
	else if (exists)
		"[Server][CouchDB] DB exists, great!" 
		createDbViews(db)
	else
		console.log "[Server][CouchDB] DB not existing, but don't worry.."
		db.create()
		createDbViews()
		console.log "[Server][CouchDB] I created it." 

createDbViews = () ->
	# be careful not to use CONSTANTS in the equasion. Cuz this functions are send as they are (without binding to availables variables 	 
	db.save '_design/problems', {
		all: {
			map: (doc) ->
				if (doc.type == 'GIANT_PROBLEM')
					emit(doc.type, doc)
		},
		not_solved: {
			map: (doc) ->
				if (doc.type  == 'GIANT_PROBLEM' && doc.status == 'NOT_SOLVED')
					emit(doc.type, doc)
		},
		results: {
			map: (doc) ->
				if (doc.type  == 'GIANT_RESULT')
					emit(doc.problem_id, parseFloat(doc.bestTime))
			reduce: "_stats"
			
		},
		group: {
			map: (doc) ->
				if (doc.type  == 'GIANT_RESULT')
					emit(doc.problem_id, 1)
			reduce :(key, values, rereduce) ->
				sum(values)
			
		}
	}


getById = (id, fun) ->
	db.get id, (err, res) ->
		if err
			console.log err
		else
		    console.log res
			fun(res)

getFirstNeverSolvedProblem = (fun) ->
	db.view 'problems/not_solved', (err, res) ->
		if err
			console.log "[Server][CouchDB] Fail to get a not solved problem"
		else
			if res.length == 0
				# all problem were solved at least once
				console.log "[Server][CouchDB] All problems were solved at least once"
				getFirstProblem fun
			else
				console.log "[Server][CouchDB] Returning problem that was never solved before"
				fun(res[0].value)
			
# get the giant problem
getFirstProblem = (fun) ->
	db.view 'problems/group', {group: true}, (err, res) ->
		if err
			console.log "[Server][CouchDB] Fail to get a problem"
		else
			min = 0
			min_id = null
			if res.length == 0
				console.log "[Server] Fail to get any problem either not solved or solved"
				return
			else
				for result,i in res
					if result.value < min or i == 0
						min = result.value
						min_id = result.key
				console.log "[Server] Returning probelm that was solved lowest number of time"
				getById min_id, fun

getResults = (fun) ->
	db.view 'problems/results', {group: true},(err, res) ->
		if err
			console.log "[Server][CouchDB] Fail to get all results"
			console.dir err
		else
			console.log "[Server][CouchDB] Returning best result"
			fun(res)

			
saveToDb = (problem) ->
	console.log problem.closedGates.length
	for i in [0...problem.closedGates.length]
		problem.closedGates[i] = parseInt(problem.closedGates[i], 10)
	for i in [0...problem.giantGates.length]
		x =  parseInt(problem.giantGates[i][0], 10)
		y =  parseInt(problem.giantGates[i][1], 10)
		problem.giantGates[i] = [x,y]
	for i in [0...problem.hasLeftSidePollGates.length]
		problem.hasLeftSidePollGates[i] = parseInt(problem.hasLeftSidePollGates[i][0], 10)
	problem.type = GIANT_PROBLEM_TYPE
	problem.status = NOT_SOLVED_STATUS
	db.save problem, (err, res) ->
		if (err)
			console.log err
		else
			console.log "[Server][CouchDB] I saved the problem instance."
			

saveResultToDb = (result) ->
	db.save result, (err, res) ->
		if (err)
			console.log err
		else
			console.log "[Server][CouchDB] I saved the result instance."
			console.log result.problem_id
			console.log typeof(result.problem_id)
			db.merge result.problem_id, { status: SOLVED_STATUS } , (err, doc) ->
				if err
					console.log "[Server][CouchDB] Problem updating the problem instance with the new solution"
				else
					console.log "[Server][CouchDB] I updated the problem instance with the new solution"
			
			
giantProblem = {
    "id": "trol1",
	"desc": "Dear client, this is a giant problem for you to solve",
	"gates": [],
	"params": {}
}

###
Required in order to allow Cross-origin resource sharing (client that request resurces is in other domain that the server is) 
###
app.all '/*', (req, res, next) ->
  res.header("Access-Control-Allow-Origin", "*")
  res.header("Access-Control-Allow-Headers", "X-Requested-With")
  next()

###
Post the problem instance that shall be stored in the db and distribite to clients that want to resolve it.
###
app.post '/problem', (req, res) ->
	console.log "[Server][REST] Got problem instance proposition"
	console.log req.body
	
	saveToDb(req.body)
	res.send({})
  

app.get '/result/:problem_id', (req, res) =>
	console.log "[Server][REST] Quering for best result for a given problem"
	getResults (results) =>
		for result in results
			if result.key == req.params.problem_id
				console.log "[Server][REST] Min result for this problem is " + result.value.min
				res.send({bestTimeInDb: result.value.min})
  
app.get '/result', (req, res) =>
	console.log "[Server][REST] Quering for number of results."
	getResults (result) =>
		res.send(result)
				
				
###
Post the result of solving problem instance by the client
###
app.post '/slalom', (req, res) ->
	console.log "[Server][REST] Got problem result."
	console.dir req.body
	saveResultToDb req.body
	res.send({ msg: "Thanks"})
	

###
Return the problem instance for the client to solve
###
app.get '/slalom', (req, res) ->
	getFirstNeverSolvedProblem (giantProblem) ->
		console.dir giantProblem
		res.send(giantProblem)
		console.log "[Server][REST] Sending problem instance."
  
io.sockets.on 'connection', (socket) ->
	socket.on 'set nickname', (name) ->
		socket.set 'nickname', name, () ->
			socket.emit('ready', {})
	socket.on 'getProblemInstance', () ->
		socket.get 'nickname', (err, name) ->
			console.log "[Serve][Websocket] Sending problem instance to #{name}"
			getFirstProblem (giantProblem) ->
				socket.emit('sendingProblemInstance', giantProblem)
	  
	socket.on 'postingProblemSolution', (result) ->
		socket.get 'nickname', (err, name) ->
			console.log "[Server][Websocket] Got problem result from #{name}"
			console.dir result