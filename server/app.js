var CONFIG;

CONFIG = {
  scouting_focus_options: ['food', 'weapons', 'looting'],
  denormalized_tables: ['units', 'resources', 'state_data', 'formulas'],
  resource_descriptions: {
    meal: 'Meals are used to feed your population',
    sophisticated_meal: 'Sophisticated meals are used to feed your population and increase morale',
    beef: 'Second half a part of a well-rounded meal',
    fish: 'Second half a part of a well-rounded meal',
    rice: 'First half a part of a well-rounded meal. It\'s slow to work with.',
    bread: 'First half a part of a well-rounded meal',
    grapes: 'A sweet fruit that makes up part of a sophisticated meal',
    cheese: 'Cheese made from the milk of goats that makes up part of a sophisticated meal',
    hops: 'A bitter flower used to make beer',
    yeast: 'Versatile ingredient for making delicious things',
    beer: 'Alcholic beverage that increases morale. It takes some time to make.',
    wine: 'Alcholic beverage that makes up part of a sophisticated meal. It takes some time to make.',
    flour: 'Versatile ingredient for making things',
    iron: 'Material used to create sturdy weapons and building features',
    spear: 'A frail weapon used for combat',
    timber: 'Used to create wooden buildings',
    glowstones: 'Main currency used'
  },
  calendar: {
    morrows_per_rabbit: 30,
    morrows_per_lion: 119,
    morrows_per_elephant: 659
  },
  stages: {
    1: {
      overlay: ['map-frontyard-forest'],
      underlay: ['map-start-greenland']
    },
    2: {
      overlay: [],
      underlay: ['map-start-greenland']
    },
    3: {
      overlay: ['map-backyard-forest'],
      underlay: ['map-greenland']
    },
    4: {
      overlay: [],
      underlay: ['map-greenland']
    },
    5: {
      overlay: ['map-backyard-forest'],
      underlay: ['map-greenland', 'map-desert']
    },
    6: {
      overlay: [],
      underlay: ['map-greenland', 'map-desert']
    },
    7: {
      overlay: [],
      underlay: ['map-water', 'map-greenland', 'map-desert']
    }
  }
};

var GameTick;

GameTick = (function() {
  function GameTick(clan_data) {
    var runtime_formulas;
    this.clan_data = clan_data;
    this.resource_calc = new ResourceCalculator(this.clan_data.resources);
    this.clan_data.state_data.tick_counter = this.clan_data.state_data.tick_counter + 1;
    this.clan_data.state_data.timestamp = this.morrowTick(this.clan_data.state_data.tick_counter, this.clan_data.state_data.timestamp);
    runtime_formulas = this.clan_data.formulas;
    if (this.isNewRabbit(this.clan_data.state_data.timestamp)) {
      this.clan_data.current_policies = this.clan_data.proposed_policies;
    }
    if (this.isNewMorrow(this.clan_data.state_data.tick_counter)) {
      this.clan_data.units = this.tickUnits(this.clan_data.units, this.isNewRabbit(this.clan_data.state_data.timestamp));
    }
    if (this.isNewMorrow(this.clan_data.state_data.tick_counter)) {
      this.clan_data.morale = parseFloat(this.clan_data.morale) + this.unitMoraleOffset(this.clan_data.units);
      this.resource_calc.runFormulas(runtime_formulas);
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

  GameTick.prototype.unitMoraleOffset = function(units) {
    return parseFloat(Object.keys(units).reduce((function(_this) {
      return function(memo, key) {
        return memo + units[key].morale_rate;
      };
    })(this), 0));
  };

  GameTick.prototype.tickUnits = function(units, isNewRabbit) {
    var unit, unitIndex, unit_costs, unit_tick, _i, _len;
    if (units === null) {
      return [];
    }
    for (unitIndex = _i = 0, _len = units.length; _i < _len; unitIndex = ++_i) {
      unit = units[unitIndex];
      if (unit === void 0) {
        continue;
      }
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
      if (unit_tick.isDead()) {
        units.splice(unitIndex, 1);
      } else {
        units[unitIndex] = unit_tick.unit;
      }
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

  ResourceCalculator.prototype.runFormulas = function(formulas) {
    var formula, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = formulas.length; _i < _len; _i++) {
      formula = formulas[_i];
      if (!formula['enabled']) {
        continue;
      }
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

var Firebase, GameState, Global, joinPaths, _,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

Firebase = require('firebase');

_ = require('underscore');

Global = {
  firebaseRef: new Firebase("ws://local.firebaseio.com:5111"),
  tickRate: 1000,
  ticks_per_morrow: 2
};

GameState = {
  mainCycle: null,
  activeClans: [],
  clanDataStructureKeys: []
};

joinPaths = function(id, paths, fn) {
  var expectedCount, mergedObject, returnCount;
  returnCount = 0;
  expectedCount = paths.length;
  mergedObject = {};
  return paths.forEach(function(p) {
    return Global.firebaseRef.child(p + '/' + id).once('value', function(snap) {
      if (__indexOf.call(CONFIG.denormalized_tables, p) >= 0) {
        mergedObject[p] = snap.val();
      } else {
        _.extend(mergedObject, snap.val());
      }
      if (++returnCount === expectedCount) {
        return fn(null, mergedObject);
      }
    }, function(error) {
      returnCount = expectedCount + 1;
      return fn(error, null);
    });
  });
};

Global.firebaseRef.child("clans").on("child_added", function(snapshot) {
  GameState.clanDataStructureKeys = Object.keys(snapshot.val());
  return GameState.activeClans.push(snapshot.key());
});

GameState.mainCycle = setInterval(function() {
  var clanKey, _i, _len, _ref, _results;
  _ref = GameState.activeClans;
  _results = [];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    clanKey = _ref[_i];
    _results.push(joinPaths(clanKey, CONFIG.denormalized_tables.concat(['clans']), function(err, combined_value) {
      var actuated_clan_data, frozen_start_value, game_tick, k, key, _j, _k, _len1, _len2, _ref1, _ref2, _results1;
      frozen_start_value = JSON.parse(JSON.stringify(combined_value));
      game_tick = new GameTick(combined_value);
      actuated_clan_data = {};
      _ref1 = GameState.clanDataStructureKeys;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        k = _ref1[_j];
        actuated_clan_data[k] = game_tick.clan_data[k];
      }
      Global.firebaseRef.child("clans/" + clanKey).set(actuated_clan_data);
      _ref2 = CONFIG.denormalized_tables;
      _results1 = [];
      for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
        key = _ref2[_k];
        if (!_.isEqual(frozen_start_value[key], game_tick.clan_data[key])) {
          _results1.push(Global.firebaseRef.child("" + key + "/" + clanKey).set(game_tick.clan_data[key]));
        } else {
          _results1.push(void 0);
        }
      }
      return _results1;
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

  UnitTick.prototype.isDead = function() {
    return this.unit.current_hp <= 0;
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
