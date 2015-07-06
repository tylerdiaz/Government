var FirebaseServer = require('firebase-server');

function unit_json(name, profession){
  return {
    id: Math.floor((Math.random() * 10000) + 1000),
    name: name,
    title: profession,
    profession: "builder",
    img: profession+".png",
    current_hp: 10,
    max_hp: 10,
    is_recovering: false,
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
      }
    ],
  }
}

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
      resources: {
        glowstones: 2000,
        timber: 25,
        rice: 90,
        meat: 100,
        meal: 200,
      },
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
        unit_json("Mark", "builder"),
        unit_json("Max", "villager"),
        unit_json("Jupiter", "jupiter"),
        unit_json("Com", "drunkard"),
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

