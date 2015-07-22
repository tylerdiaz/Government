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
          perk.proactive = (if unit.duty_target_type is 'player' then false else true) # invalid, also needs to include stuff like "defending"
          console.log perk.proactive, unit.duty_target_type
          if perk.proactive is true
            console.log @clan[unit.duty_target_type], unit.duty_target_type
            perk_target = @clan[unit.duty_target_type][unit.duty_target_id]
            duty_tick = new UnitDutyHandler(perk, perk_target, unit)
            @clan[unit.duty_target_type][unit.duty_target_id] = duty_tick.perk_target

    for clan_event, event_index in @clan.events
      if clan_event.dismissed
        @clan.events[event_index]['dismissed_countdown'] = @clan.events[event_index]['dismissed_countdown'] - 1
        if @clan.events[event_index]['dismissed_countdown'] <= 0
          @clan.events[event_index]['hidden'] = true

    # run building stuff here, which may add to formulas in real-time
    if @isNewMorrow(@clan.state_data.tick_counter)
      @clan.morale = (
        parseFloat(@clan.morale) + @unitMoraleOffset(@clan.units)
      )

      @resource_calc.runFormulas(runtime_formulas)

    @clan.resources = @resource_calc.resources

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

  calculateBuildingCosts: (buildings) ->
    console.log 'building'
