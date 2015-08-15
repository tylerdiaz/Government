class GameTick
  constructor: (@clan) ->
    @resource_calc = new ResourceCalculator(@clan.resources)
    @clan.state_data.tick_counter = @clan.state_data.tick_counter + 1
    @clan.state_data.timestamp = @morrowTick(@clan.state_data.tick_counter, @clan.state_data.timestamp)
    runtime_formulas = @clan.formulas

    if @isNewRabbit(@clan.state_data.timestamp)
      @clan.current_policies = @clan.proposed_policies

    if @isNewMorrow(@clan.state_data.tick_counter)
      @clan.units = @tickUnits(@clan.units, @isNewRabbit(@clan.state_data.timestamp))

      # Loop through the units' perks and assigned
      # targets, and see if there's anything that can
      # be done to exercise the duty they're assigned.
      # Some duties are reactive, others are proactive.

      for unit, unitIndex in @clan.units
        if unit.perks is undefined or unit.on_duty is false # grr... firebase...
          continue

        for perk, perkIndex in unit.perks
          perk_fn = @runPerk(
            unit,
            perk,
            @clan[unit.duty_target_type][unit.duty_target_id]
          )

          if perk_fn.perk_target
            @clan[unit.duty_target_type][unit.duty_target_id] = perk_fn.perk_target

    for clan_event, event_index in @clan.events
      if clan_event.dismissed
        @clan.events[event_index]['dismissed_countdown'] = @clan.events[event_index]['dismissed_countdown'] - 1
        if @clan.events[event_index]['dismissed_countdown'] <= 0
          @clan.events[event_index]['hidden'] = true

    # Convert proposed buildings into actual buildings (we can re-use this to dismantle)
    for index, building_type of @clan.proposed_buildings
      if building_type != 'null'
        @clan.buildings[index] = {
          building_type: building_type,
          construction: 0,
          required_construction: DATA['buildings'][building_type]['required_construction']
        }
      else
        @clan.buildings[index] = { building_type: false, construction: 1, required_construction: 1 }

    @clan.proposed_buildings = {}

    # run building stuff here, which may add to formulas in real-time
    if @isNewMorrow(@clan.state_data.tick_counter)
      @clan.morale = (
        parseFloat(@clan.morale) + @unitMoraleOffset(@clan.units)
      )

      @resource_calc.runFormulas(runtime_formulas)

    @clan.resources = @resource_calc.resources

  runPerk: (unit, perk, target) ->
    mechanics = DATA['perk_mechanics'][perk.resource_type]
    if mechanics.proactive is true
      if mechanics['perk_type'] is 'territory_harvest'
        @clan.resources[perk.resource_type] =
          @runPerk(unit, {
            resource_type: 'resource_modify',
            resource_value: perk.resource_value
          }, (@clan.resources[perk.resource_type] || 0)).perk_target
      else if mechanics['perk_type'] is 'building_construction'
        total_costs = @calculateBuildingCosts(target, perk.resource_value)
        can_afford_building_construction = true
        for resource, cost of total_costs
          if (total_costs[resource] && total_costs[resource] <= @clan.resources[resource])
            @clan.resources[resource] =
              @runPerk(unit, {
                resource_type: 'resource_modify',
                resource_value: -cost
              }, @clan.resources[resource]).perk_target
          else
            can_afford_building_construction = false

        # short circuiting here doesn't seem like the best solution, will
        # consider alternative architecture later.
        return false unless can_afford_building_construction

      new UnitDutyHandler(perk, target, unit)

  isNewRabbit: (timestamp) ->
    (timestamp % CONFIG.calendar.morrows_per_rabbit) == 0

  isNewMorrow: (tickCount) ->
    tickCount % Global.ticks_per_morrow == 0

  morrowTick: (tickCount, timestamp) ->
    if @isNewMorrow(tickCount)
      timestamp + 1
    else
      timestamp

  unitMoraleOffset: (units) ->
    parseFloat(
      Object.keys(units).reduce((memo, key) =>
        memo + units[key].morale_rate
      , 0)
    )

  tickUnits: (units, isNewRabbit) ->
    return [] if units is null # no units

    for unit, unitIndex in units
      continue if unit is undefined

      unit_tick = new UnitTick(unit, @clan.current_policies.wages, isNewRabbit)
      unit_costs = unit_tick.costs()

      if @resource_calc.canAfford(unit_costs)
        @resource_calc.deplete(unit_costs)
      else
        if unit_tick.isOnDuty()
          unit_tick.decommission()
        else
          unit_tick.starvationPenalty()

      if unit_tick.isDead()
        units.splice(unitIndex, 1)
      else
        units[unitIndex] = unit_tick.unit

    units

  calculateBuildingCosts: (building, construction_progress) ->
    max_costs = DATA['buildings'][building.building_type]['costs']
    costs = {}
    for resource, cost of max_costs
      costs[resource] =
        (construction_progress / building.required_construction) * cost

    costs
