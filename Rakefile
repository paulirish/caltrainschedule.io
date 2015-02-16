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

  url = 'http://www.caltrain.com/Assets/GTFS/caltrain/GTFS-Caltrain-Devs.zip'
  Tempfile.open('index.html') do |f|
    temp_file = f.path
    system("curl #{url} -o #{temp_file} && unzip -o #{temp_file} -d ./gtfs/ && rm #{temp_file}")
    f.unlink
  end

  [:prepare_data, :update_appcache].each do |task|
    Rake::Task[task].invoke
  end
end

desc "Prepare Data"
task :prepare_data do
  require "csv"
  require "json"
  require "plist"

  # Read from CSV, prepare it with `block`, write what returns to JSON and PLIST files
  # If multiply names, expected to return a hash as NAME => CONTENT
  def prepare_for(*names, &block)
    raise "block is needed for prepare_for!" unless block_given?
    raise "filename is needed!" if names.size < 1

    csvs = names.map { |name|
      CSV.read("gtfs/#{name}.txt", headers: true, header_converters: :symbol, converters: :all)
    }
    hashes = yield(*csvs)
    hashes = { names[0] => hashes } if names.size == 1 # if only one name, make result as a hash
    hashes.each { |name, hash|
      File.write("data/#{name}.json", hash.to_json)
      File.write("data/#{name}.plist", Plist::Emit.dump(hash))
    }
  end

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

  # Remove header and unify station_id by name
  # From:
  #   stop_id,stop_code,stop_name,stop_desc,stop_lat,stop_lon,zone_id,stop_url,location_type,parent_station,platform_code
  #   70011,70011,"San Francisco Caltrain",,  37.776390,-122.394992,1,,0,ctsf,NB
  # To:
  #   stop_name => [stop_id1, stop_id2]
  #   "San Francisco" => [70011, 70012]
  prepare_for("stops") do |csv|
    csv
      .each { |item|
        # check data (if its scheme is changed)
        if item.size != 11 ||
          item.stop_name !~ / Caltrain/
          puts item
          require 'pry'; binding.pry
        end
      }
      .keep_if { |item| item.stop_id.is_a?(Integer) }
      .each { |item|
        name = item.stop_name.gsub(/ Caltrain/, '')
        # TODO: hack the data
        name = "So. San Francisco" if name == "So. San Francisco Station" # shorten the name
        name = "Tamien" if name == "Tamien Station" # merge station
        name = "San Jose" if name == "San Jose Diridon"  # name reversed
        name = "San Jose Diridon" if name == "San Jose Station" # name reversed
        item.stop_name = name
      }
      .group_by(&:stop_name)
      .map { |name, items| # customized Hash#map
        items.map(&:stop_id).sort
      }
  end

  # From:
  #   routes:
  #     route_id,route_short_name,route_long_name,route_desc,route_type,route_url,route_color
  #     Bu-121,,"Bullet",,2,,E31837
  #   trips:
  #     route_id,service_id,trip_id,trip_headsign,trip_short_name,direction_id,block_id,shape_id
  #     Lo-121,CT-14OCT-Caltrain-Saturday-02,6507770-CT-14OCT-Caltrain-Saturday-02,"San Jose Caltrain Station",422,1,,"cal_sf_sj"
  #   stop_times:
  #     trip_id,arrival_time,departure_time,stop_id,stop_sequence,pickup_type,drop_off_type
  #     6507770-CT-14OCT-Caltrain-Saturday-02,08:15:00,08:15:00,70012,1,0,0
  # To:
  #   trips:
  #     { route_long_name => { service_id => { trip_id => [[stop_id, arrival_time/departure_time(in seconds)]] } } }
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
      .keep_if { |item| /14OCT/.match(item.trip_id) } # only 14 OCT plans
      .group_by(&:trip_id)
      .map { |trip_id, trips| # customized Hash#map
        trips
          .sort_by(&:stop_sequence)
          .map { |trip|
            t = trip.arrival_time.split(":").map(&:to_i)
            [trip.stop_id, t[0] * 60 * 60 + t[1] * 60 + t[2]]
          }
      }

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

    routes = routes
      .group_by(&:route_long_name)
      .map { |name, routes|
        routes
          .map(&:route_id)
          .reduce({}) { |h, route_id|
            h.merge(trips[route_id])
          }
      }

    { trips: routes }
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
  begin
    `git checkout master`
    `git push`

    `git checkout gh-pages`
    `git checkout master -- .`
    [:prepare_data, :enable_appcache, :update_appcache, :minify_files].each do |task|
      Rake::Task[task].invoke
    end
    `git add .`
    `git commit -m 'Updated at #{Time.now}.'`
    `git push`
  ensure
    `git checkout master`
  end
end
