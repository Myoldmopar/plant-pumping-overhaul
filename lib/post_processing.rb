#!/usr/bin/env ruby

require '/usr/Ruby/openstudio'
require 'sqlite3'
require 'gnuplot'

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

# Small structure to capture a single time/datum point
class SingleTimePointData
  def initialize(time, datum)
    @time = time
    @datum = datum
  end

  attr_reader :time
  attr_reader :datum
end

def query_a_model(run_folder, variable_names)
  sql_file = "#{run_folder}/run/eplusout.sql"
  case_number = run_folder.split('/').last
  variable_names.each_with_index do |this_variable, plot_index|
    time_series_data = {}
    begin
      db = SQLite3::Database.open sql_file
      stm = db.prepare 'SELECT * FROM ReportDataDictionary'
      rs = stm.execute
      db_info = []
      rs.each do |row|
        if this_variable == row[6]
          db_info.push(DatabaseInfo.new(row[6], row[5], row[0]))
        end
      end
      db_info.each do |variable|
        time_series_name = "#{variable.variable_name}:#{variable.key_name}"
        stm_two = db.prepare "SELECT * FROM ReportData WHERE ReportDataDictionaryIndex == #{variable.data_dict_index}"
        rs_two = stm_two.execute
        time_series = []
        # need to actually look in the Time table to get the correct time, for now I'm just using an index
        cur_time = 0.0
        rs_two.each do |row|
          cur_time += 0.25
          time_series.push(SingleTimePointData.new(cur_time, row[3]))
        end
        time_series_data[time_series_name] = time_series
        stm_two.close
      end
      plot_results case_number, plot_index, this_variable, time_series_data
    rescue SQLite3::Exception => e
      puts 'Exception occurred'
      puts e
    ensure
      stm.close if stm
      db.close if db
    end
  end
end

def plot_results(run_key, plot_index, this_variable, time_series_data)
  Gnuplot.open do |gp|
    Gnuplot::Plot.new(gp) do |plot|
      plot.terminal 'png'
      this_script_dir = File.dirname(__FILE__)
      plot_file_path = File.join(this_script_dir, '..', 'report', 'media', "plot#{run_key}_#{plot_index}.png")
      plot.output File.expand_path(plot_file_path, __FILE__)
      # plot.xrange '[-10:10]'
      plot.ylabel this_variable
      plot.xlabel 'Hour of Design Day'

      temp_data = []
      time_series_data.each do |time_series_name, time_series|
        x = time_series.collect(&:time)
        y = time_series.collect(&:datum)
        ds = Gnuplot::DataSet.new([x, y]) do |this_ds|
          this_ds.with = 'lines'
          this_ds.title = time_series_name
          this_ds.linewidth = 4
        end
        temp_data.push(ds)
      end

      plot.data = temp_data
    end
  end
end
