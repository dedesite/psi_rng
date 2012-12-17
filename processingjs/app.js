var app = require('express')();

app.get('/*', function (req, res) {
	res.sendfile(__dirname + req.originalUrl);
});

var port = 3000;
app.listen(port);
console.log("Listening on port ", port);