# Defines different pump types
module PumpTypes
  CONSTANT_SPEED = 0
  VARIABLE_SPEED = 1
end

# Defines different common pipe types
module CommonPipeTypes
  NO_COMMON_PIPE = 0
  COMMON_PIPE = 1
  CONTROLLED = 2
end

# Defines different load distribution strategies
module LoadDistribution
  UNIFORM = 0
  SEQUENTIAL = 1
end

# Defines different pump placement options
module PumpPlacement
  LOOP_PUMP = 0
  BRANCH_PUMP = 1
end

# Defines different schedule strategies
module ScheduleType
  CONSTANT = 0
  ON_DURING_DAY = 1
  ON_DURING_NIGHT = 2
  ON_DURING_MORNING = 3
  ON_DURING_AFTERNOON = 4
end

# Defines different pump control types
module PumpControl
  CONTINUOUS = 0
  INTERMITTENT = 1
end
