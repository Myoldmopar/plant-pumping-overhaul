require 'openstudio'
require 'json'
require 'pathname'
require_relative 'enums.rb'
require_relative 'run.rb'
require_relative 'config.rb'

def make_a_load_profile_schedule(model, peakval, profile_num, load_or_flow, schedule_type)
  sch_rule_set = OpenStudio::Model::ScheduleRuleset.new(model)
  sch_rule_set.setName("Load Profile #{profile_num} #{load_or_flow} Schedule")
  week_day = sch_rule_set.defaultDaySchedule
  week_day.setName("Load Profile #{profile_num} #{load_or_flow} Day Schedule")
  case schedule_type
  when ScheduleType::CONSTANT
    week_day.addValue(OpenStudio::Time.new(0, 24, 0, 0), peakval)
  when ScheduleType::ON_DURING_DAY
    week_day.addValue(OpenStudio::Time.new(0, 8, 0, 0), 0)
    week_day.addValue(OpenStudio::Time.new(0, 17, 0, 0), peakval)
    week_day.addValue(OpenStudio::Time.new(0, 24, 0, 0), 0)
  when ScheduleType::ON_DURING_NIGHT
    week_day.addValue(OpenStudio::Time.new(0, 8, 0, 0), peakval)
    week_day.addValue(OpenStudio::Time.new(0, 17, 0, 0), 0)
    week_day.addValue(OpenStudio::Time.new(0, 24, 0, 0), peakval)
  when ScheduleType::ON_DURING_MORNING
    week_day.addValue(OpenStudio::Time.new(0, 8, 0, 0), 0)
    week_day.addValue(OpenStudio::Time.new(0, 12, 0, 0), peakval)
    week_day.addValue(OpenStudio::Time.new(0, 24, 0, 0), 0)
  when ScheduleType::ON_DURING_AFTERNOON
    week_day.addValue(OpenStudio::Time.new(0, 12, 0, 0), 0)
    week_day.addValue(OpenStudio::Time.new(0, 17, 0, 0), peakval)
    week_day.addValue(OpenStudio::Time.new(0, 24, 0, 0), 0)
  end
  sch_rule_set
end

def make_a_plant_model(conf)
  # the overall model
  m = OpenStudio::Model::Model.new

  # build up plant loop itself
  pl = OpenStudio::Model::PlantLoop.new(m)
  sp_sched = OpenStudio::Model::ScheduleConstant.new(m)
  sp_sched.setValue(conf[:loop_setpoint_temp])
  spm = OpenStudio::Model::SetpointManagerScheduled.new(m, 'Temperature', sp_sched)
  spm.addToNode(pl.supplyOutletNode)
  if conf[:common_pipe_type] == CommonPipeTypes::COMMON_PIPE
    pl.setCommonPipeSimulation('CommonPipe')
  elsif conf[:common_pipe_type] == CommonPipeTypes::CONTROLLED
    pl.setCommonPipeSimulation('TwoWayCommonPipe')
  end
  if conf[:load_distribution] == LoadDistribution::UNIFORM
    pl.setLoadDistributionScheme('Uniform')
  elsif conf[:load_distribution] == LoadDistribution::SEQUENTIAL
    pl.setLoadDistributionScheme('Sequential')
  end

  # build up primary pump
  if conf[:primary_pump_type] == PumpTypes::CONSTANT_SPEED
    primary_pump = OpenStudio::Model::PumpConstantSpeed.new(m)
  elsif conf[:primary_pump_type] == PumpTypes::VARIABLE_SPEED
    primary_pump = OpenStudio::Model::PumpVariableSpeed.new(m)
  end
  primary_pump.setRatedFlowRate(conf[:primary_pump_vol_flow])
  primary_pump.setName('Primary Pump 1')

  if conf[:primary_pump_location] == PumpPlacement::LOOP_PUMP
    primary_pump.addToNode(pl.supplyInletNode)
    if conf[:primary_pump_control_type] == PumpControl::CONTINUOUS
      primary_pump.setPumpControlType('Continuous')
    elsif conf[:primary_pump_control_type] == PumpControl::INTERMITTENT
      primary_pump.setPumpControlType('Intermittent')
    end
  elsif conf[:primary_pump_location] == PumpPlacement::BRANCH_PUMP
    if conf[:primary_pump_2_type] == PumpTypes::CONSTANT_SPEED
      primary_pump_two = OpenStudio::Model::PumpConstantSpeed.new(m)
    elsif conf[:primary_pump_2_type] == PumpTypes::VARIABLE_SPEED
      primary_pump_two = OpenStudio::Model::PumpVariableSpeed.new(m)
    end
    primary_pump_two.setRatedFlowRate(conf[:primary_pump_2_vol_flow])
    primary_pump_two.setName('Primary Pump 2')
    pl.addSupplyBranchForComponent(primary_pump)
    pl.addSupplyBranchForComponent(primary_pump_two)
    if conf[:primary_pump_2_control_type] == PumpControl::CONTINUOUS
      primary_pump_two.setPumpControlType('Continuous')
    elsif conf[:primary_pump_2_control_type] == PumpControl::INTERMITTENT
      primary_pump_two.setPumpControlType('Intermittent')
    end
  end

  # build up secondary pump if needed
  if conf[:has_secondary_pump]
    if conf[:secondary_pump_type] == PumpTypes::CONSTANT_SPEED
      secondary_pump = OpenStudio::Model::PumpConstantSpeed.new(m)
    elsif conf[:secondary_pump_type] == PumpTypes::VARIABLE_SPEED
      secondary_pump = OpenStudio::Model::PumpVariableSpeed.new(m)
    end
    secondary_pump.setRatedFlowRate(conf[:secondary_pump_vol_flow])
    secondary_pump.setName('Secondary Pump 1')
  end
  if conf[:secondary_pump_location] == PumpPlacement::BRANCH_PUMP
    if conf[:secondary_pump_2_type] == PumpTypes::CONSTANT_SPEED
      secondary_pump_two = OpenStudio::Model::PumpConstantSpeed.new(m)
    elsif conf[:secondary_pump_2_type] == PumpTypes::VARIABLE_SPEED
      secondary_pump_two = OpenStudio::Model::PumpVariableSpeed.new(m)
    end
    secondary_pump_two.setRatedFlowRate(conf[:secondary_pump_2_vol_flow])
    secondary_pump_two.setName('Secondary Pump 2')
  end

  # build up supply equipment
  boil1 = OpenStudio::Model::BoilerHotWater.new(m)
  boil1.setNominalCapacity(conf[:boiler_1_capacity])
  boil2 = OpenStudio::Model::BoilerHotWater.new(m)
  boil2.setNominalCapacity(conf[:boiler_2_capacity])
  if conf[:primary_pump_location] == PumpPlacement::LOOP_PUMP
    pl.addSupplyBranchForComponent(boil1)
    pl.addSupplyBranchForComponent(boil2)
  elsif conf[:primary_pump_location] == PumpPlacement::BRANCH_PUMP
    boil1.addToNode(primary_pump.outletModelObject.get.to_Node.get)
    boil2.addToNode(primary_pump_two.outletModelObject.get.to_Node.get)
  end

  # set up the load profile
  load_sched = make_a_load_profile_schedule(m, conf[:load_profile_load], 1, 'load', conf[:load_profile_sched])
  flow_sched = make_a_load_profile_schedule(m, 1, 1, 'flow', conf[:load_profile_sched])
  profile = OpenStudio::Model::LoadProfilePlant.new(m)
  profile.setPeakFlowRate(conf[:load_profile_vol_flow])
  profile.setLoadSchedule(load_sched)
  profile.setFlowRateFractionSchedule(flow_sched)
  load_sched_two = make_a_load_profile_schedule(m, conf[:load_profile_2_load], 2, 'load', conf[:load_profile_2_sched])
  flow_sched_two = make_a_load_profile_schedule(m, 1, 2, 'flow', conf[:load_profile_2_sched])
  profile_two = OpenStudio::Model::LoadProfilePlant.new(m)
  profile_two.setPeakFlowRate(conf[:load_profile_2_vol_flow])
  profile_two.setLoadSchedule(load_sched_two)
  profile_two.setFlowRateFractionSchedule(flow_sched_two)

  # build up demand side
  if conf[:has_secondary_pump]
    if conf[:secondary_pump_location] == PumpPlacement::LOOP_PUMP
      pl.addDemandBranchForComponent(profile)
      pl.addDemandBranchForComponent(profile_two)
      secondary_pump.addToNode(pl.demandInletNode)
      if conf[:secondary_pump_control_type] == PumpControl::CONTINUOUS
        secondary_pump.setPumpControlType('Continuous')
      elsif conf[:secondary_pump_control_type] == PumpControl::INTERMITTENT
        secondary_pump.setPumpControlType('Intermittent')
      end
    elsif conf[:secondary_pump_location] == PumpPlacement::BRANCH_PUMP
      pl.addDemandBranchForComponent(secondary_pump)
      pl.addDemandBranchForComponent(secondary_pump_two)
      profile.addToNode(secondary_pump.outletModelObject.get.to_Node.get)
      if conf[:secondary_pump_control_type] == PumpControl::CONTINUOUS
        secondary_pump.setPumpControlType('Continuous')
      elsif conf[:secondary_pump_control_type] == PumpControl::INTERMITTENT
        secondary_pump.setPumpControlType('Intermittent')
      end
      profile_two.addToNode(secondary_pump_two.outletModelObject.get.to_Node.get)
      if conf[:secondary_pump_2_control_type] == PumpControl::CONTINUOUS
        secondary_pump_two.setPumpControlType('Continuous')
      elsif conf[:secondary_pump_2_control_type] == PumpControl::INTERMITTENT
        secondary_pump_two.setPumpControlType('Intermittent')
      end
    end
  else
    pl.addDemandBranchForComponent(profile)
    pl.addDemandBranchForComponent(profile_two)
  end

  # now we have a few things to fine tune to make the idf runnable
  ddy_path = OpenStudio::Path.new(DDY_FILE_PATH)
  ddy_idf = OpenStudio::IdfFile.load(ddy_path, 'EnergyPlus'.to_IddFileType).get
  ddy_workspace = OpenStudio::Workspace.new(ddy_idf)
  reverse_translator = OpenStudio::EnergyPlus::ReverseTranslator.new
  ddy_model = reverse_translator.translateWorkspace(ddy_workspace)
  ddy_objects = ddy_model.getDesignDays.select { |d| d.name.get.include?('99.6%') }
  m.addObjects([ddy_objects.first])
  OpenStudio::Model.getSimulationControl(m).setRunSimulationforWeatherFileRunPeriods(false)

  # and add some interesting output variables too
  var_names = ['Pump Mass Flow Rate', 'Pump Electric Power', 'Pump Fluid Heat Gain Rate', 'Plant Load Profile Mass Flow Rate', 'Plant Load Profile Heat Transfer Rate', 'Boiler Heating Rate', 'Boiler Mass Flow Rate', 'Plant Supply Side Outlet Temperature', 'Plant Common Pipe Mass Flow Rate']
  var_names.each do |var|
    var_object = OpenStudio::Model::OutputVariable.new(var, m)
    var_object.setReportingFrequency('Timestep')
  end

  # make the parent path
  parent_folder = File.dirname(conf[:output_file_name])
  FileUtils.mkdir_p(parent_folder)

  # save output file
  m.save(conf[:output_file_name], true)

  # also create a workflow file
  workflow = { 'seed_file': Pathname.new(conf[:output_file_name]).realpath.to_s, 'weather_file': EPW_FILE_PATH }
  workflow_file_path = File.join(parent_folder, 'workflow.osw')
  File.open(workflow_file_path, 'w') do |f|
    f.write(workflow.to_json)
  end

  # run it!
  `ENERGYPLUS_EXE_PATH=/tmp/ep88/EnergyPlus-8-8-0/energyplus openstudio run -w #{workflow_file_path}`
  # run_a_model(conf[:output_file_name], "/home/edwin/Projects/energyplus/repos/1eplus/weather/USA_IL_Chicago-OHare.Intl.AP.725300_TMY3.epw", parent_folder)

  # grab some result
  # puts query_a_model(parent_folder, ['Boiler Heating Rate'], 40)
  # chart_a_column(parent_folder, ['BOILER HOT WATER 1:Boiler Mass Flow Rate'], 'massflowrate.png')
end
