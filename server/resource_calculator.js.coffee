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
