var express = require('express'),
    http = require('http'),
    parseString = require('xml2js').parseString,
    cors = require('cors'),
    app = express();

// app setup
var port = process.env.PORT || 3005;

// 511 setup
var domain = 'services.my511.org';
var token = '&token=5e58e873-398c-4408-87f4-d58b19136466';

// routes
app.use(express.static(__dirname + '/src'));

app.get('/api/position/:train', cors(), function(req, res) {
  var trainId = req.params.train;
  var options = {
    hostname: domain,
    path: '/Transit2.0/GetCurrentPosition.aspx?trainnum=' + train + token
  };

  console.log('sending API request…');
  http.request(options, function(serviceRes) {
    var data = '';

    serviceRes.on('data', function (chunk) {
      data += chunk;
    });

    serviceRes.on('end', function () {
      parseString(data, function(err, dataString) {
        res.set('Content-Type', 'application/json');
        res.send(JSON.stringify(dataString));
      })
    });
  })
  .on('error', function(e){
    console.log("Error: " + e.message);
  })
  .end();

});

app.listen(port);