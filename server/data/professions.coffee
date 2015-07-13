DATA = {} if DATA is undefined

DATA['professions'] =
  scout:
    starting_stats: { exp: 50, damage: [1, 4], accuracy: 0.35, max_hp: 10 }
    final_stats: { exp: 25000, damage: [30, 65], accuracy: 0.90, max_hp: 220 }
    targets: ['discovered_territories']
  lumberman:
    starting_stats: { exp: 15, damage: [1, 2], accuracy: 0.2, max_hp: 6 }
    final_stats: { exp: 900, damage: [4, 12], accuracy: 0.5, max_hp: 40 }
    targets: ['self', 'opponents', 'self_units', 'discovered_territories']
  teacher:
    starting_stats: { exp: 15, damage: [1, 2], accuracy: 0.2, max_hp: 6 }
    final_stats: { exp: 900, damage: [4, 12], accuracy: 0.5, max_hp: 40 }
    targets: ['self_units']
  drunk:
    starting_stats: { exp: 50, damage: [1, 2], accuracy: 0.2, max_hp: 6 }
    final_stats: { exp: 700, damage: [4, 6], accuracy: 0.5, max_hp: 40 }
    targets: []
  spearman:
    starting_stats: { exp: 100, damage: [2, 8], accuracy: 0.5, max_hp: 18 }
    final_stats: { exp: 30000, damage: [35, 90], accuracy: 0.95, max_hp: 320 }
    targets: ['self', 'self_units']
