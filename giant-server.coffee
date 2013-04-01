express = require('express')
app = express.createServer()
socket = require('socket.io')
cradle = require 'cradle'

app.configure () ->
	app.use(express.static(__dirname + '/'))
  
app.use(express.bodyParser());

server = app.listen(8080)
io = socket.listen(server)


db = new(cradle.Connection)().database('starwars')
db.exists (err, exists) ->
	if (err)
		console.log "[Server][CouchDB] Error checking for db existance #{err}" 
	else if (exists)
		"[Server][CouchDB] DB exists, great!" 
	else
		console.log "[Server][CouchDB] DB not existing, but don't worry.."
		db.create()
		console.log "[Server][CouchDB] I created it." 

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
	res.send(giantProblem)
  
io.sockets.on 'connection', (socket) ->
	socket.on 'set nickname', (name) ->
		socket.set 'nickname', name, () ->
			socket.emit('ready', {})
	socket.on 'getProblemInstance', () ->
		socket.get 'nickname', (err, name) ->
			console.log "[Server][Websocket] Sending problem instance to #{name}"
		socket.emit('sendingProblemInstance', giantProblem)
	  
	socket.on 'postingProblemSolution', (result) ->
		socket.get 'nickname', (err, name) ->
			console.log "[Server][Websocket] Got problem result from #{name}"
			# console.log result
	 