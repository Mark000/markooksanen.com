#setup Dependencies
connect = require 'connect'
	, express = require 'express'
	, io = require 'socket.io'
	, port = process.env.PORT || 8000

nodemailer = require 'nodemailer'

httpProxy = require 'http-proxy'
blogProxy = httpProxy.createProxyServer()

#Load the Ghost Module
#Hapi = require 'hapi'
#path = require 'path'
#ghost = require 'ghost'

#server = new Hapi.Server('0.0.0.0', '8000');

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

server.get '/blog*', (req, res, next) ->
		req.headers.host = 'https://markooksanenblog.herokuapp.com';
		blogProxy.web req, res, { target: 'https://markooksanenblog.herokuapp.com' }

###
 server.get '/blog*', (req,res) ->
  blogProxy.web req, res, { target: 'http://localhost:2368' }
  console.log 'Hello!!'
###

#server == parentApp running express
#rootApp = Ghost server

###
ghost().then (ghostServer) ->
#	server.use ghostServer.config.paths.subdir, ghostServer.rootApp
#	server.use 'http://localhost:2368', ghostServer.rootApp
	ghostServer.start server
	console.log 'Hello again :) '
ghost().then (ghostServer) ->
	#	server.use ghostServer.config.paths.subdir, ghostServer.rootApp
	#	server.use 'http://localhost:2368', ghostServer.rootApp
	ghostServer.start server

ghost({
    config: path.join(__dirname, 'config.js')
})
###


server.post '/sendMail', (req, res) ->
	console.log 'getting transport'
	transport = nodemailer.createTransport('SMTP', {
		service: "Mailgun",
		auth: {
			user: "postmaster@markooksanen.com",
			pass: "b454362f88174c7452db3fa58dd748bf"
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
									,analyticssiteid: 'UA-58573235-1'
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
