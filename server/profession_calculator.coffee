class ProfessionCalculator
  max_level: 20
  constructor: (@profession) ->
  power_rule: (min, max, offset, round=true) ->
    B = Math.log(max / min) / (@max_level - 1)
    A = min / (Math.exp(B) - 1)
    if round
      Math.round(A * Math.exp(B * offset)) - Math.round(A * Math.exp(B * (offset - 1)))
    else
      A * Math.exp(B * offset) - A * Math.exp(B * (offset - 1))

  smoothing: (lvl, profession) ->
    {
      exp: (Math.round(@power_rule(@profession.starting_stats.exp, @profession.final_stats.exp, lvl) / 5) * 5),
      damage: [
        @power_rule(@profession.starting_stats.damage[0], @profession.final_stats.damage[0], lvl)
        @power_rule(@profession.starting_stats.damage[1], @profession.final_stats.damage[1], lvl)
      ],
      accuracy: @power_rule(@profession.starting_stats.accuracy, @profession.final_stats.accuracy, lvl, false).toFixed(2),
      max_hp: @power_rule(@profession.starting_stats.max_hp, @profession.final_stats.max_hp, lvl),
    }

  stats: (lvl=1) ->
    @smoothing(lvl, @profession)
