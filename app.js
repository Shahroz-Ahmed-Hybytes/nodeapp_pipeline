const promClient = require('prom-client');
const express = require('express');
const bodyParser = require('body-parser');
const methodOverride = require('method-override');
const sanitizer = require('sanitizer');
const app = express();
const port = 3001;

// Create a Prometheus Registry to register and manage your metrics
const register = new promClient.Registry();
promClient.collectDefaultMetrics({ register });

app.use(bodyParser.urlencoded({ extended: false }));
app.use(methodOverride(function (req, res) {
    if (req.body && typeof req.body === 'object' && '_method' in req.body) {
        let method = req.body._method;
        delete req.body._method;
        return method;
    }
}));

let todolist = [];

// Create a Prometheus counter metric for HTTP requests
const httpRequestCounter = new promClient.Counter({
    name: 'http_requests_total',
    help: 'Total number of HTTP requests',
    labelNames: ['method', 'route'],
    registers: [register], // Register this metric with the custom registry
});

app.get('/todo', function (req, res) {
    // Increment the HTTP request counter for this route
    httpRequestCounter.inc({ method: 'GET', route: '/todo' });

    res.render('todo.ejs', {
        todolist,
        clickHandler: "func1();"
    });
})

.post('/todo/add/', function (req, res) {
    httpRequestCounter.inc({ method: 'POST', route: '/todo/add' });

    let newTodo = sanitizer.escape(req.body.newtodo);
    if (req.body.newtodo != '') {
        todolist.push(newTodo);
    }
    res.redirect('/todo');
})

.get('/todo/delete/:id', function (req, res) {
    httpRequestCounter.inc({ method: 'GET', route: '/todo/delete' });

    if (req.params.id != '') {
        todolist.splice(req.params.id, 1);
    }
    res.redirect('/todo');
})

.get('/todo/:id', function (req, res) {
    httpRequestCounter.inc({ method: 'GET', route: '/todo/:id' });

    let todoIdx = req.params.id;
    let todo = todolist[todoIdx];

    if (todo) {
        res.render('edititem.ejs', {
            todoIdx,
            todo,
            clickHandler: "func1();"
        });
    } else {
        res.redirect('/todo');
    }
})

.put('/todo/edit/:id', function (req, res) {
    httpRequestCounter.inc({ method: 'PUT', route: '/todo/edit' });

    let todoIdx = req.params.id;
    let editTodo = sanitizer.escape(req.body.editTodo);
    if (todoIdx != '' && editTodo != '') {
        todolist[todoIdx] = editTodo;
    }
    res.redirect('/todo');
})

.use(function (req, res, next) {
    httpRequestCounter.inc({ method: 'UNKNOWN', route: 'unknown' });
    res.redirect('/todo');
})

.listen(port, function () {
    console.log(`Todolist running on http://127.0.0.1:${port}`);
});

// Add a new endpoint to expose Prometheus metrics
app.get('/metrics', (req, res) => {
    res.set('Content-Type', register.contentType);
    res.end(register.metrics());
});

module.exports = app;
