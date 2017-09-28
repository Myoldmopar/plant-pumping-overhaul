#!/usr/bin/env ruby

require 'openstudio'

def query_a_model(run_folder, variable_names, row_num = -1)
  csv_file = "#{run_folder}/ModelToIdf/EnergyPlus-0/eplusout.csv"
  return nil if !File.exist?(csv_file)
  csv_rows = IO.readlines(csv_file)
  csv_header_tokens = csv_rows.first.split(',') # dangerous maneuver...
  csv_row_of_interest = csv_rows.last
  if row_num != -1
    csv_row_of_interest = csv_rows[row_num]
  end
  csv_row_of_interest = csv_row_of_interest.split(',')
  puts 'Found csv row of interest: '
  puts csv_row_of_interest
  var_values = {}
  variable_names.each do |var_name|
    #	puts "Searching for variable named: #{var_name}"
    csv_header_tokens.each_with_index do |header_token, header_col|
      if header_token.upcase.include?(var_name.upcase)
        var_values[var_name] = csv_row_of_interest[header_col]
      end
    end
  end
  var_values
end

def chart_a_column(run_folder, variable_names, output_file_name)
  csv_file = "#{run_folder}/ModelToIdf/EnergyPlus-0/eplusout.csv"
  return nil if !File.exist?(csv_file)
  csv_rows = IO.readlines(csv_file)
  csv_header_tokens = csv_rows.first.split(',') # dangerous maneuver...
  var_columns = {}
  variable_names.each do |var_name|
    csv_header_tokens.each_with_index do |header_token, header_col|
      if header_token.upcase.include?(var_name.upcase)
        var_columns[var_name] = header_col + 1
      end
    end
  end
  File.open("#{run_folder}/ModelToIdf/EnergyPlus-0/gp.plt", 'w') do |file|
    file.write("set term png\n")
    file.write("set output \"test.png\"\n")
    file.write("plot x**2\n")
    file.write("set title \"Output Data\"\n")
    file.write("set xlabel \"Date/Time\"\n")
    file.write("set timefmt \"%d/%m/%y\t%H%M\"\n")
    file.write('set xdata time')
  end
  FileUtils.cd("#{run_folder}/ModelToIdf/EnergyPlus-0") do
    system 'gnuplot gp.plt'
  end
end
