desc "Prepare Data"
task :prepare_data do
  require "csv"
  require "json"

  # stop_name, stop_id
  stops = CSV.read("gtfs/stops.txt").map! { |s| [s[2], s[0]]}
  stops.shift
  stops
    .keep_if { |s| /\A\d+\Z/.match(s.last) }
    .map! { |s|
      s.first.gsub!(/ Caltrain/, '')
      # TODO: hack the data
      s[0] = "So. San Francisco" if s[0] == "So. San Francisco Station" # shorten the name
      s[0] = "Tamien" if s[0] == "Tamien Station" # merge station
      s[0] = "San Jose" if s[0] == "San Jose Diridon"  # name reversed
      s[0] = "San Jose Diridon" if s[0] == "San Jose Station" # name reversed
      s
    }
  stops = stops
    .group_by{|s| s.first}
    .inject({}) {|h, (k,v)| h[k] = v.map{|v| v.last}; h}
  File.open("data/stops.json", "wb").write(stops.to_json)

  times = CSV.read("gtfs/stop_times.txt").map! { |s| s[0..4]}
  header = times.shift
  times
    .keep_if { |s| /14OCT/.match(s[0]) }
    .map! { |s| id = s[0].split('-'); s[0] = [id[0], id[4]].join('-'); s }
  times.unshift(header)
  CSV.open("data/times.csv", "wb") { |c| times.each { |i| c << i } }

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
