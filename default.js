function save_cookies () {
  $.cookie("from", $("#from").prop("value"));
  $.cookie("to", $("#to").prop("value"));
  $.cookie("when", $("#when").prop("value"));
}

function load_cookies () {
  // load selections from cookies
  $.cookie.defaults.expires = 365;
  $.cookie.defaults.path = '/';
  $("#from").prop("value", $.cookie("from"));
  $("#to").prop("value", $.cookie("to"));
  $("#when").prop("value", $.cookie("when"));
}

function from_now () {
  return $("#when").prop("value") === "now";
}

function now_str () {
  var now_date = new Date();
  return now_date.getHours() + ':' + now_date.getMinutes() + ':00';
}

function str2time (str) {
  return str.split(':').map(function(t) { return parseInt(t) });
}

function time2str (arr) {
  return arr[0] + ':' + arr[1] + ':00';
}

function time_relative (from, to) {
  var from_time = str2time(from), to_time = str2time(to);
  return (to_time[0] - from_time[0]) * 60 + (to_time[1] - from_time[1]);
}

function get_trip_match_regexp () {
  var trip_reg, now_date = new Date();
  switch ($("#when").prop("value")) {
    case "now": {
      switch (now_date.getDay()) {
        case 1: case 2: case 3: case 4: case 5:
          trip_reg = /Weekday/;
          break;
        case 6:
          trip_reg = /Saturday/;
          break;
        case 0:
          trip_reg = /Sunday/;
          break;
        default:
          alert("now_date.getDay() got wrong: " + now_date.getDay());
      }
      break;
    }
    case "weekday":
      trip_reg = /Weekday/;
      break;
    case "weekend":
      trip_reg = /Saturday|Sunday/;
      break;
    default:
      alert("$('#when').prop('value') got wrong: " + $("#when").prop("value"));
  }
  return trip_reg;
}

function get_trips (times, from_id, to_id) {
  var trips = {};
  var trip_reg = get_trip_match_regexp();

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

  var results = [];
  for (var trip_id in trips) {
    var trip = trips[trip_id];
    if (typeof(trip.from_time) !== "undefined" &&
        typeof(trip.to_time) !== "undefined") {
      results.push(trip);
    };
  }

  return results;
}

function set_next_train_info (next_train, now_date) {
  var info = $("#info").empty();
  if (from_now() && typeof(next_train) !== 'undefined') {
    var next_relative = time_relative(now_str(), next_train);
    info.append('<div class="info">Next train: ' + next_relative + 'min</div>');
  };
}

function schedule (event) {
  save_cookies();

  // Fix the stop ids
  var from_id = parseInt($("#from").prop("value")), to_id = parseInt($("#to").prop("value"));
  if (to_id > from_id) { // if South Bound
    from_id += 1;
    to_id += 1;
  };

  var times = event.data.times;
  var now_date = new Date();
  var trips = get_trips(times, from_id, to_id);

  // generate html strings and sort
  var next_train;
  var trip_strs = [];
  trips.forEach(function(trip) {
    // check avalible
    if (from_now() && trip.from_time < now_str()) { return; };

    if (!next_train || next_train > trip.from_time) {
      next_train = trip.from_time;
    };

    var trip_time = time_relative(trip.from_time, trip.to_time);
    var item = trip.from_time + ' => ' + trip.to_time + ' (' + trip_time + 'min)';
    trip_strs.push(item);
  });
  trip_strs.sort();

  set_next_train_info(next_train, now_date);

  // append the result
  var result = $("#result").empty();
  trip_strs.forEach(function(str) {
    result.append('<div class="trip">' + str + '</div>');
  });
}

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

function bind_events (data) {
  $("#from").on("change", data, schedule);
  $("#to").on("change", data, schedule);
  $("#when").on("change", data, schedule);
  $("#reverse").on("click", data, function(event) {
    var t = $("#from").prop("value");
    $("#from").prop("value", $("#to").prop("value"));
    $("#to").prop("value", t);
    schedule(event);
  });
}


$(document).ready(function() {
  var stops, times;
  var checker = data_checker(["stops", "times"], function() {
    // All data is finished
    var city_ids = {};
    stops.forEach(function(s) {
      var id = s.stop_id, name = s.stop_name;
      if (typeof(city_ids[name]) == "undefined") {
        city_ids[name] = id;
        $("#from").append(new Option(name, id));
        $("#to").append(new Option(name, id));
      };
    });

    bind_events({ times: times });
    load_cookies();
    schedule({data: {times: times}}); // init schedule
  });

  Papa.parse("stops.csv", {
    download: true,
    dynamicTyping: true,
    header: true,
    complete: function(results) {
      stops = results.data;
      checker("stops");
    }
  });

  Papa.parse("times.csv", {
    download: true,
    dynamicTyping: true,
    header: true,
    complete: function(results) {
      times = results.data;
      checker("times");
    }
  });
});
