require 'fileutils'
require_relative 'enums.rb'
require_relative 'build_single_model.rb'

# for kicks, let"s delete the ../Build_directory directory, we might not keep that in here later
BUILD_DIRECTORY = '_build'.freeze
FileUtils.rm_rf(Dir.glob(BUILD_DIRECTORY))

# The default configuration builds out a plant loop with:
# - a single, constant speed, loop pump on the supply side, no common pipe
# - two boilers, each with 5000 W of heating capacity, with load distributed uniformly between them
# - two load profiles, each with 4500 W of peaking heating demand, on during the day
default_configuration = {
  primary_pump_type: PumpTypes::CONSTANT_SPEED,
  primary_pump_vol_flow: 0.0018,
  primary_pump_location: PumpPlacement::LOOP_PUMP,
  primary_pump_control_type: PumpControl::INTERMITTENT,
  primary_pump_2_type: PumpTypes::CONSTANT_SPEED,
  primary_pump_2_vol_flow: 0.0009,
  primary_pump_2_control_type: PumpControl::INTERMITTENT,
  common_pipe_type: CommonPipeTypes::NO_COMMON_PIPE,
  boiler_1_capacity: 5000,
  boiler_2_capacity: 5000,
  has_secondary_pump: false,
  secondary_pump_type: PumpTypes::CONSTANT_SPEED,
  secondary_pump_vol_flow: 0.002,
  secondary_pump_location: PumpPlacement::LOOP_PUMP,
  secondary_pump_control_type: PumpControl::INTERMITTENT,
  secondary_pump_2_type: PumpTypes::CONSTANT_SPEED,
  secondary_pump_2_vol_flow: 0.001,
  secondary_pump_2_control_type: PumpControl::INTERMITTENT,
  load_distribution: LoadDistribution::UNIFORM,
  loop_setpoint_temp: 82,
  load_profile_vol_flow: 0.001,
  load_profile_load: 4500,
  load_profile_sched: ScheduleType::ON_DURING_DAY,
  load_profile_2_vol_flow: 0.001,
  load_profile_2_load: 4500,
  load_profile_2_sched: ScheduleType::ON_DURING_AFTERNOON
  #	output_file_name: "/tmp/testplantloop.osm"
}

const_pri_loop_no_sec_uniform = default_configuration.merge(
  output_file_name: "./#{BUILD_DIRECTORY}/01/01-const_pri_loop_no_sec_uniform.osm"
)
make_and_run_plant_model(const_pri_loop_no_sec_uniform)

const_pri_loop_no_sec_sequent = default_configuration.merge(
  load_distribution: LoadDistribution::SEQUENTIAL,
  output_file_name: "./#{BUILD_DIRECTORY}/02/02-const_pri_loop_no_sec_sequent.osm"
)
make_and_run_plant_model(const_pri_loop_no_sec_sequent)

varia_pri_loop_no_sec_uniform = default_configuration.merge(
  primary_pump_type: PumpTypes::VARIABLE_SPEED,
  output_file_name: "./#{BUILD_DIRECTORY}/03/03-varia_pri_loop_no_sec_uniform.osm"
)
make_and_run_plant_model(varia_pri_loop_no_sec_uniform)

varia_pri_loop_no_sec_sequent = default_configuration.merge(
  primary_pump_type: PumpTypes::VARIABLE_SPEED,
  load_distribution: LoadDistribution::SEQUENTIAL,
  output_file_name: "./#{BUILD_DIRECTORY}/04/04-varia_pri_loop_no_sec_sequent.osm"
)
make_and_run_plant_model(varia_pri_loop_no_sec_sequent)

const_pri_bran_no_sec_uniform = default_configuration.merge(
  primary_pump_location: PumpPlacement::BRANCH_PUMP,
  primary_pump_vol_flow: 0.0009,
  primary_pump_2_vol_flow: 0.0009,
  output_file_name: "./#{BUILD_DIRECTORY}/05/05-const_pri_bran_no_sec_uniform.osm"
)
make_and_run_plant_model(const_pri_bran_no_sec_uniform)

const_pri_bran_no_sec_sequent = default_configuration.merge(
  primary_pump_location: PumpPlacement::BRANCH_PUMP,
  load_distribution: LoadDistribution::SEQUENTIAL,
  primary_pump_vol_flow: 0.0009,
  primary_pump_2_vol_flow: 0.0009,
  output_file_name: "./#{BUILD_DIRECTORY}/06/06-const_pri_bran_no_sec_sequent.osm"
)
make_and_run_plant_model(const_pri_bran_no_sec_sequent)

varia_pri_bran_no_sec_uniform = default_configuration.merge(
  primary_pump_location: PumpPlacement::BRANCH_PUMP,
  primary_pump_type: PumpTypes::VARIABLE_SPEED,
  primary_pump_2_type: PumpTypes::VARIABLE_SPEED,
  primary_pump_vol_flow: 0.0009,
  primary_pump_2_vol_flow: 0.0009,
  output_file_name: "./#{BUILD_DIRECTORY}/07/07-varia_pri_bran_no_sec_uniform.osm"
)
make_and_run_plant_model(varia_pri_bran_no_sec_uniform)

varia_pri_bran_no_sec_sequent = default_configuration.merge(
  primary_pump_location: PumpPlacement::BRANCH_PUMP,
  primary_pump_type: PumpTypes::VARIABLE_SPEED,
  primary_pump_2_type: PumpTypes::VARIABLE_SPEED,
  load_distribution: LoadDistribution::SEQUENTIAL,
  primary_pump_vol_flow: 0.0009,
  primary_pump_2_vol_flow: 0.0009,
  output_file_name: "./#{BUILD_DIRECTORY}/08/08-varia_pri_bran_no_sec_sequent.osm"
)
make_and_run_plant_model(varia_pri_bran_no_sec_sequent)

mixed_pri_bran_no_sec_uniform = default_configuration.merge(
  primary_pump_location: PumpPlacement::BRANCH_PUMP,
  primary_pump_2_type: PumpTypes::VARIABLE_SPEED,
  primary_pump_vol_flow: 0.0009,
  primary_pump_2_vol_flow: 0.0009,
  output_file_name: "./#{BUILD_DIRECTORY}/09/09-mixed_pri_bran_no_sec_uniform.osm"
)
make_and_run_plant_model(mixed_pri_bran_no_sec_uniform)

mixed_pri_bran_no_sec_sequent = default_configuration.merge(
  primary_pump_location: PumpPlacement::BRANCH_PUMP,
  primary_pump_2_type: PumpTypes::VARIABLE_SPEED,
  load_distribution: LoadDistribution::SEQUENTIAL,
  primary_pump_vol_flow: 0.0009,
  primary_pump_2_vol_flow: 0.0009,
  output_file_name: "./#{BUILD_DIRECTORY}/10/10-mixed_pri_bran_no_sec_sequent.osm"
)
make_and_run_plant_model(mixed_pri_bran_no_sec_sequent)

const_pri_loop_const_sec_loop_uniform_onewaycommon = default_configuration.merge(
  common_pipe_type: CommonPipeTypes::COMMON_PIPE,
  has_secondary_pump: true,
  output_file_name: "./#{BUILD_DIRECTORY}/11/11-const_pri_loop_const_sec_loop_uniform_onewaycommon.osm"
)
make_and_run_plant_model(const_pri_loop_const_sec_loop_uniform_onewaycommon)

const_pri_loop_varia_sec_loop_uniform_onewaycommon = default_configuration.merge(
  common_pipe_type: CommonPipeTypes::COMMON_PIPE,
  has_secondary_pump: true,
  secondary_pump_type: PumpTypes::VARIABLE_SPEED,
  output_file_name: "./#{BUILD_DIRECTORY}/12/12-const_pri_loop_varia_sec_loop_uniform_onewaycommon.osm"
)
make_and_run_plant_model(const_pri_loop_varia_sec_loop_uniform_onewaycommon)

const_pri_branch_const_sec_loop_uniform_onewaycommon = default_configuration.merge(
  common_pipe_type: CommonPipeTypes::COMMON_PIPE,
  primary_pump_location: PumpPlacement::BRANCH_PUMP,
  primary_pump_vol_flow: 0.0009,
  has_secondary_pump: true,
  output_file_name: "./#{BUILD_DIRECTORY}/13/13-const_pri_branch_const_sec_loop_uniform_onewaycommon.osm"
)
make_and_run_plant_model(const_pri_branch_const_sec_loop_uniform_onewaycommon)

const_pri_branch_const_sec_loop_sequent_onewaycommon = default_configuration.merge(
  common_pipe_type: CommonPipeTypes::COMMON_PIPE,
  primary_pump_location: PumpPlacement::BRANCH_PUMP,
  primary_pump_vol_flow: 0.0009,
  load_distribution: LoadDistribution::SEQUENTIAL,
  has_secondary_pump: true,
  output_file_name: "./#{BUILD_DIRECTORY}/14/14-const_pri_branch_const_sec_loop_uniform_onewaycommon.osm"
)
make_and_run_plant_model(const_pri_branch_const_sec_loop_sequent_onewaycommon)

var_pri_branch_const_sec_loop_uniform_onewaycommon = default_configuration.merge(
  common_pipe_type: CommonPipeTypes::COMMON_PIPE,
  has_secondary_pump: true,
  primary_pump_location: PumpPlacement::BRANCH_PUMP,
  primary_pump_vol_flow: 0.0009,
  primary_pump_type: PumpTypes::VARIABLE_SPEED,
  primary_pump_2_type: PumpTypes::VARIABLE_SPEED,
  output_file_name: "./#{BUILD_DIRECTORY}/15/15-var_pri_branch_const_sec_loop_uniform_onewaycommon.osm"
)
make_and_run_plant_model(var_pri_branch_const_sec_loop_uniform_onewaycommon)

var_pri_branch_const_sec_loop_sequent_onewaycommon = default_configuration.merge(
  common_pipe_type: CommonPipeTypes::COMMON_PIPE,
  has_secondary_pump: true,
  primary_pump_location: PumpPlacement::BRANCH_PUMP,
  primary_pump_vol_flow: 0.0009,
  primary_pump_type: PumpTypes::VARIABLE_SPEED,
  primary_pump_2_type: PumpTypes::VARIABLE_SPEED,
  load_distribution: LoadDistribution::SEQUENTIAL,
  output_file_name: "./#{BUILD_DIRECTORY}/16/16-var_pri_branch_const_sec_loop_sequent_onewaycommon.osm"
)
make_and_run_plant_model(var_pri_branch_const_sec_loop_sequent_onewaycommon)

mixed_pri_branch_const_sec_loop_uniform_onewaycommon = default_configuration.merge(
  common_pipe_type: CommonPipeTypes::COMMON_PIPE,
  has_secondary_pump: true,
  primary_pump_location: PumpPlacement::BRANCH_PUMP,
  primary_pump_vol_flow: 0.0009,
  primary_pump_type: PumpTypes::CONSTANT_SPEED,
  primary_pump_2_type: PumpTypes::VARIABLE_SPEED,
  output_file_name: "./#{BUILD_DIRECTORY}/17/17-mixed_pri_branch_const_sec_loop_uniform_onewaycommon.osm"
)
make_and_run_plant_model(mixed_pri_branch_const_sec_loop_uniform_onewaycommon)

mixed_pri_branch_const_sec_loop_sequent_onewaycommon = default_configuration.merge(
  common_pipe_type: CommonPipeTypes::COMMON_PIPE,
  has_secondary_pump: true,
  primary_pump_location: PumpPlacement::BRANCH_PUMP,
  primary_pump_vol_flow: 0.0009,
  primary_pump_type: PumpTypes::CONSTANT_SPEED,
  primary_pump_2_type: PumpTypes::VARIABLE_SPEED,
  load_distribution: LoadDistribution::SEQUENTIAL,
  output_file_name: "./#{BUILD_DIRECTORY}/18/18-mixed_pri_branch_const_sec_loop_sequent_onewaycommon.osm"
)
make_and_run_plant_model(mixed_pri_branch_const_sec_loop_sequent_onewaycommon)

all_variable_all_branch_pump_sequent_oneway_comment = default_configuration.merge(
  common_pipe_type: CommonPipeTypes::COMMON_PIPE,
  has_secondary_pump: true,
  primary_pump_location: PumpPlacement::BRANCH_PUMP,
  primary_pump_vol_flow: 0.0009,
  primary_pump_type: PumpTypes::VARIABLE_SPEED,
  primary_pump_2_type: PumpTypes::VARIABLE_SPEED,
  secondary_pump_type: PumpTypes::VARIABLE_SPEED,
  secondary_pump_vol_flow: 0.001,
  secondary_pump_location: PumpPlacement::BRANCH_PUMP,
  secondary_pump_2_type: PumpTypes::VARIABLE_SPEED,
  load_distribution: LoadDistribution::SEQUENTIAL,
  output_file_name: "./#{BUILD_DIRECTORY}/19/19-all_variable_all_branch_pump_sequent_oneway_comment.osm"
)
make_and_run_plant_model(all_variable_all_branch_pump_sequent_oneway_comment)
