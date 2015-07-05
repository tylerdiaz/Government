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
      @tickUnitCosts(@isNewRabbit(@clan_data.timestamp))

  isNewRabbit: (timestamp) ->
    (timestamp % Global.morrows_per_rabbit) == 0

  isNewMorrow: (tickCount) ->
    tickCount % Global.ticks_per_morrow == 0

  morrowTick: (tickCount, timestamp) ->
    if @isNewMorrow(tickCount)
      timestamp + 1
    else
      timestamp

  tickUnitCosts: (isNewRabbit) ->
    total_costs = {}

    for unit in @clan_data.units
      total_unit_costs = {}
      for cost in unit['costs']
        continue if cost.on_duty_contingency is true && unit.on_duty is false
        continue if cost.frequency is 'rabbit' && isNewRabbit is false

        resource = _.findWhere(@clan_data.resources, { resource: cost.resource_type })
        if resource && resource.amount >= cost.resource_amount
          total_unit_costs[cost.resource_type] = cost.resource_amount
          # ...
        else
          total_unit_costs = false
          # if you can't afford to pay the unit, make them unemployed
          # if you can't afford to feed them, start a decay counter to run away/starvation
          console.log 'unit cannot be afforded'

      if total_unit_costs
        total_costs = Object.keys(total_unit_costs).reduce((memo, key) ->
          memo[key] = total_unit_costs[key] + (memo[key] || 0)
          memo
        , total_costs)

    console.log "Total costs are: "+JSON.stringify(total_costs)

        # {
        #   resource_type: 'meal',
        #   resource_amount: 2,
        #   frequency: 'morrow',
        #   on_duty_contingency: false,
        # },

  calculateBuildingCosts: (buildings) ->
    console.log 'test'
