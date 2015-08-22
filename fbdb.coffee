#!/usr/bin/env node

Firebase = require('firebase')
firebaseRef = new Firebase("ws://local.firebaseio.com:5111")
_ = require('underscore')
argv = require('optimist').argv

merge = (xs...) ->
  if xs?.length > 0
    tap {}, (m) -> m[k] = v for k, v of x for x in xs
capitalizeFirstLetter = (string) ->
  string.charAt(0).toUpperCase() + string.slice(1)

tap = (o, fn) -> fn(o); o

medievalNames = ["Merek", "Carac", "Ulric", "Tybalt", "Borin", "Sadon", "Terrowin", "Rowan", "Forthwind", "Althalos", "Fendrel", "Brom", "Hadrian", "Benedict", "Gregory", "Peter", "Henry", "Frederick", "Walter", "Thomas", "Arthur", "Bryce", "Donald", "Leofrick", "Ronald", "Jarin", "Cassius", "Leo", "Cedric", "Gavin", "Peyton", "Josef", "Doran", "Asher", "Quinn", "Zane", "Xalvador", "Favian", "Destrian", "Dain", "Lord Falk", "Berinon", "Tristan", "Gorvenal"]

class Unit
  default_data:
    name: 'No one',
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
    on_duty: false,
    duty_target_type: '',
    duty_target_id: 0,
    duty_description: 'Off duty',
    states: {},
    population_space: 1,
    morale_rate: 0,
    costs: [
      { resource_type: 'meal', resource_value: 20, frequency: 'bunny', on_duty_contingency: false },
      {resource_type: 'glowstones', resource_value: 2, frequency: 'morrow', on_duty_contingency: true },
    ],
    perks: []

  constructor: (config_data) ->
    @default_data['img'] = "units/"+config_data['profession']+'.png'
    @default_data['title'] = capitalizeFirstLetter(config_data['profession'])
    @data = merge(@default_data, config_data)
    @data.id = Math.floor((Math.random() * 10000) + 1000)
    @data.name = medievalNames[Math.floor(Math.random()*medievalNames.length)]

class Clan
  default_data:
    clan_size: "village"
    morale: 60.0
    name: "Default"
    max_population: 5
    current_policies:
      wages: "1"
      overtime: false
      religion: false
      scoutingFocus: 'food'
    proposed_policies:
      wages: "1"
      overtime: false
      religion: false
      scoutingFocus: 'food'
    proposed_buildings: {}

  constructor: (config_data) ->
    @data = merge(@default_data, config_data)

randomPW = Math.random().toString(36).slice(-12)


medievalVillages = ["Glassmount", "Fairfield", "Stonecastle", "Redwyvern", "Wintercoast", "Highbarrow", "Wildefort", "Ironbridge", "Bluehill", "Foxland", "Whitedell", "Summerelf", "Woodview", "Rosewall", "Oakcliff", "Brightbourne"]

firebaseRef.createUser({
  email    : argv.email,
  password : randomPW,
}, (error, userData) ->
  if error
    console.log("Error creating user:", error, userData)
  else
    new_uID = userData.uid
    console.log("Successfully created user account with uid:", userData.uid)

    clan = new Clan({ name: medievalVillages[Math.floor(Math.random()*medievalVillages.length)]})
    firebaseRef.child("clans/#{new_uID}").set(clan.data)

    # First. Resources.
    firebaseRef.child("resources/#{new_uID}").set({
      glowstones: 20000,
      lumber: 500,
      meal: 1000,
      rice: 1000,
      beef: 500,
      fish: 1000,
    })

    # States.
    firebaseRef.child("state_data/#{new_uID}").set({user_active: true, tick_counter: 0, timestamp: 0})

    # The actual user data.
    firebaseRef.child("users/#{new_uID}").set({name: argv.name, addressment: "Lord"})

    # Presence data.
    firebaseRef.child("presence/#{new_uID}").set({name: argv.name, province: "#{clan.data.clan_size} #{clan.data.name}", presence: 'online'})

    firebaseRef.child("maps/#{new_uID}").set({stage: 3})
    firebaseRef.child("formulas/#{new_uID}").set([
      { name: 'Beef sandwhich', value: { meal: 1 }, cost: { bread: 1, beef: 1 }, greedy: true, enabled: true },
      { name: 'Rice with fish', value: { meal: 2 }, cost: { rice: 2, fish: 2 }, greedy: false, enabled: true },
      { name: 'Fish sandwhich', value: { meal: 1 }, cost: { bread: 1, fish: 1 }, greedy: true, enabled: true },
      { name: 'Rice with beef', value: { meal: 2 }, cost: { rice: 2, beef: 2 }, greedy: false, enabled: true },
      { name: 'Sophisticated meal', value: { sophisticated_meal: 1 }, cost: { wine: 1, cheese: 1, grapes: 1 }, greedy: true, enabled: true },

      { name: 'Beer', value: { beer: 1 }, cost: { hops: 1, yeast: 1 }, greedy: false, enabled: true },
      { name: 'Wine', value: { wine: 1 }, cost: { grapes: 5 }, greedy: false, enabled: true },
    ])

    firebaseRef.child("territories/#{new_uID}").set({
      'meadows': { exploration_progress: 0, resources: { lumber: 1000, rice: 50000 } },
      'swampland': { exploration_progress: 0, resources: { lumber: 500, rice: 2000 } },
    })

    firebaseRef.child("battles/#{new_uID}").set({
      'f2jq0fj291': {
        title: 'A fierce battle',
        logs: [],
      }
    })

    firebaseRef.child("events/#{new_uID}").set([
      {
        storyline_id: 'abcdefg',
        title: 'A boot in the shore',
        img: 'boot.png',
        category: 'event',
        timestamp: 3020,
        progression_countdown: 201,
        dismissed_countdown: 5,
        description: 'Some villagers are reporting a boot was found ashore.',
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
    ])

    firebaseRef.child("buildings/#{new_uID}").set([{
      building_type: false,
      construction: 1,
      required_construction: 1
    },
    {
      building_type: 'cabin',
      construction: 200,
      required_construction: 200,
    }])

    # UNITS
    scout = new Unit({
      profession: 'scout',
      perks: [
        {
          resource_type: 'exploration',
          resource_value: 1,
          frequency: 'morrow',
          on_duty_contingency: true,
        }
      ]
    })

    builder = new Unit({
      profession: 'builder',
      perks: [
        {
          resource_type: 'construction',
          resource_value: 10,
          frequency: 'morrow',
          on_duty_contingency: true,
        }]
     })

    lumberman = new Unit({
      profession: 'lumberman',
      perks: [{
        resource_type: 'lumber',
        resource_value: 1,
        frequency: 'morrow',
        on_duty_contingency: true,
      }]
    })

    spearman = new Unit({
      profession: 'spearman',
      perks: []
    })

    # The actual user data.
    firebaseRef.child("units/#{new_uID}").set([scout.data, spearman.data, lumberman.data, builder.data])

)
console.log "Username: #{argv.email}, Password: #{randomPW}"
