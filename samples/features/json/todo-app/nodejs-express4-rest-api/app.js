var express = require('express');
var bodyParser = require('body-parser');

var app = express();
app.use(bodyParser.text());
app.use('/todo', require('./routes/todo'));

// catch 404 and forward to error handler
app.use(function (req, res, next) {
    var err = new Error('Not Found');
    err.status = 404;
    next(err);
});

module.exports = app;
