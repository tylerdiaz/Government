seedrandom = require('seedrandom')

class BattleGenerator
  battle: {} # this is what you'd want to export for firebase manipulation
  randomizer_fn: null
  constructor: (@defending_party, @offending_party, config = { seed: null }) ->
    @randomizer_fn = seedrandom(@config['seed'])
    # if offending party is just a string and not an
    # object, we assume mob generation is desired.
  create_event: ->
    console.log 'A battle has been created!'

class MobGenerator
  mob: {} # this is what you'd want to export for your battle
  constructor: (@mob_type, @level, @properties, @randomizer_fn) ->
    # @token = [seed generator] if @token is null
    # We need to do property merging here have more
    # granular control over what the result is.

  attribute_randomizer: ->
    # what can be done in here?
