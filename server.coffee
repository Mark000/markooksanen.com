#setup Dependencies
connect = require 'connect'
	, express = require 'express'
	, io = require 'socket.io'
	, port = process.env.PORT || 8081

nodemailer = require 'nodemailer'

#Setup Express
server = express.createServer()
server.configure ->
	server.set 'views', __dirname + '/views'
	server.set 'view options', { layout: false }
	server.use connect.bodyParser()
	server.use express.cookieParser()
	server.use express.session { secret: "shhhhhhhhh!"}
	server.use connect.static __dirname + '/static'
	server.use server.router

#setup the errors
server.error (err, req, res, next) ->
	if err instanceof NotFound
		res.render '404.jade', { locals: { 
			title : '404 - Not Found'
			,description: ''
			,author: ''
			,analyticssiteid: 'UA-40412130-1' 
			},status: 404 }
	else 
		console.log 'err: ' +err.stack
		res.render '500.jade', { locals: { 
			title : 'The Server Encountered an Error'
			,description: 'an error occurred with stack: '+err.stack
			,author: ''
			,analyticssiteid: 'UA-40412130-1'
			,error: err 
			},status: 500 }
server.listen port

#Setup Socket.IO
io = io.listen server
io.sockets.on 'connection', (socket) -> 
	console.log 'Client Connected'
	socket.on 'message', (data) -> 
		socket.broadcast.emit 'server_message', data
		socket.emit 'server_message', data
	socket.on 'disconnect', () ->
		console.log 'Client Disconnected.'
	


###
///////////////////////////////////////////
//              Routes                   //
///////////////////////////////////////////

/////// ADD ALL YOUR ROUTES HERE  /////////
###

server.get '/', (req,res) -> 
	res.render 'index.jade', {
		locals : { 
							title : 'Marko Oksanen'
							,description: 'Personal website & CV'
							,author: 'Marko Oksanen'
							,analyticssiteid: 'XXXXXXX' 
							}
	}

server.post '/sendMail', (req, res) -> 
	console.log 'getting transport'
	transport = nodemailer.createTransport('SMTP', {
		service: "Mailgun",
		auth: {
			user: "postmaster@ideanimarkooksanen.mailgun.org",
			pass: "6yzddd5coom8"
			}
	})
	console.log 'transport: '+transport
	
	mailOptions = {
		from: ""+req.body.name+" <"+req.body.email+">", #sender address
		to: "marko.oksanen@aceconsulting.fi", #list of receivers
		subject: req.body.subject, #Subject line
		text: req.body.message, #plaintext body
		html: req.body.message #html body
	}

	#send mail with defined transport object
	transport.sendMail mailOptions, (error, response) ->
		if error
			console.log error
			res.send 'error in sending mail'
		else
			console.log "Message sent: " + response.message
			res.render 'index.jade', {
				locals : { 
									title : 'Marko Oksanen'
									,description: 'Personal website & CV'
									,author: 'Marko Oksanen'
									,analyticssiteid: 'XXXXXXX' 
									}
			}

#A Route for Creating a 500 Error (Useful to keep around)
server.get '/500', (req, res) -> 
	throw new Error 'This is a 500 Error'


#The 404 Route (ALWAYS Keep this as the last route)
server.get '/*', (req, res)->
	throw new NotFound

NotFound = (msg) ->
	this.name = 'NotFound'
	Error.call this, msg
	Error.captureStackTrace this, arguments.callee

console.log 'Listening on http://0.0.0.0:' + port 
