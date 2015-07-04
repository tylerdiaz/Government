var FirebaseServer = require('firebase-server');

var firebaseData = {
  clans: {
    "simplelogin:1": {
      clan_size: "village",
      morale: 70,
      name: "Karolann",
      population: 3,
      max_population: 5,
      timestamp: 31,
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
    }
  },
  resources: {
    "simplelogin:1": [
      { resource: 'glowstones', amount: 1200, description: 'what a description would go here......' },
      { resource: 'timber', amount: 25, description: 'what a description would go here......' },
      { resource: 'rice', amount: 90, description: 'what a description would go here......' },
      { resource: 'meat', amount: 100, description: 'what a description would go here......' },
    ]
  },
  units: {
    "simplelogin:1": [
      {
        id: 103901,
        name: "Walter",
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
            resource_amount: 2,
            frequency: 'morrow',
            on_duty_contingency: false,
          },
          {
            resource_type: 'glowstones',
            resource_amount: 4,
            frequency: 'morrow',
            on_duty_contingency: true,
          },
        ],
        perks: [
          {
            resource_type: 'construction',
            resource_amount: 3,
            frequency: 'moon',
            on_duty_contingency: true,
          },
        ],
      },
    ]
  },
  users: {
    "simplelogin:1": {
      name: "Tyler",
      addressment: "Lord"
    }
  }
};

new FirebaseServer(5111, 'local.firebaseio.com', firebaseData);

