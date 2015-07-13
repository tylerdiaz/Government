DATA = {} if DATA is undefined

DATA['units'] =
  default:
    id: null
    name: ''
    title: 'villager'
    profession: 'drunk'
    img: 'units/drunkard.png'
    current_hp: 10
    max_hp: 10
    damage: [1, 5]
    accuracy: 0.5
    lvl: 1
    current_exp: 0
    max_exp: 50
    is_recovering: false
    on_duty: false
    duty_description: 'Off duty'
    population_space: 1
    morale_rate: 0
    states: {}
    costs: [
      resource_type: 'meal'
      resource_value: 20
      frequency: 'bunny'
      on_duty_contingency: false
    ]
    perks: []

