var FirebaseServer = require('firebase-server');

var firebaseData = {
  clans: {
    "simplelogin:1": {
      clan_size: "village",
      morale: 70,
      name: "Karolann",
      population: 3,
      max_population: 5,
      timestamp: 0,
      state_data: {
        user_active: true,
        tick_counter: 0,
      },
      resources: [
        { resource: 'glowstones', amount: 2, description: 'what a description would go here......' },
        { resource: 'timber', amount: 25, description: 'what a description would go here......' },
        { resource: 'rice', amount: 90, description: 'what a description would go here......' },
        { resource: 'meat', amount: 100, description: 'what a description would go here......' },
        { resource: 'meal', amount: 20, description: 'something to feed people with...' },
      ],
      current_policies: {
        wages: "1.5",
        overtime: false,
        religion: true,
        researchFocus: 'combat'
      },
      proposed_policies: {
        wages: "1.5",
        overtime: false,
        religion: true,
        researchFocus: 'combat'
      },
      units: [
        {
          id: 103902,
          is_recovering: false,
          name: "Mark",
          title: "builder",
          profession: "builder",
          img: "/images/sprites/units/builder.png",
          current_hp: 10,
          max_hp: 10,
          lvl: 2,
          current_exp: 32,
          max_exp: 150,
          states: {},
          on_duty: true,
          duty_description: 'On Blacksmith#1',
          costs: [
            {
              resource_type: 'meal',
              resource_value: 60,
              frequency: 'bunny',
              on_duty_contingency: false,
            },
            {
              resource_type: 'glowstones',
              resource_value: 4,
              frequency: 'morrow',
              on_duty_contingency: true,
            },
          ],
          perks: [
            {
              resource_type: 'construction',
              resource_value: 3,
              frequency: 'morrow',
              on_duty_contingency: true,
              target: 'duty_assignment', // player,duty_assignment
              target_effect: 'additive'
            },
            {
              resource_type: 'attribute',
              resource_value: 3,
              frequency: 'morrow',
              on_duty_contingency: true,
              target: 'duty_assignment', // player,duty_assignment
              target_effect: 'additive'
            },
          ],
        },
      ],
    },
  },
  users: {
    "simplelogin:1": {
      name: "Tyler",
      addressment: "Lord"
    }
  }
};

new FirebaseServer(5111, 'local.firebaseio.com', firebaseData);

