// Generated by CoffeeScript 1.10.0
(function() {
  var NotFound, connect, express, io, port, server;

  connect = require('connect', express = require('express', io = require('socket.io', port = process.env.PORT || 8000)));

  server = express.createServer();

  server.configure(function() {
    server.set('views', __dirname + '/views');
    server.set('view options', {
      layout: false
    });
    server.use(connect.bodyParser());
    server.use(express.cookieParser());
    server.use(express.session({
      secret: "shhhhhhhhh!"
    }));
    server.use(connect["static"](__dirname + '/static'));
    return server.use(server.router);
  });

  server.error(function(err, req, res, next) {
    if (err instanceof NotFound) {
      return res.render('404.jade', {
        locals: {
          title: '404 - Not Found',
          description: '',
          author: '',
          analyticssiteid: 'UA-40412130-1'
        },
        status: 404
      });
    } else {
      console.log('err: ' + err.stack);
      return res.render('500.jade', {
        locals: {
          title: 'The Server Encountered an Error',
          description: 'an error occurred with stack: ' + err.stack,
          author: '',
          analyticssiteid: 'UA-40412130-1',
          error: err
        },
        status: 500
      });
    }
  });

  server.listen(port);

  io = io.listen(server);

  io.sockets.on('connection', function(socket) {
    console.log('Client Connected');
    socket.on('message', function(data) {
      socket.broadcast.emit('server_message', data);
      return socket.emit('server_message', data);
    });
    return socket.on('disconnect', function() {
      return console.log('Client Disconnected.');
    });
  });


  /*
  ///////////////////////////////////////////
  //              Routes                   //
  ///////////////////////////////////////////
  
  /////// ADD ALL YOUR ROUTES HERE  /////////
   */

  server.get('/', function(req, res) {
    return res.render('index.jade', {
      locals: {
        title: 'Marko Oksanen',
        description: 'Personal website & CV',
        author: 'Marko Oksanen',
        analyticssiteid: 'XXXXXXX'
      }
    });
  });

  server.get('/feed', function(req, res) {
    console.log('test');
    return res.render('feed.json', {
      locals: {
        title: 'Example Product Feed',
        description: 'Personal website & CV',
        author: 'Marko Oksanen',
        analyticssiteid: 'XXXXXXX'
      }
    });
  });

  server.get('/500', function(req, res) {
    throw new Error('This is a 500 Error');
  });

  server.get('/*', function(req, res) {
    throw new NotFound;
  });

  NotFound = function(msg) {
    this.name = 'NotFound';
    Error.call(this, msg);
    return Error.captureStackTrace(this, arguments.callee);
  };

  console.log('Listening on http://0.0.0.0:' + port);

}).call(this);
