Firebase = require('firebase')
_ = require('underscore')

Global =
  firebaseRef: new Firebase("ws://local.firebaseio.com:5111")
  tickRate: 1000
  ticks_per_morrow: 2

GameState =
  mainCycle: null
  activeClans: []

Global.firebaseRef.child("clans").on "child_added", (snapshot) ->
  clan_data = snapshot.val()
  GameState.activeClans.push snapshot.key()

GameState.mainCycle = setInterval( ->
  for clanKey in GameState.activeClans
    Global.firebaseRef.child("clans/#{clanKey}").once("value", (snapshot) ->
      Global.firebaseRef.child("clans/#{clanKey}").set(new GameTick(snapshot.val()).clan_data)
    )
, Global.tickRate)
