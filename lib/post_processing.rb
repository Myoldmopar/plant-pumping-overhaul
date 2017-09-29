#!/usr/bin/env ruby

require 'openstudio'
require 'sqlite3'

# def query_a_model(run_folder, variable_names, row_num = -1)
#   csv_file = "#{run_folder}/ModelToIdf/EnergyPlus-0/eplusout.csv"
#   return nil unless File.exist?(csv_file)
#   csv_rows = IO.readlines(csv_file)
#   csv_header_tokens = csv_rows.first.split(',') # dangerous maneuver...
#   csv_row_of_interest = csv_rows.last
#   if row_num != -1
#     csv_row_of_interest = csv_rows[row_num]
#   end
#   csv_row_of_interest = csv_row_of_interest.split(',')
#   puts 'Found csv row of interest: '
#   puts csv_row_of_interest
#   var_values = {}
#   variable_names.each do |var_name|
#     #	puts "Searching for variable named: #{var_name}"
#     csv_header_tokens.each_with_index do |header_token, header_col|
#       if header_token.upcase.include?(var_name.upcase)
#         var_values[var_name] = csv_row_of_interest[header_col]
#       end
#     end
#   end
#   var_values
# end

# Small structure to capture database output variable data
class DatabaseInfo
  def initialize(variable_name, key_name, data_dict_index)
    @variable_name = variable_name
    @key_name = key_name
    @data_dict_index = data_dict_index
  end
  attr_reader :variable_name
  attr_reader :key_name
  attr_reader :data_dict_index
end

def query_a_model(run_folder, variable_names)
  sql_file = "#{run_folder}/run/eplusout.sql"
  begin
    db = SQLite3::Database.open sql_file
    stm = db.prepare 'SELECT * FROM ReportDataDictionary'
    rs = stm.execute
    db_info = []
    rs.each do |row|
      if variable_names.include? row[6]
        db_info.push(DatabaseInfo.new(row[6], row[5], row[0]))
      end
    end
    time_series_data = {}
    db_info.each do |variable|
      time_series_name = "#{variable.variable_name}:#{variable.key_name}"
      stm_two = db.prepare "SELECT * FROM ReportData WHERE ReportDataDictionaryIndex == #{variable.data_dict_index}"
      rs_two = stm_two.execute
      time_series = []
      rs_two.each do |row|
        time_series.push(row[3])
      end
      time_series_data[time_series_name] = time_series
      stm_two.close
    end
  rescue SQLite3::Exception => e
    puts 'Exception occurred'
    puts e
  ensure
    stm.close if stm
    db.close if db
  end
end

def chart_a_column(run_folder, variable_names, _output_file_name)
  csv_file = "#{run_folder}/ModelToIdf/EnergyPlus-0/eplusout.csv"
  return nil unless File.exist?(csv_file)
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
