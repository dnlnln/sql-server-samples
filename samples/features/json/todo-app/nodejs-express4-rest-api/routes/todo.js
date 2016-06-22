var express = require('express');
var router = express.Router();

var db = require('../db.js');
var TYPES = require('tedious').TYPES;

/* GET task listing. */
router.get('/', function (req, res) {
    db.stream("select * from todo for json path", db.createConnection(), res, '[]');
});

/* GET single task. */
router.get('/:id', function (req, res) {
    
    var conn = db.createConnection();

    var request = db.createRequest("select * from todo where id = @id for json path, without_array_wrapper", conn); 
    request.addParameter('id', TYPES.Int, req.params.id);
    db.stream(request, conn, res, '{}');
});

/* POST create task. */
router.post('/', function (req, res) {
    
    var connection = db.createConnection();
    var request = db.createRequest("exec createTodo @todo", connection);
    
    request.addParameter('todo', TYPES.NVarChar, req.body);
    
    connection.on('connect', function (err) {
        if (err) {
            throw err;
        }
        connection.execSql(request);
    });
});

/* PUT update task. */
router.put('/:id', function (req, res) {
    
    var connection = db.createConnection();
    var request = db.createRequest("exec updateTodo @id, @todo", connection);
    
    request.addParameter('id', TYPES.Int, req.params.id);
    request.addParameter('todo', TYPES.NVarChar, req.body);
    
    connection.on('connect', function (err) {
        if (err) {
            throw err;
        }
        connection.execSql(request);
    });
});

/* DELETE single task. */
router.delete('/:id', function (req, res) {
    
    var connection = db.createConnection();
    var request = db.createRequest("delete from todo where id = @id", connection);

    request.addParameter('id', TYPES.Int, req.params.id);
    
    connection.on('connect', function (err) {
        if (err) {
            throw err;
        }
        connection.execSql(request);
    });
});

module.exports = router;