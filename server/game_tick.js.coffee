class GameTick
  constructor: (@clan_data) ->
    @clan_data.state_data.tick_counter = @clan_data.state_data.tick_counter + 1
    @clan_data.timestamp = @morrowTick(@clan_data.state_data.tick_counter, @clan_data.timestamp)

    if @isNewRabbit(@clan_data.timestamp)
      @clan_data.current_policies = @clan_data.proposed_policies

    if @isNewMorrow(@clan_data.state_data.tick_counter)
      @tickUnits(@isNewRabbit(@clan_data.timestamp))

  isNewRabbit: (timestamp) ->
    (timestamp % Global.morrows_per_rabbit) == 0

  isNewMorrow: (tickCount) ->
    tickCount % Global.ticks_per_morrow == 0

  morrowTick: (tickCount, timestamp) ->
    if @isNewMorrow(tickCount)
      timestamp + 1
    else
      timestamp

  tickUnits: (isNewRabbit) ->
    resource_calculator = new ResourceCalculator(@clan_data.resources)

    for unit, unitIndex in @clan_data.units
      unit_tick = new UnitTick(unit, @clan_data.current_policies.wages, isNewRabbit)
      unit_costs = unit_tick.costs()

      if resource_calculator.canAfford(unit_costs)
        resource_calculator.deplete(unit_costs)
      else
        if unit_tick.isOnDuty()
          unit_tick.decommission()
        else
          unit_tick.starvationPenalty()

      @clan_data.units[unitIndex] = unit_tick.unit

    @clan_data.resources = resource_calculator.resources

  calculateBuildingCosts: (buildings) ->
    console.log 'building'
