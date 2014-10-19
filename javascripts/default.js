var from, to, when;

function is_defined (obj) {
  return typeof(obj) !== "undefined";
}

function save_cookies () {
  $.cookie("from", from.getText());
  $.cookie("to", to.getText());
  $.cookie("when", $('.when-button.selected').val());
}

function load_cookies () {
  $.cookie.defaults.expires = 365; // expire in one year
  $.cookie.defaults.path = '/'; // available across the whole site
  if (is_defined($.cookie("from"))) {
    from.setText($.cookie("from"));
  };
  if (is_defined($.cookie("to"))) {
    to.setText($.cookie("to"));
  };
  if (is_defined($.cookie("when"))) {
    $('.when-button[value=' + $.cookie("when") + ']').addClass('selected');
  };
}

String.prototype.repeat = function( num ) {
  for( var i = 0, buf = ""; i < num; i++ ) buf += this;
  return buf;
}

String.prototype.rjust = function( width, padding ) {
  padding = padding || " ";
  padding = padding.substr( 0, 1 );
  if( this.length < width )
    return padding.repeat( width - this.length ) + this;
  else
    return this;
}

function str2date (str) {
  var parts = str.split(':').map(function(t) { return parseInt(t) });
  var date = new Date();
  date.setHours(parts[0], parts[1], parts[2]);
  return date;
}

function date2str (date) {
  return [
  date.getHours().toString().rjust(2, '0'),
  date.getMinutes().toString().rjust(2, '0')
  ].join(':');
}

function time_relative (from, to) {
  return Math.round((to - from) / 1000 / 60); // in minute
}

function is_now () {
  return $('.when-button.selected').val() === "now";
}

function get_trip_match_regexp () {
  if (is_now()) {
    var now_date = new Date();
    switch (now_date.getDay()) {
      case 1: case 2: case 3: case 4: case 5:
        return /Weekday/i;
      case 6:
        return /Saturday/i;
      case 0:
        return /Sunday/i;
      default:
        alert("now_date.getDay() got wrong: " + now_date.getDay());
        return;
    }
  } else {
    var value = $('.when-button.selected').val();
    if (is_defined(value)) {
      value = value.charAt(0).toUpperCase() + value.substring(1); // capitalize
      return new RegExp(value, "i"); // ignore case
    };
  }
}

function compare_trip (a, b) {
  return a.departure_time - b.departure_time;
}

function get_trips (services, from_ids, to_ids) {
  var trips = []; // valid trips
  var trip_reg = get_trip_match_regexp();

  // invalid when
  if (!is_defined(trip_reg)) { return; };

  for (var trip_id in services) {
    if (!trip_reg.exec(trip_id)) {
      continue;
    }

    var service = services[trip_id],
    from = undefined,
    to = undefined;

    from_ids.forEach(function(id) {
      if (is_defined(service[id])) {
        from = service[id];
      }
    });
    to_ids.forEach(function(id) {
      if (is_defined(service[id])) {
        to = service[id];
      }
    });

    if (is_defined(from) && is_defined(to) &&
        from.stop_sequence < to.stop_sequence &&
        (!is_now() || from.departure_time > new Date())) {
      trips.push({
        departure_time: from.departure_time,
        arrival_time: to.arrival_time
      });
    };
  }

  return trips.sort(compare_trip);
}

function render_info (next_train) {
  var info = $("#info").empty();
  if (is_now() && is_defined(next_train)) {
    var next_relative = time_relative(new Date(), next_train.departure_time);
    info.append('<div class="info">Next train: ' + next_relative + 'min</div>');
  };
}

function render_result (trips) {
  var result = $("#result").empty();
  trips.forEach(function(trip) {
    var departure_str = date2str(trip.departure_time);
    var arrival_str = date2str(trip.arrival_time);
    var trip_time = time_relative(trip.departure_time, trip.arrival_time);
    result.append('<div class="trip">' +
                  '<span class="departure">' + departure_str + '</span>' +
                  '<span class="duration">' + trip_time + ' min</span>' +
                  '<span class="arrival">' + arrival_str + '</span>' +
                  '</div>');
  });
}

function schedule (event) {
  var cities = event.data["cities"], services = event.data["services"];
  var from_ids = cities[from.getText()],
      to_ids = cities[to.getText()];
  var trips = get_trips(services, from_ids, to_ids);
  if (!is_defined(from_ids) || !is_defined(to_ids) || !is_defined(trips)) {
    // if ids are invalid, just return. Since some input is invalid
    return;
  };

  save_cookies();
  render_info(trips[0]);
  render_result(trips);
}

function bind_events (data) {
  var event = { data: data };

  [from, to].forEach(function(c) {
    // generate cancel button
    var cancel = $('<span class="cancel">x</span>')
    .on("click", function() {
      c.setText('');
      c.input.focus();
    });
    var hide_if_has_input_and_schedule = function() {
      if (c.input.value === '') {
        cancel.hide();
      } else {
        cancel.show();
      };
      schedule(event);
    };
    c.on("change", hide_if_has_input_and_schedule);
    c.on("complete", hide_if_has_input_and_schedule);
    $(c.wrapper).append(cancel);
  });

  when.each(function(index, elem) {
    $(elem).on("click", data, function(event) {
      when.each(function(index, elem) {
        $(elem).removeClass("selected");
      });
      $(elem).addClass("selected");
      schedule(event);
    });

    // in iOS, label is unclickable, this hack can fix it
    $(elem).find('span').on('click', data, function(event) {
      $(elem).trigger('click', event);
    });
  });

  $("#reverse").on("click", data, function(event) {
    var t = from.getText();
    from.setText(to.getText());
    to.setText(t);
    schedule(event);
  });
}

function initialize (data) {
  var stops = data.stops, times = data.times;

  // generate cities
  var cities = {};
  stops.forEach(function(s) {
    var id = s.stop_id, name = s.stop_name;
    if (!is_defined(cities[name])) {
      cities[name] = [id];
    } else {
      cities[name].push(id);
    };
  });

  // generate select options
  var names = Object.keys(cities);
  from.setOptions(names);
  to.setOptions(names);

  // generate services
  var services = {};
  times.forEach(function(t) {
    var trip_id = t.trip_id;
    if (!is_defined(services[trip_id])) {
      services[trip_id] = {};
    };

    services[trip_id][t.stop_id] = {
      departure_time: str2date(t.departure_time),
      arrival_time: str2date(t.arrival_time),
      stop_sequence: t.stop_sequence
    };
  });

  // init
  var data = {
    cities: cities,
    services: services
  };
  bind_events(data);
  load_cookies();
  schedule({ data: data }); // init schedule
}

function data_checker (names, callback) {
  var mark = {}, all_data = {}, callback = callback;
  names.forEach(function(name) {
    mark[name] = false;
  });
  return function(name, data) {
    mark[name] = true;
    all_data[name] = data;

    var all_true = true;
    for (var n in mark)
      if (!mark[n])
        all_true = false;

    if (all_true)
      callback(all_data);
  };
}

$(function() {
  FastClick.attach(document.body);
});

$(document).ready(function() {
  var checker = data_checker(["stops", "times"], initialize);

  from = rComplete($('#from')[0], { placeholder: "Departure" });
  to = rComplete($('#to')[0], { placeholder: "Destination" });
  when = $('.when-button');

  Papa.parse("data/stops.csv", {
    download: true,
    dynamicTyping: true,
    header: true,
    complete: function(results) {
      checker("stops", results.data);
    }
  });

  Papa.parse("data/times.csv", {
    download: true,
    dynamicTyping: true,
    header: true,
    complete: function(results) {
      checker("times", results.data);
    }
  });
});
