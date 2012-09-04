var app = require('express')();

app.get('/*', function (req, res) {
	res.sendfile(__dirname + req.originalUrl);
});

app.listen(3000);