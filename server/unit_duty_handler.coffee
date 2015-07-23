class UnitDutyHandler
  perk_mechanics: {},
  constructor: (@perk, @perk_target, @self_unit) ->
    @perk_mechanics = DATA['perk_mechanics'][@perk.resource_type]
    @run()

  run: ->
    switch (@perk_mechanics['perk_type'])
      when 'territories_exploration'
        @target_attribute_increment('exploration_progress', @perk.resource_value)
      when 'territories_harvest'
        # this is a bit of a different case because it extracts from a finite resource
        # I need to figure out the syntax for something like 'resources.lumber'
        @target_attribute_increment('exploration_progress', @perk.resource_value)

  target_attribute_increment: (key, amount) ->
    @perk_target[key] = (@perk_target[key] + amount)
