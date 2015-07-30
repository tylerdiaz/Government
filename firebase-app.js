var FirebaseServer = require('firebase-server');
var _ = require('underscore');

var default_unit_json = {
  id: Math.floor((Math.random() * 10000) + 1000),
  name: 'No one', // writable
  title: 'villager',
  profession: 'drunk',
  img: 'units/drunkard.png',
  current_hp: 12,
  max_hp: 12,
  damage: [2, 4],
  accuracy: 0.5,
  is_recovering: false,
  lvl: 1,
  current_exp: 0,
  max_exp: 50,
  on_duty: false, // writable
  duty_target_type: '', // writable
  duty_target_id: 0, // writable
  duty_description: 'Off duty', // writable
  states: {},
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
  perks: []
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
      name: "Karolann", // writable
      max_population: 5,
      current_policies: {
        wages: "1",
        overtime: false,
        religion: false,
        scoutingFocus: 'food'
      },
      proposed_policies: {
        wages: "1",
        overtime: false,
        religion: false,
        scoutingFocus: 'food'
      }, // writable
    },
  },
  users: {
    "simplelogin:1": {
      name: "Tyler",
      addressment: "Lord"
    }
  },
  state_data: {
    "simplelogin:1": {
      user_active: true,
      tick_counter: 0,
      timestamp: 0
    },
  },
  resources: {
    "simplelogin:1": {
      glowstones: 640,
      lumber: 25,
      meal: 300,
      rice: 500,
      beef: 400
    }
  },
  units: {
    "simplelogin:1": [
      merge_options(
        default_unit_json, {
          id: Math.floor((Math.random() * 10000) + 1000),
          name: 'Jupiter',
          title: 'Resourceful',
          profession: 'scout',
          img: 'units/jupiter.png',
          perks: [
            {
              resource_type: 'exploration',
              resource_value: 1,
              frequency: 'morrow',
              on_duty_contingency: true,
            }
          ]
        }
      ),
      merge_options(
        default_unit_json, {
          id: Math.floor((Math.random() * 10000) + 1000),
          name: 'Mendel',
          title: 'Builder',
          profession: 'builder',
          img: 'units/builder.png'
        }
      ),
      merge_options(
        default_unit_json, {
          id: Math.floor((Math.random() * 10000) + 1000),
          name: 'Tybalt',
          title: 'Spearman',
          profession: 'spearman',
          img: 'units/spearman.png'
        }
      ),
      merge_options(
        default_unit_json, {
          id: Math.floor((Math.random() * 10000) + 1000),
          name: 'Quentive',
          title: 'Lumberman',
          profession: 'lumberman',
          img: 'units/lumberman.png',
          perks: [
            {
              resource_type: 'lumber',
              resource_value: 1,
              frequency: 'morrow',
              on_duty_contingency: true,
            }
          ]
        }
      )
    ]
  },
  buildings: {
    "simplelogin:1": {
      1: {
        building_type: 'cabin',
        heath: 100,
        construction: 100
      },
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
  events: {
    "simplelogin:1": [
      {
        storyline_id: 'abcdefg',
        title: 'This is strange',
        img: 'boot.png',
        category: 'event',
        timestamp: 3020,
        progression_countdown: 201,
        dismissed_countdown: 5,
        description: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Alias facere dolorem molestiae repellendus.',
        dismissed: false,
        hidden: false,
      },
      {
        storyline_id: 'f2jq0fj291',
        title: 'Jupiter is in combat!',
        img: 'sprites/3x/wildlife/bear.png',
        category: 'battle',
        timestamp: 3020,
        dismissed_countdown: 5,
        progression_countdown: 201,
        description: 'Jupiter was ambushed by a wild bear.',
        dismissed: false,
        hidden: false,
      },
    ]
  },
  battles: {
    "simplelogin:1": {
      'f2jq0fj291': {
        title: 'A fierce battle',
        logs: [],
      }
    }
  },
  territories: {
    "simplelogin:1": {
      'meadows': { exploration_progress: 0, resources: { lumber: 1000, rice: 50000 } },
      'swampland': { exploration_progress: 0, resources: { lumber: 500, rice: 2000 } },
    }
  },
  formulas: {
    "simplelogin:1": [
      // meals
      { name: 'Beef sandwhich', value: { meal: 1 }, cost: { bread: 1, beef: 1 }, greedy: true, enabled: true },
      { name: 'Rice with fish', value: { meal: 2 }, cost: { rice: 2, fish: 2 }, greedy: false, enabled: true },
      { name: 'Fish sandwhich', value: { meal: 1 }, cost: { bread: 1, fish: 1 }, greedy: true, enabled: true },
      { name: 'Rice with beef', value: { meal: 2 }, cost: { rice: 2, beef: 2 }, greedy: false, enabled: true },
      { name: 'Sophisticated meal', value: { sophisticated_meal: 1 }, cost: { wine: 1, cheese: 1, grapes: 1 }, greedy: true, enabled: true },

      // drinks
      { name: 'Beer', value: { beer: 1 }, cost: { hops: 1, yeast: 1 }, greedy: false, enabled: true },
      { name: 'Wine', value: { wine: 1 }, cost: { grapes: 5 }, greedy: false, enabled: true },
    ]
  },
};

new FirebaseServer(5111, 'local.firebaseio.com', firebaseData);
