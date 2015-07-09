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
      exp: (Math.round(@power_rule(@profession.start.exp, @profession.end.exp, lvl) / 5) * 5),
      damage: [
        @power_rule(@profession.start.damage[0], @profession.end.damage[0], lvl)
        @power_rule(@profession.start.damage[1], @profession.end.damage[1], lvl)
      ],
      accuracy: @power_rule(@profession.start.accuracy, @profession.end.accuracy, lvl, false).toFixed(2),
      max_hp: @power_rule(@profession.start.max_hp, @profession.end.max_hp, lvl),
    }

  stats: (lvl=1) ->
    @smoothing(lvl, @profession)
