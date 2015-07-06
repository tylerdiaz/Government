class ResourceCalculator
  constructor: (@resources) ->
  formulas: [
    {
      resource: 'meal',
      value: 1,
      cost: { rice: 1, meat: 1 },
      greedy: true
    },
  ]
  canAfford: (prices) ->
    result = true
    for resource_key, cost of prices
      break if result is false
      result = false unless resource[resource_key] && resource[resource_key] >= cost

    result

  deplete: (prices) ->
    return true if Object.keys(prices).length is 0
    return false unless @canAfford(prices)

    for resource_key, cost of prices
      @resources[resource_key] = @resources[resource_key] - cost

  grant: (grants) ->
    return true if Object.keys(grants).length is 0

    for resource_key, cost of grants
      @resources[resource_key] = (@resources[resource_key] || 0) + cost

  runCombinations: ->
    # for formula in @formulas
      # if @canAfford(formula['cost']) && formula['greedy']
        # while @canAfford(formula['cost'])
        #   @deplete(formula['cost'])

