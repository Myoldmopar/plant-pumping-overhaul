require "fileutils"
require_relative "enums.rb"
require_relative "build_single_model.rb"

# for kicks, let"s delete the ../Build_directory directory, we might not keep that in here later
Build_directory = '_build'
FileUtils.rm_rf(Dir.glob(Build_directory))

default_configuration = {
	primary_pump_type: PumpTypes::ConstantSpeed,
	primary_pump_vol_flow: 0.0018,
	primary_pump_location: PumpPlacement::LoopPump,
	primary_pump_control_type: PumpControl::Intermittent,
	primary_pump_2_type: PumpTypes::ConstantSpeed,
	primary_pump_2_vol_flow: 0.0009,
	primary_pump_2_control_type: PumpControl::Intermittent,
	common_pipe_type:  CommonPipeTypes::NoCommonPipe,
	boiler_1_capacity: 5000,
	boiler_2_capacity: 5000,
	has_secondary_pump: false,
	secondary_pump_type: PumpTypes::ConstantSpeed,
	secondary_pump_vol_flow: 0.002,
	secondary_pump_location: PumpPlacement::LoopPump,
	secondary_pump_control_type: PumpControl::Intermittent,
	secondary_pump_2_type: PumpTypes::ConstantSpeed,
	secondary_pump_2_vol_flow: 0.001,
	secondary_pump_2_control_type: PumpControl::Intermittent,
	load_distribution: LoadDistribution::Uniform,
	loop_setpoint_temp: 82,
	load_profile_vol_flow: 0.001,
	load_profile_load: 4500,
	load_profile_sched: ScheduleType::OnDuringDay,
	load_profile_2_vol_flow: 0.001,
	load_profile_2_load: 4500,
	load_profile_2_sched: ScheduleType::OnDuringAfternoon
#	output_file_name: "/tmp/testplantloop.osm"
}

const_pri_loop_no_sec_uniform = default_configuration.merge(
	output_file_name: "./#{Build_directory}/01/01-const_pri_loop_no_sec_uniform.osm"
)
make_a_plant_model(const_pri_loop_no_sec_uniform)

const_pri_loop_no_sec_sequent = default_configuration.merge(
	load_distribution: LoadDistribution::Sequential,
	output_file_name: "./#{Build_directory}/02/02-const_pri_loop_no_sec_sequent.osm"
)
make_a_plant_model(const_pri_loop_no_sec_sequent)

varia_pri_loop_no_sec_uniform = default_configuration.merge(
	primary_pump_type: PumpTypes::VariableSpeed,
	output_file_name: "./#{Build_directory}/03/03-varia_pri_loop_no_sec_uniform.osm"
)
make_a_plant_model(varia_pri_loop_no_sec_uniform)

varia_pri_loop_no_sec_sequent = default_configuration.merge(
	primary_pump_type: PumpTypes::VariableSpeed,
	load_distribution: LoadDistribution::Sequential,
	output_file_name: "./#{Build_directory}/04/04-varia_pri_loop_no_sec_sequent.osm"
)
make_a_plant_model(varia_pri_loop_no_sec_sequent)

const_pri_bran_no_sec_uniform = default_configuration.merge(
	primary_pump_location: PumpPlacement::BranchPump,
	primary_pump_vol_flow: 0.0009,
	primary_pump_2_vol_flow: 0.0009,
	output_file_name: "./#{Build_directory}/05/05-const_pri_bran_no_sec_uniform.osm"
)
make_a_plant_model(const_pri_bran_no_sec_uniform)

const_pri_bran_no_sec_sequent = default_configuration.merge(
	primary_pump_location: PumpPlacement::BranchPump,
	load_distribution: LoadDistribution::Sequential,
	primary_pump_vol_flow: 0.0009,
	primary_pump_2_vol_flow: 0.0009,
	output_file_name: "./#{Build_directory}/06/06-const_pri_bran_no_sec_sequent.osm"
)
make_a_plant_model(const_pri_bran_no_sec_sequent)

varia_pri_bran_no_sec_uniform = default_configuration.merge(
	primary_pump_location: PumpPlacement::BranchPump,
	primary_pump_type: PumpTypes::VariableSpeed,
	primary_pump_2_type: PumpTypes::VariableSpeed,
	primary_pump_vol_flow: 0.0009,
	primary_pump_2_vol_flow: 0.0009,
	output_file_name: "./#{Build_directory}/07/07-varia_pri_bran_no_sec_uniform.osm"
)
make_a_plant_model(varia_pri_bran_no_sec_uniform)

varia_pri_bran_no_sec_sequent = default_configuration.merge(
	primary_pump_location: PumpPlacement::BranchPump,
	primary_pump_type: PumpTypes::VariableSpeed,
	primary_pump_2_type: PumpTypes::VariableSpeed,
	load_distribution: LoadDistribution::Sequential,
	primary_pump_vol_flow: 0.0009,
	primary_pump_2_vol_flow: 0.0009,
	output_file_name: "./#{Build_directory}/08/08-varia_pri_bran_no_sec_sequent.osm"
)
make_a_plant_model(varia_pri_bran_no_sec_sequent)

mixed_pri_bran_no_sec_uniform = default_configuration.merge(
	primary_pump_location: PumpPlacement::BranchPump,
	primary_pump_2_type: PumpTypes::VariableSpeed,
	primary_pump_vol_flow: 0.0009,
	primary_pump_2_vol_flow: 0.0009,
	output_file_name: "./#{Build_directory}/09/09-mixed_pri_bran_no_sec_uniform.osm"
)
make_a_plant_model(mixed_pri_bran_no_sec_uniform)

mixed_pri_bran_no_sec_sequent = default_configuration.merge(
	primary_pump_location: PumpPlacement::BranchPump,
	primary_pump_2_type: PumpTypes::VariableSpeed,
	load_distribution: LoadDistribution::Sequential,
	primary_pump_vol_flow: 0.0009,
	primary_pump_2_vol_flow: 0.0009,
	output_file_name: "./#{Build_directory}/10/10-mixed_pri_bran_no_sec_sequent.osm"
)
make_a_plant_model(mixed_pri_bran_no_sec_sequent)

const_pri_loop_const_sec_loop_uniform_onewaycommon = default_configuration.merge(
	common_pipe_type: CommonPipeTypes::CommonPipe,
	has_secondary_pump: true,
	output_file_name: "./#{Build_directory}/11/11-const_pri_loop_const_sec_loop_uniform_onewaycommon.osm"
)
make_a_plant_model(const_pri_loop_const_sec_loop_uniform_onewaycommon)

const_pri_loop_varia_sec_loop_uniform_onewaycommon = default_configuration.merge(
	common_pipe_type: CommonPipeTypes::CommonPipe,
	has_secondary_pump: true,
	secondary_pump_type: PumpTypes::VariableSpeed,
	output_file_name: "./#{Build_directory}/12/12-const_pri_loop_varia_sec_loop_uniform_onewaycommon.osm"
)
make_a_plant_model(const_pri_loop_varia_sec_loop_uniform_onewaycommon)

const_pri_branch_const_sec_loop_uniform_onewaycommon = default_configuration.merge(
	common_pipe_type: CommonPipeTypes::CommonPipe,
	primary_pump_location: PumpPlacement::BranchPump,
	primary_pump_vol_flow: 0.0009,
	has_secondary_pump: true,
	output_file_name: "./#{Build_directory}/13/13-const_pri_branch_const_sec_loop_uniform_onewaycommon.osm"
)
make_a_plant_model(const_pri_branch_const_sec_loop_uniform_onewaycommon)

const_pri_branch_const_sec_loop_sequent_onewaycommon = default_configuration.merge(
	common_pipe_type: CommonPipeTypes::CommonPipe,
	primary_pump_location: PumpPlacement::BranchPump,
	primary_pump_vol_flow: 0.0009,
	load_distribution: LoadDistribution::Sequential,
	has_secondary_pump: true,
	output_file_name: "./#{Build_directory}/14/14-const_pri_branch_const_sec_loop_uniform_onewaycommon.osm"
)
make_a_plant_model(const_pri_branch_const_sec_loop_sequent_onewaycommon)

var_pri_branch_const_sec_loop_uniform_onewaycommon = default_configuration.merge(
	common_pipe_type: CommonPipeTypes::CommonPipe,
	has_secondary_pump: true,
	primary_pump_location: PumpPlacement::BranchPump,
	primary_pump_vol_flow: 0.0009,
	primary_pump_type: PumpTypes::VariableSpeed,
	primary_pump_2_type: PumpTypes::VariableSpeed,
	output_file_name: "./#{Build_directory}/15/15-var_pri_branch_const_sec_loop_uniform_onewaycommon.osm"
)
make_a_plant_model(var_pri_branch_const_sec_loop_uniform_onewaycommon)

var_pri_branch_const_sec_loop_sequent_onewaycommon = default_configuration.merge(
	common_pipe_type: CommonPipeTypes::CommonPipe,
	has_secondary_pump: true,
	primary_pump_location: PumpPlacement::BranchPump,
	primary_pump_vol_flow: 0.0009,
	primary_pump_type: PumpTypes::VariableSpeed,
	primary_pump_2_type: PumpTypes::VariableSpeed,
	load_distribution: LoadDistribution::Sequential,
	output_file_name: "./#{Build_directory}/16/16-var_pri_branch_const_sec_loop_sequent_onewaycommon.osm"
)
make_a_plant_model(var_pri_branch_const_sec_loop_sequent_onewaycommon)

mixed_pri_branch_const_sec_loop_uniform_onewaycommon = default_configuration.merge(
	common_pipe_type: CommonPipeTypes::CommonPipe,
	has_secondary_pump: true,
	primary_pump_location: PumpPlacement::BranchPump,
	primary_pump_vol_flow: 0.0009,
	primary_pump_type: PumpTypes::ConstantSpeed,
	primary_pump_2_type: PumpTypes::VariableSpeed,
	output_file_name: "./#{Build_directory}/17/17-mixed_pri_branch_const_sec_loop_uniform_onewaycommon.osm"
)
make_a_plant_model(mixed_pri_branch_const_sec_loop_uniform_onewaycommon)

mixed_pri_branch_const_sec_loop_sequent_onewaycommon = default_configuration.merge(
	common_pipe_type: CommonPipeTypes::CommonPipe,
	has_secondary_pump: true,
	primary_pump_location: PumpPlacement::BranchPump,
	primary_pump_vol_flow: 0.0009,
	primary_pump_type: PumpTypes::ConstantSpeed,
	primary_pump_2_type: PumpTypes::VariableSpeed,
	load_distribution: LoadDistribution::Sequential,
	output_file_name: "./#{Build_directory}/18/18-mixed_pri_branch_const_sec_loop_sequent_onewaycommon.osm"
)
make_a_plant_model(mixed_pri_branch_const_sec_loop_sequent_onewaycommon)

all_variable_all_branch_pump_sequent_oneway_comment = default_configuration.merge(
	common_pipe_type: CommonPipeTypes::CommonPipe,
	has_secondary_pump: true,
	primary_pump_location: PumpPlacement::BranchPump,
	primary_pump_vol_flow: 0.0009,
	primary_pump_type: PumpTypes::VariableSpeed,
	primary_pump_2_type: PumpTypes::VariableSpeed,
	secondary_pump_type: PumpTypes::VariableSpeed,
	secondary_pump_vol_flow: 0.001,
	secondary_pump_location: PumpPlacement::BranchPump,
	secondary_pump_2_type: PumpTypes::VariableSpeed,
	load_distribution: LoadDistribution::Sequential,
	output_file_name: "./#{Build_directory}/19/19-all_variable_all_branch_pump_sequent_oneway_comment.osm"
)
make_a_plant_model(all_variable_all_branch_pump_sequent_oneway_comment)
