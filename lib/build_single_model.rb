require '/usr/Ruby/openstudio'
require 'json'
require 'pathname'
require_relative 'enums.rb'
require_relative 'post_processing.rb'

# This class captures the logic required to build out plant models
# rubocop:disable Metrics/ClassLength
class ModelBuilder
  def initialize(conf)
    @conf = conf
    @model = OpenStudio::Model::Model.new
    @pl = OpenStudio::Model::PlantLoop.new(@model)
  end

  def make_full_model
    # the overall model
    add_set_point_managers
    add_primary_pumping
    add_secondary_pumping
    add_primary_equipment
    add_load_profiles
    add_loop_demand_side
    enable_design_day_runs
    add_output_vars
  end

  def add_set_point_managers
    # build up plant loop itself
    set_point_schedule = OpenStudio::Model::ScheduleConstant.new(@model)
    set_point_schedule.setValue(@conf[:loop_setpoint_temp])
    spm = OpenStudio::Model::SetpointManagerScheduled.new(@model, 'Temperature', set_point_schedule)
    spm.addToNode(@pl.supplyOutletNode)
    if @conf[:common_pipe_type] == CommonPipeTypes::COMMON_PIPE
      @pl.setCommonPipeSimulation('CommonPipe')
    elsif @conf[:common_pipe_type] == CommonPipeTypes::CONTROLLED
      @pl.setCommonPipeSimulation('TwoWayCommonPipe')
    end
    if @conf[:load_distribution] == LoadDistribution::UNIFORM
      @pl.setLoadDistributionScheme('Uniform')
    elsif @conf[:load_distribution] == LoadDistribution::SEQUENTIAL
      @pl.setLoadDistributionScheme('Sequential')
    end
  end

  def add_primary_pumping
    # build up primary pump
    if @conf[:primary_pump_type] == PumpTypes::CONSTANT_SPEED
      @primary_pump = OpenStudio::Model::PumpConstantSpeed.new(@model)
    elsif @conf[:primary_pump_type] == PumpTypes::VARIABLE_SPEED
      @primary_pump = OpenStudio::Model::PumpVariableSpeed.new(@model)
    else
      raise Exception("Invalid primary_pump_type key in configuration = #{@conf[:primary_pump_type]}")
    end
    @primary_pump.setRatedFlowRate(@conf[:primary_pump_vol_flow])
    @primary_pump.setName('Primary Pump 1')
    if @conf[:primary_pump_location] == PumpPlacement::LOOP_PUMP
      @primary_pump.addToNode(@pl.supplyInletNode)
      if @conf[:primary_pump_control_type] == PumpControl::CONTINUOUS
        @primary_pump.setPumpControlType('Continuous')
      elsif @conf[:primary_pump_control_type] == PumpControl::INTERMITTENT
        @primary_pump.setPumpControlType('Intermittent')
      end
    elsif @conf[:primary_pump_location] == PumpPlacement::BRANCH_PUMP
      if @conf[:primary_pump_2_type] == PumpTypes::CONSTANT_SPEED
        @primary_pump_two = OpenStudio::Model::PumpConstantSpeed.new(@model)
      elsif @conf[:primary_pump_2_type] == PumpTypes::VARIABLE_SPEED
        @primary_pump_two = OpenStudio::Model::PumpVariableSpeed.new(@model)
      else
        raise Exception("Invalid primary_pump_2_type key in configuration = #{@conf[:primary_pump_2_type]}")
      end
      @primary_pump_two.setRatedFlowRate(@conf[:primary_pump_2_vol_flow])
      @primary_pump_two.setName('Primary Pump 2')
      @pl.addSupplyBranchForComponent(@primary_pump)
      @pl.addSupplyBranchForComponent(@primary_pump_two)
      if @conf[:primary_pump_2_control_type] == PumpControl::CONTINUOUS
        @primary_pump_two.setPumpControlType('Continuous')
      elsif @conf[:primary_pump_2_control_type] == PumpControl::INTERMITTENT
        @primary_pump_two.setPumpControlType('Intermittent')
      end
    end
  end

  def add_secondary_pumping
    # build up secondary pump if needed
    if @conf[:has_secondary_pump]
      if @conf[:secondary_pump_type] == PumpTypes::CONSTANT_SPEED
        @secondary_pump = OpenStudio::Model::PumpConstantSpeed.new(@model)
      elsif @conf[:secondary_pump_type] == PumpTypes::VARIABLE_SPEED
        @secondary_pump = OpenStudio::Model::PumpVariableSpeed.new(@model)
      else
        raise Exception("Invalid secondary_pump_type key in configuration = #{@conf[:secondary_pump_type]}")
      end
      @secondary_pump.setRatedFlowRate(@conf[:secondary_pump_vol_flow])
      @secondary_pump.setName('Secondary Pump 1')
    end
    # return early if secondary pump is loop
    return unless @conf[:secondary_pump_location] == PumpPlacement::BRANCH_PUMP
    if @conf[:secondary_pump_2_type] == PumpTypes::CONSTANT_SPEED
      @secondary_pump_two = OpenStudio::Model::PumpConstantSpeed.new(@model)
    elsif @conf[:secondary_pump_2_type] == PumpTypes::VARIABLE_SPEED
      @secondary_pump_two = OpenStudio::Model::PumpVariableSpeed.new(@model)
    else
      raise Exception("Invalid secondary_pump_2_type key in configuration = #{@conf[:secondary_pump_2_type]}")
    end
    @secondary_pump_two.setRatedFlowRate(@conf[:secondary_pump_2_vol_flow])
    @secondary_pump_two.setName('Secondary Pump 2')
  end

  def add_primary_equipment
    # build up supply equipment
    @boil1 = OpenStudio::Model::BoilerHotWater.new(@model)
    @boil1.setNominalCapacity(@conf[:boiler_1_capacity])
    @boil2 = OpenStudio::Model::BoilerHotWater.new(@model)
    @boil2.setNominalCapacity(@conf[:boiler_2_capacity])
    if @conf[:primary_pump_location] == PumpPlacement::LOOP_PUMP
      @pl.addSupplyBranchForComponent(@boil1)
      @pl.addSupplyBranchForComponent(@boil2)
    elsif @conf[:primary_pump_location] == PumpPlacement::BRANCH_PUMP
      @boil1.addToNode(@primary_pump.outletModelObject.get.to_Node.get)
      @boil2.addToNode(@primary_pump_two.outletModelObject.get.to_Node.get)
    end
  end

  def add_load_profiles
    # set up the load profile
    load_sched = make_a_load_profile_schedule(@conf[:load_profile_load], 1, 'load', @conf[:load_profile_sched])
    flow_sched = make_a_load_profile_schedule(1, 1, 'flow', @conf[:load_profile_sched])
    @profile = OpenStudio::Model::LoadProfilePlant.new(@model)
    @profile.setPeakFlowRate(@conf[:load_profile_vol_flow])
    @profile.setLoadSchedule(load_sched)
    @profile.setFlowRateFractionSchedule(flow_sched)
    load_sched_two = make_a_load_profile_schedule(@conf[:load_profile_2_load], 2, 'load', @conf[:load_profile_2_sched])
    flow_sched_two = make_a_load_profile_schedule(1, 2, 'flow', @conf[:load_profile_2_sched])
    @profile_two = OpenStudio::Model::LoadProfilePlant.new(@model)
    @profile_two.setPeakFlowRate(@conf[:load_profile_2_vol_flow])
    @profile_two.setLoadSchedule(load_sched_two)
    @profile_two.setFlowRateFractionSchedule(flow_sched_two)
  end

  def add_loop_demand_side
    # build up demand side
    if @conf[:has_secondary_pump]
      if @conf[:secondary_pump_location] == PumpPlacement::LOOP_PUMP
        @pl.addDemandBranchForComponent(@profile)
        @pl.addDemandBranchForComponent(@profile_two)
        @secondary_pump.addToNode(@pl.demandInletNode)
        if @conf[:secondary_pump_control_type] == PumpControl::CONTINUOUS
          @secondary_pump.setPumpControlType('Continuous')
        elsif @conf[:secondary_pump_control_type] == PumpControl::INTERMITTENT
          @secondary_pump.setPumpControlType('Intermittent')
        end
      elsif @conf[:secondary_pump_location] == PumpPlacement::BRANCH_PUMP
        @pl.addDemandBranchForComponent(@secondary_pump)
        @pl.addDemandBranchForComponent(@secondary_pump_two)
        @profile.addToNode(@secondary_pump.outletModelObject.get.to_Node.get)
        if @conf[:secondary_pump_control_type] == PumpControl::CONTINUOUS
          @secondary_pump.setPumpControlType('Continuous')
        elsif @conf[:secondary_pump_control_type] == PumpControl::INTERMITTENT
          @secondary_pump.setPumpControlType('Intermittent')
        end
        @profile_two.addToNode(@secondary_pump_two.outletModelObject.get.to_Node.get)
        if @conf[:secondary_pump_2_control_type] == PumpControl::CONTINUOUS
          @secondary_pump_two.setPumpControlType('Continuous')
        elsif @conf[:secondary_pump_2_control_type] == PumpControl::INTERMITTENT
          @secondary_pump_two.setPumpControlType('Intermittent')
        end
      end
    else
      @pl.addDemandBranchForComponent(@profile)
      @pl.addDemandBranchForComponent(@profile_two)
    end
  end

  def enable_design_day_runs
    # now we have a few things to fine tune to make the idf runnable
    cur_directory = File.dirname(__FILE__)
    ddy_file_path = File.join(cur_directory, '..', 'support_files', 'USA_IL_Chicago-OHare.Intl.AP.725300_TMY3.ddy')
    ddy_path = OpenStudio::Path.new(ddy_file_path)
    ddy_idf = OpenStudio::IdfFile.load(ddy_path, 'EnergyPlus'.to_IddFileType).get
    ddy_workspace = OpenStudio::Workspace.new(ddy_idf)
    reverse_translator = OpenStudio::EnergyPlus::ReverseTranslator.new
    ddy_model = reverse_translator.translateWorkspace(ddy_workspace)
    ddy_objects = ddy_model.getDesignDays.select { |d| d.name.get.include?('99.6%') }
    @model.addObjects([ddy_objects.first])
    OpenStudio::Model.getSimulationControl(@model).setRunSimulationforWeatherFileRunPeriods(false)
  end

  def add_output_vars
    # and add some interesting output variables too
    var_names = ['Pump Mass Flow Rate', 'Pump Electric Power', 'Pump Fluid Heat Gain Rate', 'Plant Load Profile Mass Flow Rate', 'Plant Load Profile Heat Transfer Rate', 'Boiler Heating Rate', 'Boiler Mass Flow Rate', 'Plant Supply Side Outlet Temperature', 'Plant Common Pipe Mass Flow Rate']
    var_names.each do |var|
      var_object = OpenStudio::Model::OutputVariable.new(var, @model)
      var_object.setReportingFrequency('Timestep')
    end
  end

  def save_and_run_model
    # make the parent path
    parent_folder = File.dirname(@conf[:output_file_name])
    FileUtils.mkdir_p(parent_folder)

    # save output file
    @model.save(@conf[:output_file_name], true)

    # also create a workflow file
    cur_directory = File.dirname(__FILE__)
    epw_file_path = File.join(cur_directory, '..', 'support_files', 'USA_IL_Chicago-OHare.Intl.AP.725300_TMY3.epw')
    workflow = { 'seed_file': Pathname.new(@conf[:output_file_name]).realpath.to_s, 'weather_file': epw_file_path }
    workflow_file_path = File.join(parent_folder, 'workflow.osw')
    File.open(workflow_file_path, 'w') do |f|
      f.write(JSON.pretty_generate(workflow))
    end

    # find E+
    eplus_file_path = File.join(cur_directory, '..', 'EnergyPlus-8.8.0-7c3bbe4830-Linux-x86_64', 'EnergyPlus-8-8-0', 'energyplus')
    `ENERGYPLUS_EXE_PATH=#{eplus_file_path} openstudio run -w #{workflow_file_path}`
    # run_a_model(conf[:output_file_name], "/home/edwin/Projects/energyplus/repos/1eplus/weather/USA_IL_Chicago-OHare.Intl.AP.725300_TMY3.epw", parent_folder)

    # grab some result
    query_a_model(parent_folder, ['Boiler Heating Rate'])
    write_description(parent_folder, @conf[:description])
    # chart_a_column(parent_folder, ['BOILER HOT WATER 1:Boiler Mass Flow Rate'], 'massflowrate.png')
  end

  def make_a_load_profile_schedule(peak_value, profile_num, load_or_flow, schedule_type)
    sch_rule_set = OpenStudio::Model::ScheduleRuleset.new(@model)
    sch_rule_set.setName("Load Profile #{profile_num} #{load_or_flow} Schedule")
    week_day = sch_rule_set.defaultDaySchedule
    week_day.setName("Load Profile #{profile_num} #{load_or_flow} Day Schedule")
    case schedule_type
    when ScheduleType::CONSTANT
      week_day.addValue(OpenStudio::Time.new(0, 24, 0, 0), peak_value)
    when ScheduleType::ON_DURING_DAY
      week_day.addValue(OpenStudio::Time.new(0, 8, 0, 0), 0)
      week_day.addValue(OpenStudio::Time.new(0, 17, 0, 0), peak_value)
      week_day.addValue(OpenStudio::Time.new(0, 24, 0, 0), 0)
    when ScheduleType::ON_DURING_NIGHT
      week_day.addValue(OpenStudio::Time.new(0, 8, 0, 0), peak_value)
      week_day.addValue(OpenStudio::Time.new(0, 17, 0, 0), 0)
      week_day.addValue(OpenStudio::Time.new(0, 24, 0, 0), peak_value)
    when ScheduleType::ON_DURING_MORNING
      week_day.addValue(OpenStudio::Time.new(0, 8, 0, 0), 0)
      week_day.addValue(OpenStudio::Time.new(0, 12, 0, 0), peak_value)
      week_day.addValue(OpenStudio::Time.new(0, 24, 0, 0), 0)
    when ScheduleType::ON_DURING_AFTERNOON
      week_day.addValue(OpenStudio::Time.new(0, 12, 0, 0), 0)
      week_day.addValue(OpenStudio::Time.new(0, 17, 0, 0), peak_value)
      week_day.addValue(OpenStudio::Time.new(0, 24, 0, 0), 0)
    else
      raise Exception("Invalid schedule_type key in configuration = #{@conf[:schedule_type]}")
    end
    sch_rule_set
  end
end
# rubocop:enable Metrics/ClassLength

def make_and_run_plant_model(conf)
  m = ModelBuilder.new(conf)
  m.make_full_model
  m.save_and_run_model
end
