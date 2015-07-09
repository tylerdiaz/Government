DATA = {} if DATA is undefined

DATA['professions'] =
  scout:
    start: { exp: 50, damage: [1, 4], accuracy: 0.35, max_hp: 10 }
    end: { exp: 25000, damage: [30, 65], accuracy: 0.90, max_hp: 220 }
  lumberman:
    start: { exp: 15, damage: [1, 2], accuracy: 0.2, max_hp: 6 }
    end: { exp: 900, damage: [4, 12], accuracy: 0.5, max_hp: 40 }
  drunk:
    start: { exp: 50, damage: [1, 2], accuracy: 0.2, max_hp: 6 }
    end: { exp: 700, damage: [4, 6], accuracy: 0.5, max_hp: 40 }
  spearman:
    start: { exp: 100, damage: [2, 8], accuracy: 0.5, max_hp: 18 }
    end: { exp: 30000, damage: [35, 90], accuracy: 0.95, max_hp: 320 }
