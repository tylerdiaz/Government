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
  costs: [
    {
      resource_type: 'meal',
      resource_value: 40,
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
  perks: [],
}

var firebaseData = {
  clans: {
    "simplelogin:1": {
      clan_size: "village",
      morale: 60,
      name: "Karolann",
      max_population: 5,
      timestamp: 0,
      state_data: {
        user_active: true,
        tick_counter: 0,
      },
      resources: {
        glowstones: 800,
        meal: 160,
        rice: 100,
        meat: 20,
      },
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
      },
      units: [
        _.extend(default_unit_json, {
          name: 'Jupiter',
          title: 'Resourceful',
          profession: 'scout',
          img: 'units/jupiter.png',
          perks: [
            {
              resource_type: 'scouting',
              resource_value: null,
              frequency: 'morrow',
              on_duty_contingency: true,
              target: 'player', // player,duty_assignment
              target_effect: 'event' // additive,event
            }
          ],
        })
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

