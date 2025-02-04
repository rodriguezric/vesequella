extends Node

var rng = RandomNumberGenerator.new()
var inventory = []
var tokens = 10

# Player Data
var player = {
    "name": "",
    "hp": 10,
    "sp": 5,
    "atk": 5,
    "def": 2,
    "dex": 2,
    "agi": 2,
}

# Enemy Models
var rat = {
    "name": "Rat",
    "description": "A vile Rat",
    "hp": 8,
    "sp": 5,
    "atk": 2,
    "def": 2,
    "dex": 3,
    "agi": 5,
    "skills": [
        SKILL.attack,
        SKILL.rat_eat_cheese,
        SKILL.rat_nibble,
    ]
}

var slime = {
    "name": "Slime",
    "description": "A green Slime",
    "hp": 6,
    "sp": 5,
    "atk": 3,
    "def": 1,
    "dex": 2,
    "agi": 3,
    "skills": [
        SKILL.attack,
        SKILL.pulses_eerily,
    ]
}

var squishy_slime = {
    "name": "Slime",
    "description": "A squishy, green Slime",
    "hp": 4,
    "sp": 5,
    "atk": 2,
    "def": 1,
    "dex": 1,
    "agi": 4,
    "skills": [
        SKILL.attack,
        SKILL.pulses_eerily,
    ]
}

var goblin = {
    "name": "Goblin",
    "description": "A Goblin",
    "hp": 12,
    "sp": 5,
    "atk": 4,
    "def": 3,
    "dex": 3,
    "agi": 6,
    "skills": [
        SKILL.attack,
        SKILL.trip,
    ]
}

var lost_sorcerer = {
    "name": "Tattered Sorcerer",
    "description": "A tattered Sorcerer",
    "hp": 10,
    "sp": 5,
    "atk": 2,
    "def": 3,
    "dex": 3,
    "agi": 3,
    "skills": [
        #SKILL.attack,
        SKILL.bolt,
        #SKILL.fizzle,
    ]
}

enum Enemy {
    RAT,
    SLIME,
    SQUISHY_SLIME,
    GOBLIN,
    LOST_SORCERER,
}

# map for getting a copy an instance of an enemy model
var enemy_map = {
    Enemy.RAT: rat,
    Enemy.SLIME: slime,
    Enemy.SQUISHY_SLIME: squishy_slime,
    Enemy.GOBLIN: goblin,
    Enemy.LOST_SORCERER: lost_sorcerer,
}

func create_enemy(enemy: Enemy):
    return enemy_map[enemy].duplicate()

func dice_roll(sides, modifier=0):
    # Roll 1d{sides} + modifier
    return rng.randi_range(1, sides) + modifier
