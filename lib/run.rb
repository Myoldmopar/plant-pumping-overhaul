#!/usr/bin/env ruby

require 'openstudio'

def run_a_model(osm_file_path, epw_file_path, run_folder)

	epw_path = OpenStudio::Path.new(epw_file_path)
	run_path = OpenStudio::Path.new(run_folder)
	osm_path = OpenStudio::Path.new(osm_file_path)
	co = OpenStudio::Runmanager::ConfigOptions.new(true)
	co.fastFindEnergyPlus()
	co.fastFindRuby()
	wf = OpenStudio::Runmanager::Workflow.new("modeltoidf->energyplus")
	wf.add(co.getTools)
	rm = OpenStudio::Runmanager::RunManager.new(run_path / OpenStudio::Path.new("thisworkflow.db"), true)
	job = wf.create(run_path, osm_path, epw_path)
	puts "Running OpenStudio in run folder: #{run_path}"
	rm.enqueue(job, true)
	rm.waitForFinished
	# now run ReadVars
	FileUtils.cd("#{run_folder}/ModelToIdf/EnergyPlus-0") do
		system "ReadVarsESO"
		system "HVAC-Diagram"
		system "cp eplusout.csv #{run_folder[-2]}#{run_folder[-1]}-eplusout.csv"
	end
	puts "*****DONE"

end

def query_a_model(run_folder, variable_names, row_num = -1)

	csv_file = "#{run_folder}/ModelToIdf/EnergyPlus-0/eplusout.csv"
	return nil if !File.exists?(csv_file)
	csv_rows = IO.readlines(csv_file)
	csv_header_tokens = csv_rows.first.split(',') # dangerous maneuver...
	csv_row_of_interest = csv_rows.last
	if row_num != -1
		csv_row_of_interest = csv_rows[row_num]
	end
	csv_row_of_interest = csv_row_of_interest.split(',')
	puts "Found csv row of interest: "
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
	return var_values

end

def chart_a_column(run_folder, variable_names, output_file_name)

	csv_file = "#{run_folder}/ModelToIdf/EnergyPlus-0/eplusout.csv"
	return nil if !File.exists?(csv_file)
	csv_rows = IO.readlines(csv_file)
	csv_header_tokens = csv_rows.first.split(',') # dangerous maneuver...
	var_columns = {}
	variable_names.each do |var_name|
		csv_header_tokens.each_with_index do |header_token, header_col|
			if header_token.upcase.include?(var_name.upcase)
				var_columns[var_name] = header_col+1
			end
		end
	end
	File.open("#{run_folder}/ModelToIdf/EnergyPlus-0/gp.plt", 'w') { |file|
		file.write("set term png\n")
		file.write("set output \"test.png\"\n")
		file.write("plot x**2\n")
		file.write("set title \"Output Data\"\n")
		file.write("set xlabel \"Date/Time\"\n")
		file.write("set timefmt \"%d/%m/%y\t%H%M\"\n")
		file.write("set xdata time")
	}
	FileUtils.cd("#{run_folder}/ModelToIdf/EnergyPlus-0") do
		system "gnuplot gp.plt"
	end

end
