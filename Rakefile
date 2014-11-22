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
  File.open("data/stops.json", "wb") do |f|
    f.write(hash.to_json)
  end
  # Plist
  File.open("data/stops.plist", "wb") do |f|
    f.write(Plist::Emit.dump(hash))
  end

  hash = CSV.read("gtfs/stop_times.txt")[1..-1]
    .map! { |s| s[0..4] }
    .keep_if { |s| /14OCT/.match(s[0]) }
    .inject(Hash.new { |h, k| h[k] = {} }) { |h, s|
      id = s[0].split('-')
      s[0] = [id[0], id[4]].join('-')
      # (trip_id, stop_id) => (arrival_time, departure_time, stop_sequence)
      h[s[0]][s[3]] = [s[1], s[2], s[4]]
      h
    }
  # JSON
  File.open("data/times.json", "wb") do |f|
    f.write(hash.to_json)
  end
  # Plist
  File.open("data/times.plist", "wb") do |f|
    f.write(Plist::Emit.dump(hash))
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
