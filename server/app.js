var CONFIG;

CONFIG = {
  resource_descriptions: {
    glowstones: 'Main currency used',
    meal: 'Meals are used to feed your population',
    meat: 'Second half a part of a well-rounded meal',
    rice: 'First half a part of a well-rounded meal',
    timber: 'Used to create wooden buildings'
  },
  calendar: {
    morrows_per_rabbit: 30,
    morrows_per_lion: 119,
    morrows_per_elephant: 659
  },
  formulas: [
    {
      value: {
        meal: 1
      },
      cost: {
        rice: 1,
        meat: 1
      },
      greedy: true
    }
  ]
};

var CONFIG;

CONFIG = {
  resource_descriptions: {
    glowstones: 'Main currency used',
    meal: 'Meals are used to feed your population',
    meat: 'Second half a part of a well-rounded meal',
    rice: 'First half a part of a well-rounded meal',
    timber: 'Used to create wooden buildings'
  },
  calendar: {
    morrows_per_rabbit: 30,
    morrows_per_lion: 119,
    morrows_per_elephant: 659
  },
  formulas: [
    {
      value: {
        meal: 1
      },
      cost: {
        rice: 1,
        meat: 1
      },
      greedy: true
    }
  ]
};

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
      this.resource_calc.runCombinations();
    }
    this.clan_data.resources = this.resource_calc.resources;
  }

  GameTick.prototype.isNewRabbit = function(timestamp) {
    return (timestamp % CONFIG.calendar.morrows_per_rabbit) === 0;
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
  ResourceCalculator.prototype.formulas = CONFIG.formulas;

  function ResourceCalculator(resources) {
    this.resources = resources;
  }

  ResourceCalculator.prototype.canAfford = function(prices) {
    var cost, key, result;
    result = true;
    for (key in prices) {
      cost = prices[key];
      if (result === false) {
        break;
      }
      if (!(this.resources[key] && this.resources[key] >= cost)) {
        result = false;
      }
    }
    return result;
  };

  ResourceCalculator.prototype.deplete = function(prices) {
    var cost, key, _results;
    if (Object.keys(prices).length === 0) {
      return true;
    }
    if (!this.canAfford(prices)) {
      return false;
    }
    _results = [];
    for (key in prices) {
      cost = prices[key];
      _results.push(this.resources[key] = this.resources[key] - cost);
    }
    return _results;
  };

  ResourceCalculator.prototype.grant = function(grants) {
    var cost, key, _results;
    if (Object.keys(grants).length === 0) {
      return true;
    }
    _results = [];
    for (key in grants) {
      cost = grants[key];
      _results.push(this.resources[key] = (this.resources[key] || 0) + cost);
    }
    return _results;
  };

  ResourceCalculator.prototype.runCombinations = function() {
    var formula, _i, _len, _ref, _results;
    _ref = this.formulas;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      formula = _ref[_i];
      _results.push((function() {
        var _results1;
        _results1 = [];
        while (this.canAfford(formula['cost'])) {
          if (this.deplete(formula['cost'])) {
            this.grant(formula['value']);
          }
          if (!formula['greedy']) {
            break;
          } else {
            _results1.push(void 0);
          }
        }
        return _results1;
      }).call(this));
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
  ticks_per_morrow: 10
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
