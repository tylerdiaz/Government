class UnitDutyHandler
  constructor: (@perk, @perk_target, @self_unit) ->
    if @perk.resource_type is 'exploration'
      @perk_target['exploration_progress'] = (
        @perk_target['exploration_progress'] +
        @perk.resource_value
      )
