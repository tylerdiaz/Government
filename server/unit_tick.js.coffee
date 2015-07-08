class UnitTick
  constructor: (@unit, @wage_ratio, @isNewRabbit) ->
  isOnDuty: ->
    @unit.on_duty
  decommission: ->
    @unit.on_duty = false
  starvationPenalty: ->
    @unit.current_hp = (@unit.current_hp - 4)
  isDead: ->
    @unit.current_hp <= 0
  costs: ->
    total_unit_costs = {}
    for cost in @unit['costs']
      continue if cost.on_duty_contingency is true && @unit.on_duty is false
      continue if cost.frequency is 'bunny' && @isNewRabbit is false

      total_unit_costs[cost.resource_type] =
        if cost.resource_type == 'glowstones'
          parseInt(cost.resource_value * parseFloat(@wage_ratio))
        else
          cost.resource_value

    total_unit_costs
