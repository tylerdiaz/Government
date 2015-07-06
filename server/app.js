var GameTick;

GameTick = (function() {
  function GameTick(clan_data) {
    this.clan_data = clan_data;
    this.resource_calc = new ResourceCalculator(this.clan_data.resources);
    this.clan_data.state_data.tick_counter = this.clan_data.state_data.tick_counter + 1;
    this.clan_data.timestamp = this.morrowTick(this.clan_data.state_data.tick_counter, this.clan_data.timestamp);
    if (this.isNewRabbit(this.clan_data.timestamp)) {
      this.clan_data.current_policies = this.clan_data.proposed_policies;
    }
    if (this.isNewMorrow(this.clan_data.state_data.tick_counter)) {
      this.clan_data.units = this.tickUnits(this.clan_data.units, this.isNewRabbit(this.clan_data.timestamp));
    }
    this.resource_calc.runCombinations();
    this.clan_data.resources = this.resource_calc.resources;
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

  GameTick.prototype.tickUnits = function(units, isNewRabbit) {
    var unit, unitIndex, unit_costs, unit_tick, _i, _len;
    for (unitIndex = _i = 0, _len = units.length; _i < _len; unitIndex = ++_i) {
      unit = units[unitIndex];
      unit_tick = new UnitTick(unit, this.clan_data.current_policies.wages, isNewRabbit);
      unit_costs = unit_tick.costs();
      if (this.resource_calc.canAfford(unit_costs)) {
        this.resource_calc.deplete(unit_costs);
      } else {
        if (unit_tick.isOnDuty()) {
          unit_tick.decommission();
        } else {
          unit_tick.starvationPenalty();
        }
      }
      units[unitIndex] = unit_tick.unit;
    }
    return units;
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

  ResourceCalculator.prototype.formulas = [
    {
      resource: 'meal',
      value: 1,
      cost: {
        rice: 1,
        meat: 1
      },
      greedy: true
    }
  ];

  ResourceCalculator.prototype.canAfford = function(prices) {
    var cost, resource_key, result;
    result = true;
    for (resource_key in prices) {
      cost = prices[resource_key];
      if (result === false) {
        break;
      }
      if (!(resource[resource_key] && resource[resource_key] >= cost)) {
        result = false;
      }
    }
    return result;
  };

  ResourceCalculator.prototype.deplete = function(prices) {
    var cost, resource_key, _results;
    if (Object.keys(prices).length === 0) {
      return true;
    }
    if (!this.canAfford(prices)) {
      return false;
    }
    _results = [];
    for (resource_key in prices) {
      cost = prices[resource_key];
      _results.push(this.resources[resource_key] = this.resources[resource_key] - cost);
    }
    return _results;
  };

  ResourceCalculator.prototype.grant = function(grants) {
    var cost, resource_key, _results;
    if (Object.keys(grants).length === 0) {
      return true;
    }
    _results = [];
    for (resource_key in grants) {
      cost = grants[resource_key];
      _results.push(this.resources[resource_key] = (this.resources[resource_key] || 0) + cost);
    }
    return _results;
  };

  ResourceCalculator.prototype.runCombinations = function() {
    var formula, _i, _len, _ref, _results;
    _ref = this.formulas;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      formula = _ref[_i];
      if (this.canAfford(formula['cost']) && formula['greedy']) {
        _results.push((function() {
          var _results1;
          _results1 = [];
          while (this.canAfford(formula['cost'])) {
            _results1.push(this.deplete(formula['cost']));
          }
          return _results1;
        }).call(this));
      } else {
        _results.push(void 0);
      }
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
  mainCycle: null,
  activeClans: []
};

Global.firebaseRef.child("clans").on("child_added", function(snapshot) {
  var clan_data;
  clan_data = snapshot.val();
  return GameState.activeClans.push(snapshot.key());
});

GameState.mainCycle = setInterval(function() {
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
