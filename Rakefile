class Hash
  def map(&block)
    if block_given?
      self.inject({}) { |h, (k,v)| h[k] = yield(k, v); h }
    else
      raise "block is needed for map."
    end
  end
end

class File
  def self.write(filename, content, mode='')
    open(filename, "w#{mode}") { |f| f.write(content) }
  end
end

desc "Download GTFS data"
task :download_data do
  require 'tempfile'
  require 'fileutils'

  Dir.mktmpdir('gtfs_') { |tmp_dir|
    url = 'http://www.caltrain.com/Assets/GTFS/caltrain/Caltrain-GTFS.zip'
    Tempfile.open('data.zip') do |temp_file|
      system("curl #{url} -o #{temp_file.path} && unzip -o #{temp_file.path} -d #{tmp_dir}")
      temp_file.unlink
    end

    data_dir = File.join(tmp_dir, '2016APR_GTFS')
    unless File.exist? data_dir
      # Data structure changed, check data.
      require 'pry'; binding.pry
    end

    target_dir = './gtfs/'
    FileUtils.remove_dir(target_dir)
    FileUtils.mv(data_dir, target_dir)
  }

  [:prepare_data, :update_appcache].each do |task|
    Rake::Task[task].invoke
  end
end

desc "Prepare Data"
task :prepare_data do
  require "csv"
  require "json"
  require "plist"

  # Extend CSV
  class CSV
    class Table
      def keep_if(&block)
        delete_if { |item| !yield(item) }
      end
    end
    class Row
      # supports row.attr access method
      def method_missing(meth, *args, &blk)
        if meth =~ /\A(.*)\=\Z/
          self[$1.to_sym] = block_given? ? yield(args[0]) : args[0]
        else
          fetch(meth, *args, &blk)
        end
      end
    end
  end

  def read_CSV(name)
    CSV.read("gtfs/#{name}.txt", headers: true, header_converters: :symbol, converters: :all)
      .each { |item|
        item.service_id = item.service_id.to_s unless item[:service_id].nil?
        item.route_id = item.route_id.to_s unless item[:route_id].nil?
        item.trip_id = item.trip_id.to_s unless item[:trip_id].nil?
      }
  end

  def elem_to_xml(elem)
    case elem
    when Hash
      hash_to_xml(elem)
    when Array
      arr_to_xml(elem)
    else
      elem.to_s
    end
  end
  def arr_to_xml(arr)
    xml = arr.inject("") { |s, elem|
      s + %Q{<elem>#{elem_to_xml(elem)}</elem>}
    }
    "<array>\n#{xml}\n</array>"
  end
  # Transform hash into XML compatible array
  def hash_to_xml(hash)
    xml = hash.inject("") { |s, (k, v)|
      s + "<key>#{k}</key>\n<value>\n#{elem_to_xml(v)}\n</value>"
    }
    "<map>\n#{xml}\n</map>"
  end

  # Read from CSV, prepare it with `block`, write what returns to JSON and PLIST files
  # If multiply names, expected to return a hash as NAME => CONTENT
  def prepare_for(*names, &block)
    raise "block is needed for prepare_for!" unless block_given?
    raise "filename is needed!" if names.size < 1

    csvs = names.map { |name| read_CSV(name) }
    hashes = yield(*csvs)
    raise "prepare_for result has to be a Hash!" unless hashes.is_a? Hash
    hashes.each { |name, hash|
      File.write("data/#{name}.js", "var #{name} = #{hash.to_json};")
    #   File.write("data/#{name}.plist", Plist::Emit.dump(hash))
    #   File.write("data/#{name}.xml", %Q{<?xml version="1.0" encoding="UTF-8"?>\n#{hash_to_xml(hash)}\n})
    }
  end


  # From:
  #   routes:
  #     route_id,route_short_name,route_long_name,route_type,route_color
  #     TaSj-16APR, ,Tamien / San Jose Diridon Caltrain Shuttle,3,41AD49
  #     Lo-16APR, ,Local,2,FFFFFF
  #     Li-16APR, ,Limited,2,FEF0B5
  #     Bu-16APR, ,Baby Bullet,2,E31837
  #   trips:
  #     route_id,service_id,trip_id,trip_headsign,trip_short_name,direction_id,shape_id,wheelchair_accessible,bikes_allowed
  #     TaSj-16APR,CT-16APR-Caltrain-Saturday-02,23a,DIRIDON STATION,23,0,cal_tam_sj,,
  #
  # Find only valid services by route type defined in routes
  valid_service_ids = []
  prepare_for("routes", "trips") do |routes, trips|
    valid_route_ids = routes
      .each { |route|
        unless [2, 3].include? route.route_type
          require 'pry'; binding.pry
        end
      }
      .select { |route| route.route_type == 2 } # 2 for Rail, 3 for bus
      .map(&:route_id)

    valid_service_ids = trips
      .select { |trip| valid_route_ids.include? trip.route_id }
      .map(&:service_id)

    {}
  end

  # From:
  #   calendar:
  #     service_id,monday,tuesday,wednesday,thursday,friday,saturday,sunday,start_date,end_date
  #     CT-16APR-Caltrain-Weekday-01,1,1,1,1,1,0,0,20160404,20190331
  #     CT-16APR-Caltrain-Saturday-02,0,0,0,0,0,1,0,20140329,20190331
  #     CT-16APR-Caltrain-Sunday-02,0,0,0,0,0,0,1,20140323,20190331
  #   calendar_dates:
  #     service_id,date,exception_type
  #     CT-16APR-Caltrain-Weekday-01,20160530,2
  #     CT-16APR-Caltrain-Sunday-02,20160530,1
  # To:
  #   calendar:
  #     service_id => {weekday: bool, saturday: bool, sunday: bool, start_date: date, end_date: date}
  #     CT-16APR-Caltrain-Weekday-01 => {weekday: false, saturday: true, sunday: false, start_date: 20160404, end_date: 20190331}
  #   calendar_dates:
  #     service_id => [[date, exception_type]]
  #     CT-16APR-Caltrain-Weekday-01 => [[20160530,2]]
  prepare_for("calendar", "calendar_dates") do |calendar, calendar_dates|
    now_date = Time.now.strftime("%Y%m%d").to_i

    calendar = calendar
      .select { |service| valid_service_ids.include? service.service_id }
      .select { |service|
        warn "Drop outdated service #{service.service_id} ends at #{service.end_date}." if service.end_date < now_date
        service.end_date >= now_date
      }
      .each { |service|
        # Weekday should be available all together or none of them. If not, check data.
        weekday_sum = [:monday, :tuesday, :wednesday, :thursday, :friday].inject(0) { |sum, day| sum + service[day]}
        unless [0, 5].include? weekday_sum
          require 'pry'; binding.pry
        end
      }
      .group_by(&:service_id)
      .map { |service_id, items|
        if items.size != 1
          require 'pry'; binding.pry
        end
        item = items[0]
        weekday_sum = [:monday, :tuesday, :wednesday, :thursday, :friday].inject(0) { |sum, day| sum + item[day]}
        {
          weekday: weekday_sum == 5,
          saturday: item.saturday == 1,
          sunday: item.sunday == 1,
          start_date: item.start_date,
          end_date: item.end_date,
        }
      }

    # update valid_service_ids to remove out-dated services
    valid_service_ids = calendar.keys

    dates = calendar_dates
      .select { |service|
        warn "Drop outdated service_date #{service.service_id} at #{service.date}." unless valid_service_ids.include? service.service_id
        valid_service_ids.include? service.service_id
      }
      .select { |service|
        warn "Drop outdated service_date #{service.service_id} at #{service.date}." if service.date < now_date
        service.date >= now_date
      }
      .group_by(&:service_id)
      .map { |service_id, items|
        items.map { |item| item.fields[1..-1] }
      }

    { calendar: calendar, calendar_dates: dates }
  end

  # Remove header and unify station_id by name
  # From:
  #   stop_id,stop_code,stop_name,stop_lat,stop_lon,zone_id,stop_url,location_type,parent_station,platform_code,wheelchair_boarding
  #   70011,70011,San Francisco Caltrain,37.77639,-122.394992,1,http://www.caltrain.com/stations/sanfranciscostation.html,0,ctsf,NB,1
  #   70012,70012,San Francisco Caltrain,37.776348,-122.394935,1,http://www.caltrain.com/stations/sanfranciscostation.html,0,ctsf,SB,1
  # To:
  #   stop_name => [stop_id1, stop_id2]
  #   "San Francisco" => [70021, 70022]
  prepare_for("stops") do |stops|
    stops = stops
      .each { |item|
        # check data (if its scheme is changed)
        if item.stop_name !~ / Caltrain/
          require 'pry'; binding.pry
        end
      }
      .select { |item| item.stop_id.is_a?(Integer) }
      .sort_by(&:stop_lat).reverse # sort stations from north to south
      .each { |item|
        # shorten the name and merge San Jose with San Jose Diridon
        item.stop_name.gsub!(/ (Caltrain|Station)/, '').gsub!(/^San Jose$/, 'San Jose Diridon')
      }
      .group_by(&:stop_name)
      .map { |name, items| # customized Hash#map
        items.map(&:stop_id).sort
      }

    {stops: stops}
  end

  # From:
  #   routes:
  #     route_id,agency_id,route_short_name,route_long_name,route_type,route_color,route_text_color
  #     SHUTTLE,CT,,SHUTTLE,3,,
  #     LOCAL,CT,LOCAL,,2,,
  #     LIMITED,CT,,LIMITED,2,,
  #     BABY BULLET,CT,,BABY BULLET,2,,
  #   trips:
  #     route_id,service_id,trip_id,trip_headsign,direction_id,block_id,shape_id,trip_short_name
  #     SHUTTLE,4951,RTD6320540,DIRIDON STATION,0,,,
  #     SHUTTLE,4951,RTD6320555,DIRIDON STATION,0,,,
  #   stop_times:
  #     trip_id,arrival_time,departure_time,stop_id,stop_sequence
  #     RTD6320540,07:33:00,07:33:00,777403,1
  #     RTD6320540,07:45:00,07:45:00,777402,2
  # To:
  #   routes:
  #     { route_id => { service_id => { trip_id => [[stop_id, arrival_time/departure_time(in seconds)]] } } }
  #     { "Bullet" => { "CT-14OCT-XXX" => { "650770-CT-14OCT-XXX" => [[70012, 29700], ...] } } }
  prepare_for("routes", "trips", "stop_times") do |routes, trips, stop_times|
    # { trip_id => [[stop_id, arrival_time/departure_time(in seconds)]] }
    times = stop_times
      .each { |item|
        # check data (if its scheme is changed)
        if item.arrival_time != item.departure_time
          require 'pry'; binding.pry
        end
      }
      .group_by(&:trip_id)
      .map { |trip_id, trips_values| # customized Hash#map
        trips_values
          .sort_by(&:stop_sequence)
          .map { |trip|
            t = trip.arrival_time.split(":").map(&:to_i)
            [trip.stop_id, t[0] * 60 * 60 + t[1] * 60 + t[2]]
          }
      }

    # { route_id => { service_id => { trip_id => ... } } }
    trips = trips
      .group_by(&:route_id)
      .map { |route_id, route_trips|
        route_trips
          .group_by(&:service_id)
          .map { |service_id, service_trips|
            service_trips
              .group_by(&:trip_id)
              .map { |trip_id, trip_trips|
                times[trip_id]
              }
          }
      }

    # { route_id => { service_id => ... } }
    routes = routes
      .select { |route| route.route_type == 2 } # 2 for Rail, 3 for bus
      .group_by(&:route_id)
      .map { |name, routes_values|
        routes_values
          .map(&:route_id)
          .inject({}) { |h, route_id|
            h.merge(trips[route_id])
          }
      }

    { routes: routes }
  end

  puts "Prepared Data."
end

desc "Enable Appcache."
task :enable_appcache do
  require 'tempfile'
  require 'fileutils'

  path = 'index.html'
  temp_file = Tempfile.new('index.html')
  begin
    File.open(path, 'r') do |file|
      file.each_line do |line|
        if line.match("<html>")
          temp_file.puts '<html manifest="rCaltrain.appcache">'
        else
          temp_file.puts line
        end
      end
    end
    temp_file.close
    FileUtils.mv(temp_file.path, path)
  ensure
    temp_file.close
    temp_file.unlink
  end

  puts "Enabled Appcache."
end

desc "Update Appcache."
task :update_appcache do
  require 'tempfile'
  require 'fileutils'

  path = 'rCaltrain.appcache'
  temp_file = Tempfile.new('rCaltrain.appcache')
  begin
    File.open(path, 'r') do |file|
      file.each_line do |line|
        if line.match(/# Updated at /)
          temp_file.puts "# Updated at #{Time.now}"
        else
          temp_file.puts line
        end
      end
    end
    temp_file.close
    FileUtils.mv(temp_file.path, path)
  ensure
    temp_file.close
    temp_file.unlink
  end

  puts "Updated Appcache."
end

desc "Minify Files."
task :minify_files do
  require 'tempfile'
  require 'fileutils'

  path = 'javascripts/default.js'
  temp_file = Tempfile.new('default.js')
  begin
    `uglifyjs #{path} -o #{temp_file.path} -c -m`
    FileUtils.mv(temp_file.path, path)
  ensure
    temp_file.close
    temp_file.unlink
  end

  path = 'stylesheets/default.css'
  temp_file = Tempfile.new('default.css')
  begin
    `uglifycss #{path} > #{temp_file.path}`
    FileUtils.mv(temp_file.path, path)
  ensure
    temp_file.close
    temp_file.unlink
  end

  puts "Minified files."
end

desc "Publish"
task :publish do
  def run(cmd)
    res = `#{cmd}`
    unless $?.success?
      warn "#{cmd} failed:\n#{res}\n"
      abort
    end
  end

  begin
    # ensure working dir is clean
    run('[ -n "$(git status --porcelain)" ] && exit 1 || exit 0')

    # push master branch
    run("git checkout master")
    run("git pull origin")
    run("git push origin master:master")

    # push gh-pages branch
    run("git checkout gh-pages")
    run("git pull origin")
    run("git checkout master -- .")
    [:prepare_data, :enable_appcache, :update_appcache, :minify_files].each do |task|
      Rake::Task[task].invoke
    end
    run("git add .")
    run("git commit -m 'Updated at #{Time.now}.'")
    run("git push origin gh-pages:gh-pages")
  ensure
    run("git checkout master")
  end
end
