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

$(document).ready(function() {
  var stops, times;
  var checker = data_checker(["stops", "times"], function() {
    // All data is finished
    var cities = {}, options = [], from = $("#from")[0], to = $("#to")[0];

    stops.forEach(function(s) {
      if (/Station/.exec(s.stop_name)) { return; };

      cities[s.stop_name] = s.stop_id;
      if (options.indexOf(s.stop_name) == -1) {
        options.push(s.stop_name);
        from.options[from.options.length] = new Option(s.stop_name, s.stop_id);
        to.options[to.options.length] = new Option(s.stop_name, s.stop_id);
      };
    });
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
