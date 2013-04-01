express = require 'express'
socket = require 'socket.io'
cradle = require 'cradle'

app = express.createServer()

app.configure () ->
	app.use(express.static(__dirname + '/'))
  
app.use(express.bodyParser())

server = app.listen(8080)
io = socket.listen(server)

DATABASE_NAME = "giant1"
GIANT_PROBLEM_TYPE = "GIANT_PROBLEM"
SOLVED_STATUS = "SOLVED"
NOT_SOLVED_STATUS = "NOT_SOLVED"

db = new(cradle.Connection)().database(DATABASE_NAME)

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
	db.save '_design/problems', {
		all: {
			map: (doc) ->
				if (doc.type)
					emit(doc.type, doc)
		},
		not_solved: {
			map: (doc) ->
				if (doc.type && doc.status == 'NOT_SOLVED')
					emit(doc.type, doc)
		}
	}		

getFirstProblem = (fun) ->
	db.view 'problems/all', (err, res) ->
		if err
			console.log "[Server][CouchDB] Fail to get all problems"
		else
			fun(res[0])
			res.forEach (r) ->
				console.log r
	
saveToDb = (problem) ->
	console.log problem
	problem.type = GIANT_PROBLEM_TYPE
	problem.status = NOT_SOLVED_STATUS
	db.save problem, (err, res) ->
		if (err)
			console.log err
		else
			console.log "[Server][CouchDB] I saved the problem instance."
			
			
giantProblem = {
    "id": "trol1",
	"desc": "Dear client, this is a giant problem for you to solve",
	"gates": [],
	"params": {}
}

###
Post the problem instance that shall be stored in the db and distribite to clients that want to resolve it.
###
app.post '/problem', (req, res) ->
	console.log "[Server][REST] Got problem instance proposition"
	console.log req.body
	saveToDb(req.body)
	res.send({})
  
###
Post the result of solving problem instance by the client
###
app.post '/slalom', (req, res) ->
	console.log "[Server][REST] Got problem result."
	res.send({ msg: "Thanks"})

###
Return the problem instance for the client to solve
###
app.get '/slalom', (req, res) ->
	console.log "[Server][REST] Sending problem instance."
	getFirstProblem (giantProblem) ->
		res.send(giantProblem)
  
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
			# console.log result