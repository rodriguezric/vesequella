extends Node

@export var enemy_name : String
var enemy

func use_torch(source, target):
    await IO.scroll_text("%s lights the %s on fire" % [source.name, target.name])

var torch = {
    "name": "Torch",
    "description": "A disposable torch.",
    "use": use_torch
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    CTX.inventory = [torch.duplicate()]

    if not enemy_name:
        enemy_name = CTX.enemies.keys().pick_random()

    BATTLE.run(enemy_name)
