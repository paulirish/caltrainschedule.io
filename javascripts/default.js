(function(){
  "use strict";

  var from, to, when, data = {};

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
      $('.when-button[value="' + $.cookie("when") + '"]').addClass('selected');
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

  function first_within (ids, service) {
    return ids.map(function(id) {
      return service[id];
    }).filter(function(stop) {
      return is_defined(stop);
    })[0];
  }

  function get_trips (services, from_ids, to_ids, trip_reg) {
    return Object.keys(services)
      .filter(function(trip_id) {
        // select certian trip by when
        return trip_reg.test(trip_id);
      }).map(function(trip_id) {
        var service = services[trip_id];
        var departure = first_within(from_ids, service);
        var arrival = first_within(to_ids, service);

        if (is_defined(departure) && is_defined(arrival) && // both in the trip
            (departure.stop_sequence < arrival.stop_sequence) && // in right order
            (!is_now() || departure.departure_time > new Date())) { // should display by when
          return {
            departure_time: departure.departure_time,
            arrival_time: arrival.arrival_time
          };
        };
      }).filter(function(trip) {
        return is_defined(trip);
      }).sort(compare_trip);
  };

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

  function schedule () {
    var cities = data.cities, services = data.services;
    var from_ids = cities[from.getText()],
        to_ids = cities[to.getText()],
        trip_reg = get_trip_match_regexp();

    // if some input is invalid, just return
    if (!is_defined(from_ids) || !is_defined(to_ids) || !is_defined(trip_reg)) {
      return;
    };

    var trips = get_trips(services, from_ids, to_ids, trip_reg);

    save_cookies();
    render_info(trips[0]);
    render_result(trips);
  }

  function bind_events () {
    [from, to].forEach(function(c) {
      var cancel = $(c.cancel);

      cancel.on("click", function() {
        c.setText('');
        c.input.focus();
      });

      var hide_if_has_input_and_schedule = function() {
        if (c.input.value === '') {
          cancel.hide();
        } else {
          cancel.show();
        };
        schedule();
      };
      c.on("change", hide_if_has_input_and_schedule);
      c.on("complete", hide_if_has_input_and_schedule);
    });

    when.each(function(index, elem) {
      $(elem).on("click", function() {
        when.each(function(index, elem) {
          $(elem).removeClass("selected");
        });
        $(elem).addClass("selected");
        schedule();
      });
    });

    $("#reverse").on("click", function() {
      var t = from.getText();
      from.setText(to.getText());
      to.setText(t);
      schedule();
    });
  }

  function initialize () {
    // remove 300ms delay for mobiles click
    FastClick.attach(document.body);

    // init inputs elements
    from = rComplete($('#from')[0], { placeholder: "Departure" });
    to = rComplete($('#to')[0], { placeholder: "Destination" });
    when = $('.when-button');

    // add cancel buttons
    [from, to].forEach(function(c) {
      var cancel = $('<span class="cancel">x</span>');
      $(c.wrapper).append(cancel);
      c.cancel = cancel[0];
    });

    var cities = data.stops, services = data.times;

    // generate select options
    var names = Object.keys(cities);
    from.setOptions(names);
    to.setOptions(names);

    // generate services
    Object.keys(services).forEach(function(service_id) {
      Object.keys(services[service_id]).forEach(function(stop_id) {
        var t = services[service_id][stop_id];
        services[service_id][stop_id] = {
          departure_time: str2date(t[0]),
          arrival_time: str2date(t[1]),
          stop_sequence: parseInt(t[2])
        };
      });
    });

    // init
    data = {
      cities: cities,
      services: services
    };
    bind_events();
    load_cookies();
    schedule(); // init schedule
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
        if (!mark[n]) {
          all_true = false;
          break;
        };

      if (all_true)
        callback();
    };
  }

  // init after document and data are ready
  var checker = data_checker(["stops", "times"], function() {
    $(initialize);
  });

  // download data
  $.getJSON("data/stops.json", function(stops) {
    data.stops = stops;
    checker("stops");
  });
  $.getJSON("data/times.json", function(times) {
    data.times = times;
    checker("times");
  });

}());
