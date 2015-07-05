Firebase = require('firebase')
_ = require('underscore')

Global =
  firebaseRef: new Firebase("ws://local.firebaseio.com:5111")
  tickRate: 200
  ticks_per_morrow: 10
  morrows_per_rabbit: 30

GameState =
  motherCycle: null
  activeClans: []

Global.firebaseRef.child("clans").on("child_added", (snapshot) ->
  clan_data = snapshot.val()
  GameState.activeClans.push(snapshot.key())
)

GameState.motherCycle = setInterval( ->
  for clanKey in GameState.activeClans
    Global.firebaseRef.child("clans/#{clanKey}").once("value", (snapshot) ->
      Global.firebaseRef.child("clans/#{clanKey}")
                        .set(new GameTicker(snapshot.val()).clan_data)
    )
, Global.tickRate)


# ============= MEAT & POTATOES ===============

class GameTicker
  constructor: (@clan_data) ->
    @clan_data.state_data.tick_counter = @clan_data.state_data.tick_counter + 1
    @clan_data.timestamp = @morrowTick(@clan_data.state_data.tick_counter, @clan_data.timestamp)

    if @isNewRabbit(@clan_data.timestamp)
      @clan_data.current_policies = @clan_data.proposed_policies

    if @isNewMorrow(@clan_data.state_data.tick_counter)
      @tickUnits(@isNewRabbit(@clan_data.timestamp))
      @tickUnitProduction(@isNewRabbit(@clan_data.timestamp))

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
    total_costs = {}
    resource_calculator = new ResourceCalculator(@clan_data.resources)

    for unit, unitIndex in @clan_data.units
      unitTick = new UnitTick(unit, @clan_data.current_policies.wages, isNewRabbit)
      total_unit_costs = unitTick.costs()

      if total_unit_costs
        if resource_calculator.canAfford(total_unit_costs)
          resource_calculator.deplete(total_unit_costs)
        else
          if unitTick.isOnDuty()
            unitTick.decommission()
          else
            unitTick.starvationPenalty()

      @clan_data.units[unitIndex] = unitTick.unit
      @clan_data.resources = resource_calculator.resources

  calculateBuildingCosts: (buildings) ->
    console.log 'building'

  tickUnitProduction: (isNewRabbit) ->
    console.log 'tickunit'

class ResourceCalculator
  constructor: (@resources) ->
  canAfford: (prices) ->
    result = true
    for resource_type, cost of prices
      break if result is false
      resource = _.findWhere(@resources, { resource: resource_type })
      result = false unless resource && resource.amount >= cost

    result

  deplete: (prices) ->
    return false unless @canAfford(prices)
    # this resource data structure makes things like this
    # super inefficient. Probably needs refactoring.
    for r, key in @resources
      continue unless prices[r.resource]
      @resources[key] = (@resources[key] - prices[r.resource])

class UnitTick
  constructor: (@unit, @wage_ratio, @isNewRabbit) ->
  isOnDuty: ->
    @unit.on_duty
  decommission: ->
    @unit.on_duty = false
  starvationPenalty: ->
    @unit.current_hp = (@unit.current_hp - 4)
  costs: ->
    total_unit_costs = {}
    for cost in @unit['costs']
      continue if cost.on_duty_contingency is true && @unit.on_duty is false
      continue if cost.frequency is 'rabbit' && @isNewRabbit is false

      total_unit_costs[cost.resource_type] =
        if cost.resource_type == 'glowstones'
          parseInt(cost.resource_amount * parseFloat(@wage_ratio))
        else
          cost.resource_amount

    total_unit_costs
