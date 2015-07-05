var Firebase, GameState, GameTicker, Global, _;

Firebase = require('firebase');

_ = require('underscore');

Global = {
  firebaseRef: new Firebase("ws://local.firebaseio.com:5111"),
  tickRate: 200,
  ticks_per_morrow: 10,
  morrows_per_rabbit: 30
};

GameState = {
  motherCycle: null,
  activeClans: []
};

Global.firebaseRef.child("clans").on("child_added", function(snapshot) {
  var clan_data;
  clan_data = snapshot.val();
  return GameState.activeClans.push(snapshot.key());
});

GameState.motherCycle = setInterval(function() {
  var clanKey, _i, _len, _ref, _results;
  _ref = GameState.activeClans;
  _results = [];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    clanKey = _ref[_i];
    _results.push(Global.firebaseRef.child("clans/" + clanKey).once("value", function(snapshot) {
      return Global.firebaseRef.child("clans/" + clanKey).set(new GameTicker(snapshot.val()).clan_data);
    }));
  }
  return _results;
}, Global.tickRate);

GameTicker = (function() {
  function GameTicker(clan_data) {
    this.clan_data = clan_data;
    this.clan_data.state_data.tick_counter = this.clan_data.state_data.tick_counter + 1;
    this.clan_data.timestamp = this.morrowTick(this.clan_data.state_data.tick_counter, this.clan_data.timestamp);
    if (this.isNewRabbit(this.clan_data.timestamp)) {
      this.clan_data.current_policies = this.clan_data.proposed_policies;
    }
    if (this.isNewMorrow(this.clan_data.state_data.tick_counter)) {
      this.tickUnitCosts(this.isNewRabbit(this.clan_data.timestamp));
    }
  }

  GameTicker.prototype.isNewRabbit = function(timestamp) {
    return (timestamp % Global.morrows_per_rabbit) === 0;
  };

  GameTicker.prototype.isNewMorrow = function(tickCount) {
    return tickCount % Global.ticks_per_morrow === 0;
  };

  GameTicker.prototype.morrowTick = function(tickCount, timestamp) {
    if (this.isNewMorrow(tickCount)) {
      return timestamp + 1;
    } else {
      return timestamp;
    }
  };

  GameTicker.prototype.tickUnitCosts = function(isNewRabbit) {
    var cost, resource, total_costs, total_unit_costs, unit, _i, _j, _len, _len1, _ref, _ref1;
    total_costs = {};
    _ref = this.clan_data.units;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      unit = _ref[_i];
      total_unit_costs = {};
      _ref1 = unit['costs'];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        cost = _ref1[_j];
        if (cost.on_duty_contingency === true && unit.on_duty === false) {
          continue;
        }
        if (cost.frequency === 'rabbit' && isNewRabbit === false) {
          continue;
        }
        resource = _.findWhere(this.clan_data.resources, {
          resource: cost.resource_type
        });
        if (resource && resource.amount >= cost.resource_amount) {
          total_unit_costs[cost.resource_type] = cost.resource_amount;
        } else {
          total_unit_costs = false;
          console.log('unit cannot be afforded');
        }
      }
      if (total_unit_costs) {
        total_costs = Object.keys(total_unit_costs).reduce(function(memo, key) {
          memo[key] = total_unit_costs[key] + (memo[key] || 0);
          return memo;
        }, total_costs);
      }
    }
    return console.log("Total costs are: " + JSON.stringify(total_costs));
  };

  GameTicker.prototype.calculateBuildingCosts = function(buildings) {
    return console.log('test');
  };

  return GameTicker;

})();
