load 'prepare.rb'

guard :shell do
  watch(/gtfs\/.*/) { prepare_data }
  watch(/src\/.*/) { minify_files }
  watch(/.*\.html$|^javascripts\/.*$|^stylesheets\/.*$|^data\/.*$/) { update_appcache }
end
