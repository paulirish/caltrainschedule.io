function data_checker (names, callback) {
  var mark = {}, callback = callback;
  names.forEach(function(name) {
    mark[name] = false;
  });
  return function(name) {
    mark[name] = true;
    var all_true = true;
    for (var n in mark)
      if (!mark[n])
        all_true = false;
    if (all_true)
      callback();
  };
}

function schedule (event) {
  var times = event.data.times;
  var from = $("#from"), to = $("#to"), when = $("#when"), search = $("#search");

  // Fix the stop ids
  var from_id = parseInt(from.prop("value")), to_id = parseInt(to.prop("value"));
  if (to_id > from_id) {
    // South Bound
    from_id += 1;
    to_id += 1;
  };

  // trip_id regexp
  var trip_reg;
  if (when.prop("value") == "weekend") {
    trip_reg = /Saturday|Sunday/;
  } else {
    trip_reg = /Weekday/;
  };

  // Select trips
  var trips = {};
  times.forEach(function(t) {
    if (!trip_reg.exec(t.trip_id)) {
      return;
    };

    if (t.stop_id == from_id) {
      trips[t.trip_id] = {
        from: from_id,
        from_time: t.arrival_time
      };
    } else if (t.stop_id == to_id) {
      $.extend(trips[t.trip_id], {
        to: to_id,
        to_time: t.departure_time
      });
    };
  });

  var trip_strs = [];
  for (var trip_id in trips) {
    var trip = trips[trip_id];
    var item = '<div class="trip">' +
    trip_id + '\t' +
    trip.from_time + '\t' +
    trip.to_time +
    '</div>';
    trip_strs.push(item);
  };

  var result = $("#result");
  result.empty();

  debugger;
}


$(document).ready(function() {
  var stops, times;
  var checker = data_checker(["stops", "times"], function() {
    // All data is finished
    var city_ids = {}, city_names = {};
    var from = $("#from"), to = $("#to"), when = $("#when"), search = $("#search");

    stops.forEach(function(s) {
      if (/Station/.exec(s.stop_name)) { return; }; // remove duplications

      city_ids[s.stop_id] = s.stop_name;

      if (typeof(city_ids[s.stop_name]) == "undefined") {
        city_ids[s.stop_name] = s.stop_id;
        from.append(new Option(s.stop_name, s.stop_id));
        to.append(new Option(s.stop_name, s.stop_id));
      };
    });

    from.on("change", { times: times }, schedule);
    to.on("change", { times: times }, schedule);
    when.on("change", { times: times }, schedule);
    search.on("click", { times: times }, schedule);
    search.prop("disabled", false);
  });

  Papa.parse("gtfs/stops.txt", {
    download: true,
    dynamicTyping: true,
    header: true,
    complete: function(results) {
      stops = results.data;
      checker("stops");
    }
  });

  Papa.parse("gtfs/stop_times.txt", {
    download: true,
    dynamicTyping: true,
    header: true,
    complete: function(results) {
      times = results.data;
      checker("times");
    }
  });
});
