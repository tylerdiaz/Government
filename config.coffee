CONFIG =
  resource_descriptions:
    glowstones: 'Main currency used'
    meal: 'Meals are used to feed your population'
    meat: 'Second half a part of a well-rounded meal'
    rice: 'First half a part of a well-rounded meal'
    timber: 'Used to create wooden buildings'
    iron: 'Material used to create weapons and building features'
  calendar:
    morrows_per_rabbit: 30
    morrows_per_lion: 119 # minus one offset
    morrows_per_elephant: 659 # minus one offset
  formulas: [
    value:
      meal: 1
    cost:
      rice: 1
      meat: 1
    greedy: true
  ]
