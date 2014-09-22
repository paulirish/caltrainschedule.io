require "csv"

["south_weekday", "north_weekday"].each do |filename|
  parsed_file = CSV.read("#{filename}.tsv", col_sep: "\t" )
  parsed_file = parsed_file[1...-1] # remove zone info

  raise "DATA error!" if parsed_file[0][25].match(/[\d\:]+/) # check name column in the middle
  parsed_file.map! do |row|
    row.delete_at(25) # delete name column in the middle
    row.map! { |t| ["-", " "].include?(t) ? nil : t }
    row[1...-2] # remove zone info at begin and end, and name at the end
  end

  CSV.open("#{filename}.data.tsv", "wb", col_sep: "\t") do |c|
    parsed_file.each { |i| c << i }
  end
end
