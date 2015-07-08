var FirebaseServer = require('firebase-server');
var _ = require('underscore');

var default_unit_json = {
  id: Math.floor((Math.random() * 10000) + 1000),
  name: 'No one',
  title: 'villager',
  profession: 'drunk',
  img: 'units/drunkard.png',
  current_hp: 12,
  max_hp: 12,
  is_recovering: false,
  lvl: 1,
  current_exp: 0,
  max_exp: 50,
  on_duty: false,
  states: {},
  duty_description: 'Off duty',
  population_space: 1,
  morale_rate: 0,
  costs: [
    {
      resource_type: 'meal',
      resource_value: 20,
      frequency: 'bunny',
      on_duty_contingency: false,
    },
    {
      resource_type: 'glowstones',
      resource_value: 2,
      frequency: 'morrow',
      on_duty_contingency: true,
    },
  ],
  perks: [
    {
      resource_type: 'glowstones',
      resource_value: 2,
      frequency: 'morrow',
      on_duty_contingency: true,
    },
  ],
}

function merge_options(obj1,obj2){
    var obj3 = {};
    for (var attrname in obj1) { obj3[attrname] = obj1[attrname]; }
    for (var attrname in obj2) { obj3[attrname] = obj2[attrname]; }
    return obj3;
}

var firebaseData = {
  clans: {
    "simplelogin:1": {
      clan_size: "village",
      morale: 60.0,
      name: "Karolann",
      max_population: 5,
      current_policies: { wages: "1", overtime: false, religion: false, scoutingFocus: 'food' },
      proposed_policies: { wages: "1", overtime: false, religion: false, scoutingFocus: 'food' },
    },
  },
  users: {
    "simplelogin:1": { name: "Tyler", addressment: "Lord" }
  },
  state_data: {
    "simplelogin:1": { user_active: true, tick_counter: 0, timestamp: 0 },
  },
  resources: {
    "simplelogin:1": { glowstones: 600, meal: 120, rice: 10000, beef: 20000, fish: 20000 }
  },
  units: {
    "simplelogin:1": [
      merge_options(default_unit_json, { name: 'Jupiter', title: 'Resourceful', profession: 'scout', img: 'units/jupiter.png' }),
      merge_options(default_unit_json, { name: 'Mendel', title: 'Builder', profession: 'builder', img: 'units/builder.png' }),
      merge_options(default_unit_json, { name: 'Tybalt', title: 'Spearman', profession: 'spearman', img: 'units/spearman.png' }),
      merge_options(default_unit_json, { name: 'Quentin', title: 'Lumberman', profession: 'lumberman', img: 'units/villager.png' }),
    ]
  },
  buildings: {
    "simplelogin:1": {
      1: 'building data structure here',
      2: 'locked',
      3: 'locked',
      4: 'locked',
      5: 'locked',
      6: 'locked',
      7: 'locked',
    }
  },
  maps: {
    "simplelogin:1": {
      stage: 1
    }
  },
  formulas: {
    "simplelogin:1": [
      // meals
      { value: { meal: 1 }, cost: { bread: 1, beef: 1 }, greedy: true, enabled: true },
      { value: { meal: 2 }, cost: { rice: 2, fish: 2 }, greedy: false, enabled: true },
      { value: { meal: 1 }, cost: { bread: 1, fish: 1 }, greedy: true, enabled: true },
      { value: { meal: 2 }, cost: { rice: 2, beef: 2 }, greedy: false, enabled: true },
      { value: { sophisticated_meal: 1 }, cost: { wine: 1, cheese: 1, grapes: 1 }, greedy: true, enabled: true },

      // drinks
      { value: { beer: 1 }, cost: { hops: 1, yeast: 1 }, greedy: false, enabled: true },
      { value: { wine: 1 }, cost: { grapes: 5 }, greedy: false, enabled: true },
    ]
  },
};

new FirebaseServer(5111, 'local.firebaseio.com', firebaseData);
