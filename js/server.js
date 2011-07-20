// npm install sqlite3 node-static

var DATABASE = '/Users/Ivan/R-trader/data/symbols.db';

function sql(symbol, range) {
    var sql = "select D, O, H, L, C, V from symbols where S = ? ";
    var parameters = [ symbol ];
    if (range && (range.length == 2)) {
        sql += "and D between ? and ? ";
        parameters = parameters.concat(range);
    } else if (range && (range.length == 1)) {
        sql += "and D >= ? ";
        parameters = parameters.concat(range);
    }
    sql += "order by D asc";
    return {
        query : sql,
        bindings : parameters
    };
}

function load(req, res, symbol, file, range) {
    var sqlite3 = require('sqlite3');
    var db = new sqlite3.Database(file, sqlite3.OPEN_READONLY, doload);

    function edb(e, f) {
        if (!e) {
            f();
        } else {
            emitter.emit("db-load-error", req, res, symbol, e);
            db.close();
        }
    }

    function doload(e) {
        edb(e, function() {
            var args = sql(symbol, range);
            db.all(args.query, args.bindings, dofetch);
        });
    }

    function dofetch(e, data) {
        edb(e, function() {
            emitter.emit("db-load-ok", req, res, symbol, data);
            db.close();
        });
    }
};

function output(code, req, res, obj) {
    res.writeHead(code, {
        'Content-Type' : 'application/json'
    });
    if (code == 200) {
        res.write(JSON.stringify(obj));
    }
    res.end();
}

var events = require('events');

var emitter = new events.EventEmitter();

emitter.addListener("db-load-ok", function(req, res, symbol, data) {
    var o = {
        symbol : symbol,
        db : (data.length > 0) ? data : []
    };
    output(200, req, res, o);
});

emitter.addListener("db-load-error", function(req, res, symbol, e) {
    var o = {
        url : req,
        symbol : symbol,
        problem : e
    };
    output(500, req, res, o);
});

var http = require("http");
var web = require('node-static');
var file = new web.Server('./public');
var server = http.createServer();

server.on('request', function(req, res) {
    req.addListener('end', function () {
        file.serve(req, res, function (err, result) {
            if (err) {
                var p = req.url.split("/");
                if ((p.length < 3) || (p[1] === undefined)) {
                    output(400, req, res, {
                        error : 'invalid request'
                    });
                } else {
                    switch (p[1]) {
                    case 'load':
                        load(req, res, p[2], DATABASE, p.slice(3));
                        break;
                    default:
                        output(501, req, res, {
                            error : 'function not implemented [' + p[1] + "]"
                        });
                        break;
                    }
                }
            }
        });
    });
});

var port = 8080;
server.listen(port);
console.log("jstrader listening on " + port + "...");
