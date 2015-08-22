CONFIG =
  firebase_url: 'ws://local.firebaseio.com:5111'
  scouting_focus_options: ['food', 'weapons', 'looting']
  denormalized_tables: ['units', 'resources', 'state_data', 'formulas', 'events', 'battles', 'territories', 'buildings']
  building_descriptions:
    cabin: 'A place for x2 extra villagers to reside'
    'comedy-inn': 'Somewhere for villagers to unwind after work'
  resource_descriptions:
    # culinary ingredients
    meal: 'Meals are used to feed your population'
    sophisticated_meal: 'Sophisticated meals are used to feed your population and increase morale'
    beef: 'Second half a part of a well-rounded meal'
    fish: 'Second half a part of a well-rounded meal'
    rice: 'First half a part of a well-rounded meal. It\'s slow to work with.'
    bread: 'First half a part of a well-rounded meal'
    grapes: 'A sweet fruit that makes up part of a sophisticated meal'
    cheese: 'Cheese made from the milk of goats that makes up part of a sophisticated meal'
    hops: 'A bitter flower used to make beer'
    yeast: 'Versatile ingredient for making delicious things'
    beer: 'Alcholic beverage that increases morale. It takes some time to make.'
    wine: 'Alcholic beverage that makes up part of a sophisticated meal. It takes some time to make.'
    flour: 'Versatile ingredient for making things'

    # defense
    iron: 'Material used to create sturdy weapons and building features'
    spear: 'A frail weapon used for combat'

    # expansion
    lumber: 'Used to create wooden buildings'

    # economic
    glowstones: 'Main currency used'

  calendar:
    morrows_per_rabbit: 30
    morrows_per_lion: 119 # minus one offset
    morrows_per_elephant: 659 # minus one offset

  territories:
    'meadows':
      exploration_score: 625,
      description: 'land description',
      min_level: 1,
    ,
    'forest':
      exploration_score: 3125,
      description: 'land description',
      min_level: 2,
    ,
    'seaside':
      exploration_score: 15625,
      description: 'land description',
      min_level: 4,
    ,
    'swampland':
      exploration_score: 78125,
      description: 'land description',
      min_level: 8,
    ,
    'desert':
      exploration_score: 150000,
      description: 'land description',
      min_level: 10,
    ,
    'snowcap-peak':
      exploration_score: 500000,
      description: 'land description',
      min_level: 15,
    ,
  stages:
    1:
      overlay: ['map-frontyard-forest']
      underlay: ['map-start-greenland']
    2:
      overlay: []
      underlay: ['map-start-greenland']
    3:
      overlay: ['map-backyard-forest']
      underlay: ['map-greenland']
    4:
      overlay: []
      underlay: ['map-greenland']
    5:
      overlay: ['map-backyard-forest']
      underlay: ['map-greenland', 'map-desert']
    6:
      overlay: []
      underlay: ['map-greenland', 'map-desert']
    7:
      overlay: []
      underlay: ['map-water', 'map-greenland', 'map-desert']
  professions:
    scout:
      targets: ['discovered_territories']
      verb_module: 'explore'
      verb_description: 'Exploring {0}'
    lumberman:
      targets: ['discovered_territories']
      verb_module: 'harvest for lumber'
      verb_description: 'Harvesting {0} for lumber'
    builder:
      targets: ['unfinished_buildings']
      verb_module: 'build'
      verb_description: 'Building {0}'
    spearman:
      targets: ['self_player', 'self_units']
      verb_module: 'defend'
      verb_description: 'Defending {0}'
