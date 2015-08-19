class GameClock
  morrows: 0
  rabbits: 0
  constructor: (@tick_count) ->
    @calculateTimes()
  tick: (offset=1) ->
    @tick_count = @tick_count + offset
    @calculateTimes()
  isNewRabbit: ->
    (@morrows % CONFIG.calendar.morrows_per_rabbit) == 0
  isNewMorrow: ->
    (@tick_count % Global.ticks_per_morrow == 0)
  calculateTimes: ->
    @morrows = Math.floor(@tick_count / Global.ticks_per_morrow)
    @rabbits = Math.floor(@morrows / CONFIG.calendar.morrows_per_rabbit)

# @clan in EventTick is read-only
class EventTick
  constructor: (@event, @clan) ->
    @dismissal_countdown() if @event.dismissed && @event.hidden is false
  dismissal_countdown: ->
    @event.dismissed_countdown = (@event.dismissed_countdown - 1)
    if @event.dismissed_countdown <= 0
      @event.hidden = true

class UnitTick
  constructor: (@unit) ->

class GameTick
  constructor: (@clan) ->
    @clock = new GameClock(@clan.state_data.tick_counter)
    @clock.tick()
    @clan.state_data.tick_counter = @clock.tick_count
    @clan.state_data.timestamp = @clock.morrows

    @resource_calc = new ResourceCalculator(@clan.resources)
    runtime_formulas = @clan.formulas

    if @clock.isNewRabbit()
      @clan.current_policies = @clan.proposed_policies

    if @clock.isNewMorrow()
      @clan.units = @tickUnits(@clan.units, @clock.isNewRabbit())

      for unit, unitIndex in @clan.units
        if unit.perks is undefined or unit.on_duty is false
          continue

        console.log 'perk target:', unit.duty_target_type, unit.name, unit.duty_target_id

        for perk, perkIndex in unit.perks
          target = @clan[unit.duty_target_type][unit.duty_target_id]
          perk_fn = @runPerk(unit, perk, target)
          if perk_fn.perk_target
            @clan[unit.duty_target_type][unit.duty_target_id] = perk_fn.perk_target

    # Time to progress event threads/handle event pool
    for @event, event_index in @clan.events
      @clan.events[event_index] = new EventTick(@event, @clan).event

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

    # run building perks here, which may add to formulas in real-time

    if @clock.isNewMorrow()
      @clan.morale = parseFloat(@clan.morale) + @unitMoraleOffset(@clan.units)
      @resource_calc.runFormulas(runtime_formulas)

    # update affected resources
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
        if (target.construction >= target.required_construction)
          unitIndex = @clan.units.indexOf(unit)
          @clan.units[unitIndex]['on_duty'] = false
          @clan.units[unitIndex]['duty_target_type'] = false
          @clan.units[unitIndex]['duty_target_id'] = false
          @clan.units[unitIndex]['duty_description'] = "Relaxing after finishing #{target.building_type}"
          # more short-circuit to prevent over-building
          return false;

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
