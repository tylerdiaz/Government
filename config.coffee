CONFIG =
  resource_descriptions:
    glowstones: 'Main currency used'
    meal: 'Meals are used to feed your population'
    sophisticated_meal: 'Sophisticated meals are used to feed your population and increase morale'
    meat: 'Second half a part of a well-rounded meal'
    rice: 'First half a part of a well-rounded meal'
    timber: 'Used to create wooden buildings'
    iron: 'Material used to create sturdy weapons and building features'
    hops: 'Bitter flower'
    yeast: 'Versatile ingredient for making delicious things'
    grapes: 'A sweet fruit that makes up part of a sophisticated meal'
    goat_cheese: 'Cheese made from the milk of goats that makes up part of a sophisticated meal'
    beer: 'Alcholic beverage that increases morale'
    wine: 'Alcholic beverage that makes up part of a sophisticated meal'
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
    ,
    value:
      beer: 1
    cost:
      hops: 1
      yeast: 1
    greedy: false
    ,
    value:
      sophisticated_meal: 1
    cost:
      wine: 1
      cheese: 1
      grapes: 1
    greedy: true
    ,
    value:
      wine: 1
    cost:
      grapes: 10
    greedy: false

  ]
