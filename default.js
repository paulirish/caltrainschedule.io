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
  var now_date = new Date();

  // Fix the stop ids
  var from_id = parseInt($("#from").prop("value")), to_id = parseInt($("#to").prop("value"));
  if (to_id > from_id) {
    // South Bound
    from_id += 1;
    to_id += 1;
  };

  // Save selections to cookies
  $.cookie("from", $("#from").prop("value"));
  $.cookie("to", $("#to").prop("value"));
  $.cookie("when", $("#when").prop("value"));
  $.cookie("now", $("#now").prop("checked"));

  // trip_id regexp
  var trip_reg;
  if ($("#now").is(":checked")) {
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
  } else {
    if ($("#when").prop("value") == "weekend") {
      trip_reg = /Saturday|Sunday/;
    } else {
      trip_reg = /Weekday/;
    };
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

  // generate html strings and sort
  var now_str = now_date.getHours() + ':' + now_date.getMinutes() + ':00';
  var trip_strs = [];
  for (var trip_id in trips) {
    var trip = trips[trip_id];

    // check if available, 2014 OCT only,
    if (!/14OCT/.exec(trip_id) ||
        typeof(trip.from_time) == "undefined" ||
        typeof(trip.to_time) == "undefined" ||
        ($("#now").is(":checked") && trip.from_time < now_str)) {
      continue;
    };

    var from_parts = trip.from_time.split(':').map(function(t) { return parseInt(t) });
    var to_parts = trip.to_time.split(':').map(function(t) { return parseInt(t) });
    var time_length = (to_parts[0] - from_parts[0]) * 60 + (to_parts[1] - from_parts[1]);
    var item = '<div class="trip">' +
    trip.from_time + ' - ' + trip.to_time + ' = ' + time_length + 'min' +
    '</div>';
    trip_strs.push(item);
  };
  trip_strs.sort();

  // append the result
  var result = $("#result");
  result.empty();
  trip_strs.forEach(function(str) {
    result.append(str);
  });
}


$(document).ready(function() {
  var stops, times;
  var checker = data_checker(["stops", "times"], function() {
    // All data is finished
    var city_ids = {}, city_names = {};
    var from = $("#from"), to = $("#to");

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
    $("#when").on("change", { times: times }, schedule);
    $("#now").change({ times: times }, function(event) {
      $("#when").prop("disabled", $(this).is(":checked"));
      schedule(event);
    });
    $("#search").on("click", { times: times }, schedule).prop("disabled", false);
    $("#reverse").on("click", { times: times }, function(event) {
      var t = from.prop("value");
      from.prop("value", to.prop("value"));
      to.prop("value", t);
      schedule(event);
    }).prop("disabled", false);

    // load selections from cookies
    $("#from").prop("value", $.cookie("from"));
    $("#to").prop("value", $.cookie("to"));
    $("#when").prop("value", $.cookie("when"));
    $("#now").prop("checked", $.cookie("now"));
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
