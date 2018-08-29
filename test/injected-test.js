function is_defined(obj) {
  return typeof (obj) !== 'undefined';
}

//
// TESTING
//

function fetch_data(name_to_path, callback) {
  var data = {};
  Object.keys(name_to_path).forEach(function(name) { data[name] = undefined; });
  var promises = Object.keys(name_to_path).map(function(name) {
    return fetch(name_to_path[name]).then(function(r){ return r.json(); }).then(function(json) {
      data[name] = json;
    });
  });
  Promise.all(promises).then(function() {
    callback(data);
  });
}

function createElement(name, attrs) {
  var $elem = document.createElement(name);
  if (is_defined(attrs)) {
    Object.keys(attrs).forEach(function(attr_name) {
      $elem[attr_name] = attrs[attr_name];
    });
  }
  return $elem;
}

// test
function test() {

  var previousAMPMSetting = opts.amPM;
  // force to 24hour
  opts.amPM = false;

  (function(from, to, when, $result) {
    console.debug('Fetching test data');
    var passCount = 0;
    fetch_data({
      "weekday_NB_TT": "test/weekday_NB_TT.json",
      "weekday_SB_TT": "test/weekday_SB_TT.json",
      "weekend_NB_TT": "test/weekend_NB_TT.json",
      "weekend_SB_TT": "test/weekend_SB_TT.json",
    }, function(test_data) {
      console.debug('Start testing');

      var $test_result = createElement('div', {id: 'test_result'});
      document.documentElement.appendChild($test_result);
      function assert(check, msg) {
        if (!check) {
          var $item = createElement('div', {className: "test_result_item"});
          msg.split("\n").forEach(function(line) {
            $item.appendChild(createElement('div', {textContent: line}));
          });
          $test_result.appendChild($item);
        }
        passCount++;
        return check;
      }

      function fixTimeFormat(time_str) {
        var t = time_str.split(":");
        t[0] = t[0] % 24;
        return t.map(function(item) { return item.toString().rjust(2, '0'); }).join(":");
      }

      function formatExpectTime(expect) {
        return "[" + fixTimeFormat(expect[0]) + "=>" + fixTimeFormat(expect[1]) + "]";
      }

      function formatActualTime(actual) {
        return "[" + actual[0] + "=>" + actual[1] + "]";
      }

      function formatActualTime(actual) {
        return "[" + actual[0] + "=>" + actual[1] + "]";
      }

      function fixStopName(stop_name) {
        if (stopMapping[stop_name]) stop_name = stopMapping[stop_name];
        return stop_name;
      }

      // expects == what is pulled from the caltrain site
      // actuals == the results locally
      function runTest(test_datum, schedule_type) {
        for (var i = test_datum.length - 1; i >= 0; i--) {
          var to_name = fixStopName(test_datum[i].name);
          var to_stops = test_datum[i].stop_times;
          var toOptions = Array.from(to.options).map(function(e){ return e.value; })
          if (!assert(toOptions.indexOf(to_name) >= 0, "to_name is not in options:" + to_name)) {
            continue;
          }
          to.value = to_name;
          schedule();

          for (var j = i - 1; j >= 0; j--) {
            var from_name = fixStopName(test_datum[j].name);
            var from_stops = test_datum[j].stop_times;
            var fromOptions = Array.from(from.options).map(function(e){ return e.value; })
            if (!assert(fromOptions.indexOf(from_name) >= 0, "from_name is not in options:" + from_name)) {
              continue;
            }
            from.value = from_name;
            schedule();

            var expects = [];
            if (assert(from_stops.length === to_stops.length,
                        "from_stops and to_stops have different length:" + from_name + "=>" + to_name)) {
              for (var k = from_stops.length - 1; k >= 0; k--) {
                var from_stop = from_stops[k];
                var to_stop = to_stops[k];
                if (assert(from_stop.service_type === to_stop.service_type,
                            "from_stop and to_stop have different type: " +
                              "schedule:" + schedule_type + ", " +
                              from_name + "(" + from_stop.service_type + ")=>" +
                              to_name + "(" + to_stop.service_type + ")" +
                              "[" + from_stop.time + "=>" + to_stop.time + "]")) {

                  var service_type = from_stop.service_type;
                  if (service_type === 'SatOnly' && schedule_type !== 'saturday') {
                    continue;
                  }
                  if (from_stop.time && to_stop.time) {
                    // since the loop is reversed, insert to first position
                    expects.unshift([from_stop.time, to_stop.time]);
                  }
                }
              }
            }

            var actuals = [];
            var trips = $result.querySelectorAll('.trip:not(.no-trips)');
            for (var l = trips.length - 1; l >= 0; l--) {
              var trip = trips[l];
              actuals.unshift([trip.children[0].textContent, trip.children[2].textContent]);
            }


            // sort by "depature_time=>arrival_time"
            function sortTrips(a, b) {
              // HACK(paulirish): added this fixTimeFormat
              a = fixTimeFormat(a[0]) + "=>" + a[1];
              b = fixTimeFormat(b[0]) + "=>" + b[1];
              if (a < b) { return -1; }
              if (a > b) { return 1; }
              return 0;
            };

            expects.sort(sortTrips);
            actuals.sort(sortTrips);


            function isOneMinuteLower(timeLower, time) {
              var timeLowerMinutes = timeLower.split(":")[1];
              var timeMinutes = time.split(":")[1];
              return parseInt(timeLowerMinutes) == parseInt(timeMinutes) - 1;
            }

            if (assert(expects.length === actuals.length,
                    "expects and actuals have different length:" + from_name + "=>" + to_name +
                    "\nexpects:" + expects.map(formatExpectTime).join(", ") +
                    "\nactuals:" + actuals.map(formatActualTime).join(", "))) {

              for (var m = actuals.length - 1; m >= 0; m--) {
                var expect_from_text = fixTimeFormat(expects[m][0]);
                var expect_to_text = fixTimeFormat(expects[m][1]);
                const isTimeMatching = actuals[m][0] === expect_from_text && actuals[m][1] === expect_to_text;
                if (isTimeMatching) continue;
                debugger;
                const isOneMinuteOff = (isOneMinuteLower(actuals[m][0], expect_from_text) && actuals[m][1] === expect_to_text) ||
                                       (isOneMinuteLower(actuals[m][1], expect_to_text) && actuals[m][0] === expect_from_text) ||
                                       (isOneMinuteLower(actuals[m][1], expect_to_text) && isOneMinuteLower(actuals[m][0], expect_from_text));

                if (isOneMinuteOff) {
                  assert(!isOneMinuteOff,
                    "time mismatch by 1 minute: schedule:" + schedule_type + ", " +
                      from_name + "=>" + to_name +
                      "\n                 expected:(" + expect_from_text + " => " + expect_to_text +
                      ")\n                   actual:(" + actuals[m][0] + " => " + actuals[m][1] + ")");
                } else {
                   assert(!isTimeMatching,
                        "time mismatch: schedule:" + schedule_type + ", " +
                          from_name + "=>" + to_name +
                          "\n                 expected:(" + expect_from_text + " => " + expect_to_text +
                          ")\n                   actual:(" + actuals[m][0] + " => " + actuals[m][1] + ")");
                }
              }
            }
          }
        }
      }

      when[1].click(); // Weekday
      runTest(test_data.weekday_NB_TT, 'weekday');
      runTest(test_data.weekday_SB_TT, 'weekday');

      when[2].click(); // Saturday
      runTest(test_data.weekend_NB_TT, 'saturday');
      runTest(test_data.weekend_SB_TT, 'saturday');

      when[3].click(); // Sunday
      runTest(test_data.weekend_NB_TT, 'sunday');
      runTest(test_data.weekend_SB_TT, 'sunday');

      var $failed = createElement('div', {
        id: 'failed',
        textContent: "Total failed:" + $test_result.children.length});
      var $passed = createElement('div', {
          id: 'passed',
          textContent: "Total passed:" + passCount});

      $test_result.insertBefore($passed, $test_result.firstChild);
      $test_result.insertBefore($failed, $test_result.firstChild);
      console.debug('Finish testing');


      // restore
      opts.amPM = previousAMPMSetting;


    });
  })( $('#from select') , $('#to select'), whenButtons, $('#result'));
}
