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

  # remove header and unify station_id by name
  hash = CSV.read("gtfs/stops.txt")[1..-1]
    .map! { |s| [s[2], s[0]] }
    .keep_if { |s| /\A\d+\Z/.match(s.last) }
    .inject(Hash.new { |h, k| h[k] = [] }) { |h, s|
      name = s[0].gsub(/ Caltrain/, '')
      # TODO: hack the data
      name = "So. San Francisco" if name == "So. San Francisco Station" # shorten the name
      name = "Tamien" if name == "Tamien Station" # merge station
      name = "San Jose" if name == "San Jose Diridon"  # name reversed
      name = "San Jose Diridon" if name == "San Jose Station" # name reversed
      # stop_name => [stop_id]
      h[name].push(s.last.to_i)
      h
    }
  # JSON
  File.write("data/stops.json", hash.to_json)
  # Plist
  File.write("data/stops.plist", Plist::Emit.dump(hash))

  # From:
  #   trip_id,arrival_time,departure_time,stop_id,stop_sequence,pickup_type,drop_off_type
  #   6507770-CT-14OCT-Caltrain-Saturday-02,08:15:00,08:15:00,70012,1,0,0
  # To:
  #   service_id => [[stop_id, arrival_time/departure_time(in seconds)]]
  #   Saturday-6507770-02 => [[70012, 29700], [70022, 30000], ...]
  hash = CSV.read("gtfs/stop_times.txt")[1..-1] # remove CSV header
    .each { |item|
      # check data (if its scheme is changed)
      if item.size != 7 || # totally 7 columns
        item[1] != item[2] || # if arrival_time is not equal to departure_time, something is changed
        item[5] != '0' || item[6] != '0' # pickup_type and drop_off_type should be 0
        require 'pry'; binding.pry
      end
    }
    .map { |item| item[0..4] } # trip_id,arrival_time,departure_time,stop_id,stop_sequence
    .keep_if { |item| /14OCT/.match(item[0]) } # only 14 OCT plans
    .map { |item| id = item[0].split('-'); item[0] = [id[4], id[0], id[5]].join('-'); item } # generate service_id
    .group_by { |item| item.first } # group_by service_id
    .map { |service_id, trips| # customized Hash#map
      trips
        .sort_by { |trip| trip.last.to_i } # sort by stop_sequence
        .map { |trip|
          t = trip[1].split(":").map(&:to_i) # split arrival_time into hh:mm:ss
          [trip[3].to_i, t[0] * 60 * 60 + t[1] * 60 + t[2]] # stop_id, arrival_time/departure_time
        }
    }
  # JSON
  File.write("data/times.json", hash.to_json)
  # Plist
  File.write("data/times.plist", Plist::Emit.dump(hash))

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
