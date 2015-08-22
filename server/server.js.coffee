Firebase = require('firebase')
_ = require('underscore')

Global =
  firebaseRef: new Firebase(CONFIG.firebase_url)
  tickRate: 1000
  ticks_per_morrow: 2

GameState =
  mainCycle: null
  activeClans: []
  clanDataStructureKeys: []

joinPaths = (id, paths, fn) ->
  returnCount = 0
  expectedCount = paths.length
  mergedObject = {}

  paths.forEach (p) ->
    Global.firebaseRef.child(p + '/' + id).once 'value', (snap) ->
      if p in CONFIG.denormalized_tables
        mergedObject[p] = snap.val()
      else
        _.extend(mergedObject, snap.val()) # root table

      fn(null, mergedObject) if (++returnCount is expectedCount)
    ,
      (error) ->
        returnCount = expectedCount + 1 # abort counters
        fn(error, null)

Global.firebaseRef.child("clans").on "child_added", (snapshot) ->
  GameState.clanDataStructureKeys = Object.keys(snapshot.val())
  GameState.activeClans.push snapshot.key()

GameState.mainCycle = setInterval( ->
  for clanKey in GameState.activeClans
    joinPaths clanKey, CONFIG.denormalized_tables.concat(['clans']), (err, combined_value) ->
      frozen_start_value = JSON.parse(JSON.stringify(combined_value))
      game_tick = new GameTick(combined_value)

      # What's with all this weirdness? It's a hack for
      # re-constructing a denormalized data structure
      # to keep things convinient for development.
      actuated_clan_data = {}
      actuated_clan_data[k] = game_tick.clan[k] for k in GameState.clanDataStructureKeys
      Global.firebaseRef.child("clans/#{clanKey}").set(actuated_clan_data)

      # branches
      for key in CONFIG.denormalized_tables
        unless _.isEqual(frozen_start_value[key], game_tick.clan[key])
          Global.firebaseRef.child("#{key}/#{clanKey}").set(game_tick.clan[key])

, Global.tickRate)
