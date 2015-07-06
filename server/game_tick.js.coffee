class GameTick
  constructor: (@clan_data) ->
    @resource_calc = new ResourceCalculator(@clan_data.resources)
    @clan_data.state_data.tick_counter = @clan_data.state_data.tick_counter + 1
    @clan_data.timestamp = @morrowTick(@clan_data.state_data.tick_counter, @clan_data.timestamp)

    if @isNewRabbit(@clan_data.timestamp)
      @clan_data.current_policies = @clan_data.proposed_policies

    if @isNewMorrow(@clan_data.state_data.tick_counter)
      @clan_data.units = @tickUnits(@clan_data.units, @isNewRabbit(@clan_data.timestamp))

    # run building stuff here, which may add to formulas in real-time

    if @isNewMorrow(@clan_data.state_data.tick_counter)
      @resource_calc.runFormulas(CONFIG.formulas)


    @clan_data.resources = @resource_calc.resources

  isNewRabbit: (timestamp) ->
    (timestamp % CONFIG.calendar.morrows_per_rabbit) == 0

  isNewMorrow: (tickCount) ->
    tickCount % Global.ticks_per_morrow == 0

  morrowTick: (tickCount, timestamp) ->
    if @isNewMorrow(tickCount)
      timestamp + 1
    else
      timestamp

  tickUnits: (units, isNewRabbit) ->
    for unit, unitIndex in units
      unit_tick = new UnitTick(unit, @clan_data.current_policies.wages, isNewRabbit)
      unit_costs = unit_tick.costs()

      if @resource_calc.canAfford(unit_costs)
        @resource_calc.deplete(unit_costs)
      else
        if unit_tick.isOnDuty()
          unit_tick.decommission()
        else
          unit_tick.starvationPenalty()

      units[unitIndex] = unit_tick.unit

    units

  calculateBuildingCosts: (buildings) ->
    console.log 'building'
