var GameTick;

GameTick = (function() {
  function GameTick(clan_data) {
    this.clan_data = clan_data;
    this.clan_data.state_data.tick_counter = this.clan_data.state_data.tick_counter + 1;
    this.clan_data.timestamp = this.morrowTick(this.clan_data.state_data.tick_counter, this.clan_data.timestamp);
    if (this.isNewRabbit(this.clan_data.timestamp)) {
      this.clan_data.current_policies = this.clan_data.proposed_policies;
    }
    if (this.isNewMorrow(this.clan_data.state_data.tick_counter)) {
      this.tickUnits(this.isNewRabbit(this.clan_data.timestamp));
    }
  }

  GameTick.prototype.isNewRabbit = function(timestamp) {
    return (timestamp % Global.morrows_per_rabbit) === 0;
  };

  GameTick.prototype.isNewMorrow = function(tickCount) {
    return tickCount % Global.ticks_per_morrow === 0;
  };

  GameTick.prototype.morrowTick = function(tickCount, timestamp) {
    if (this.isNewMorrow(tickCount)) {
      return timestamp + 1;
    } else {
      return timestamp;
    }
  };

  GameTick.prototype.tickUnits = function(isNewRabbit) {
    var resource_calculator, unit, unitIndex, unit_costs, unit_tick, _i, _len, _ref;
    resource_calculator = new ResourceCalculator(this.clan_data.resources);
    _ref = this.clan_data.units;
    for (unitIndex = _i = 0, _len = _ref.length; _i < _len; unitIndex = ++_i) {
      unit = _ref[unitIndex];
      unit_tick = new UnitTick(unit, this.clan_data.current_policies.wages, isNewRabbit);
      unit_costs = unit_tick.costs();
      if (unit_costs) {
        if (resource_calculator.canAfford(unit_costs)) {
          resource_calculator.deplete(unit_costs);
        } else {
          if (unit_tick.isOnDuty()) {
            unit_tick.decommission();
          } else {
            unit_tick.starvationPenalty();
          }
        }
      }
      this.clan_data.units[unitIndex] = unit_tick.unit;
    }
    return this.clan_data.resources = resource_calculator.resources;
  };

  GameTick.prototype.calculateBuildingCosts = function(buildings) {
    return console.log('building');
  };

  return GameTick;

})();

var ResourceCalculator;

ResourceCalculator = (function() {
  function ResourceCalculator(resources) {
    this.resources = resources;
  }

  ResourceCalculator.prototype.canAfford = function(prices) {
    var cost, resource, resource_type, result;
    result = true;
    for (resource_type in prices) {
      cost = prices[resource_type];
      if (result === false) {
        break;
      }
      resource = _.findWhere(this.resources, {
        resource: resource_type
      });
      if (!(resource && resource.amount >= cost)) {
        result = false;
      }
    }
    return result;
  };

  ResourceCalculator.prototype.deplete = function(prices) {
    var key, r, _i, _len, _ref, _results;
    if (!this.canAfford(prices)) {
      return false;
    }
    _ref = this.resources;
    _results = [];
    for (key = _i = 0, _len = _ref.length; _i < _len; key = ++_i) {
      r = _ref[key];
      if (!prices[r.resource]) {
        continue;
      }
      _results.push(this.resources[key] = this.resources[key] - prices[r.resource]);
    }
    return _results;
  };

  return ResourceCalculator;

})();

var Firebase, GameState, Global, _;

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
      return Global.firebaseRef.child("clans/" + clanKey).set(new GameTick(snapshot.val()).clan_data);
    }));
  }
  return _results;
}, Global.tickRate);

var UnitTick;

UnitTick = (function() {
  function UnitTick(unit, wage_ratio, isNewRabbit) {
    this.unit = unit;
    this.wage_ratio = wage_ratio;
    this.isNewRabbit = isNewRabbit;
  }

  UnitTick.prototype.isOnDuty = function() {
    return this.unit.on_duty;
  };

  UnitTick.prototype.decommission = function() {
    return this.unit.on_duty = false;
  };

  UnitTick.prototype.starvationPenalty = function() {
    return this.unit.current_hp = this.unit.current_hp - 4;
  };

  UnitTick.prototype.costs = function() {
    var cost, total_unit_costs, _i, _len, _ref;
    total_unit_costs = {};
    _ref = this.unit['costs'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      cost = _ref[_i];
      if (cost.on_duty_contingency === true && this.unit.on_duty === false) {
        continue;
      }
      if (cost.frequency === 'bunny' && this.isNewRabbit === false) {
        continue;
      }
      total_unit_costs[cost.resource_type] = cost.resource_type === 'glowstones' ? parseInt(cost.resource_value * parseFloat(this.wage_ratio)) : cost.resource_value;
    }
    return total_unit_costs;
  };

  return UnitTick;

})();
