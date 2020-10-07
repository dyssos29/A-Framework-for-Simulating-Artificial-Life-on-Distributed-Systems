const createError = require('http-errors');
const express = require('express');
const path = require('path');
const cookieParser = require('cookie-parser');
const logger = require('morgan');
const http = require('http');
const amqp = require('amqplib');
const socket = require('socket.io');
const promiseRetry = require('promise-retry');

const indexRouter = require('./routes/index');
const usersRouter = require('./routes/users');

const app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', indexRouter);
app.use('/users', usersRouter);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

const server = http.createServer(app).listen(3005, function(){
  console.log('Express server listening on port ' + 3005);
});

const io = socket(server);
io.on('connection', function(socket){
  console.log('Socket connection established with status: ' + socket.connected);
});

var receivedMigrations = [];
const requestQueue = 'rpc_request_queue';
var isRequest = false;

function addToSortedList(migration)
{
  if (receivedMigrations.length == 0)
    receivedMigrations.push(migration);
  else
  {
    // console.log('length: ' + receivedMigrations.length);
    if (receivedMigrations[receivedMigrations.length - 1].bestFitnessValue > migration.bestFitnessValue)
      receivedMigrations.push(migration);
    else
    {
      for(let i = 0; i < receivedMigrations.length; i++)
      {
        if (receivedMigrations[i].bestFitnessValue == migration.bestFitnessValue)
          break;
        else
        {
          if (receivedMigrations[i].bestFitnessValue < migration.bestFitnessValue)
          {
            receivedMigrations.splice(i, 0, migration);
            break;
          }
        }
      }
    }
  }
}

function getMigrationsToSend()
{
  let migrationsToSend = [];

  if (receivedMigrations.length == 1 && !isRequest)
    return {};
  else
  {
    if (receivedMigrations.length == 1)
      migrationsToSend.push(receivedMigrations[0]);
    else
      migrationsToSend.push(receivedMigrations[0], receivedMigrations[1]);
  }

  return migrationsToSend;
}

function printBestMigrantsBeingSent(migrationsBeingSent)
{
  let bestMigrants = '';

  for(let i = 0; i < migrationsBeingSent.length; i++)
  {
    bestMigrants += migrationsBeingSent[i].bestFitnessValue + ' -- ';
  }

  return bestMigrants;
}

function processRPCrequest(aMigrationString)
{
  let migrationObj = JSON.parse(aMigrationString);

  if (aMigrationString != '{}')
  {
    console.log("Migration (best migrant) received from an island: %s", migrationObj.bestFitnessValue);
    addToSortedList(migrationObj);
  }
  else
  {
    isRequest = true;
    console.log('Received request for migrations from an island.');
  }
}

promiseRetry(function (retry, number) {
  console.log('Attempt number: ' + number);

  return amqp.connect('amqp://ody-rabbit')
      .catch(retry);
}).then(function(conn) {
  console.log('Connected to rabbitmq.');
  return conn.createChannel();
}).then(function(ch) {
  return ch.assertQueue(requestQueue, { durable: true}).then(function(ok) {
    return ch.consume(requestQueue, function(msg) {
      if (msg !== null) {
        let migrationStr = msg.content.toString();
        processRPCrequest(migrationStr);

        // console.log('Length of the migration objects array: ' + receivedMigrations.length);
        io.sockets.emit('migration', receivedMigrations);

        let migrationsToSend = getMigrationsToSend();
        let jsonToSend = JSON.stringify(migrationsToSend);
        if (jsonToSend != "{}")
          console.log('Message that is being sent as response (fittest migrants) to an island: ' + printBestMigrantsBeingSent(migrationsToSend));
        else
          console.log('Message that is being sent is empty.');

        ch.sendToQueue(msg.properties.replyTo, Buffer.from(jsonToSend), {correlationId: msg.properties.correlationId});
        ch.ack(msg);
      }
    });
  });
}).catch(console.warn);

app.locals.migrations = receivedMigrations;

module.exports = app;