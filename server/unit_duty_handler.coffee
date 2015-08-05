class UnitDutyHandler
  mechanics: null,
  errors: [],
  constructor: (@perk, @perk_target, @self_unit) ->
    @mechanics = DATA['perk_mechanics'][@perk.resource_type]
    @run()
  run: ->
    switch (@mechanics['perk_type'])
      when 'territories_exploration'
        @perk_target['exploration_progress'] = (
          @perk_target['exploration_progress'] + @perk.resource_value
        )
      when 'building_construction'
        @perk_target['construction'] = (
          @perk_target['construction'] + @perk.resource_value
        )
      when 'resource_modify'
        @perk_target = (@perk_target + @perk.resource_value)
      when 'territories_harvest'
        if @perk_target.resources[@perk.resource_type] < @perk.resource_value
          @errors.push('Not enough resources left.')
        else
          @perk_target.resources[@perk.resource_type] = (
            @perk_target.resources[@perk.resource_type] -
            @perk.resource_value
          )
