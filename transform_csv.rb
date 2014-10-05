#!/usr/bin/env ruby

require 'csv'

## Output help #################################################################

if ['-h', '--help'].include?(ARGV[0])
  puts 'transform_csv.rb'
  puts '  Duplicates a CSV file with only the specified columns. Source file'
  puts '  must have headers.'
  puts
  puts 'Usage: transform_csv.rb <source_file> <output_keys> [destination_file]'
  puts '  e.g. transform_csv.rb input.csv date,name,amount output.csv'
  exit
end

## Parse arguments #############################################################

def arg_error(message)
  puts 'ERROR: ' + message + ' (Use -h to get help.)'
  exit
end

source_path = ARGV[0]
arg_error('Must specify a valid source_file.') if !source_path || !File.exists?(source_path)

output_keys = ARGV[1].split(',') rescue nil
arg_error('Must specify output_keys.') unless output_keys

destination_path = ARGV[2]
arg_error('destination_file already exists.') if destination_path && File.exists?(destination_path)

# Default to <source_path>_transformed.csv, <source_path>_transformed_2.csv, etc
destination_path ||= lambda do
  base = source_path.sub(File.extname(source_path), '') + '_transformed'
  i = 1
  loop do
    destination_path = base + (i == 1 ? '' : "_#{i}") + '.csv'
    return destination_path unless File.exists?(destination_path)
    i += 1
  end
end.call

## Transform CSV ###############################################################

CSV.open(destination_path, 'wb', write_headers: true, headers: output_keys) do |destination|
  CSV.foreach(source_path, headers: true) do |source_row|
    transformed_row = []
    output_keys.each do |key|
      transformed_row << source_row[key]
    end
    destination << transformed_row
  end
end
