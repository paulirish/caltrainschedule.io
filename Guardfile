load 'prepare.rb'

guard :shell do
  watch(/gtfs\/.*/) { prepare_data }
  watch(/src\/.*/) { minify_files }
  watch(/.*\.html$|^javascripts\/.*$|^stylesheets\/.*$|^data\/.*$/) { update_appcache }

  callback(:start_begin) {
    Thread.new {
      `kill -9 #{`lsof -i :8000`.split("\n").last.split[1]}` rescue nil
      `python -m SimpleHTTPServer &`
      `open http://localhost:8000`
    }
  }
end
