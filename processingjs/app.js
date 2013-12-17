var express = require('express');
var app = express();
app.use(express.bodyParser());
var redis = require("redis"),
    client = redis.createClient();

//Temp : when I need to delete test results
//client.del("psi.xp.results");
//client.hdel("psi.xp.results", "bs");
//client.del("psi.xp.peoch_results.temoin");
app.post('/results', function(req, res){
  var name = req.body.name;
  client.hget("psi.xp.results", name, function (err, reply) {
    var table = reply != null ? reply.split(',') : [];
    table.push(req.body.data);
    client.hset("psi.xp.results", name, table);
    res.send("ok");
  });
});

app.get('/results.json', function(req, res) {
  client.hgetall("psi.xp.results", function (err, reply) {
    var body = JSON.stringify(reply)
    res.setHeader('Content-Type', 'application/json');
    res.setHeader('Content-Length', body.length);
    res.end(body);
  });
});

app.post('/peoch_results', function(req, res){
  var name = req.body.name;
  client.rpush("psi.xp.peoch_results." + name, req.body.data);
  res.send("ok");
});

app.get('/peoch_results.json', function(req, res){
  client.lrange("psi.xp.peoch_results.temoin", 0, -1, function (err, reply) {
    var body = JSON.stringify(reply)
    res.setHeader('Content-Type', 'application/json');
    res.setHeader('Content-Length', body.length);
    res.end(body);
  });
});

app.get('/*', function (req, res) {
	res.sendfile(__dirname + "/" + req.params[0]);
});

var port = 3001;
app.listen(port);
console.log("Listening on port ", port);
