extends Control

@onready var start_button: Button = $TextureRect/MarginContainer/VBoxContainer/StartButton
@onready var options_button: Button = $TextureRect/MarginContainer/VBoxContainer/OptionsButton
@onready var quit_button: Button = $TextureRect/MarginContainer/VBoxContainer/QuitButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    start_button.button_down.connect(_on_start_button_down)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func _on_start_button_down():
    VFX.fadeout()
    await VFX.fadeout_finished
    get_tree().change_scene_to_file("res://game.tscn")
