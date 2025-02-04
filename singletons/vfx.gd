extends CanvasLayer

signal fadeout_finished
signal fadein_finished

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
    color_rect.visible = false
    animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(animation_name):
    match animation_name:
        "fadeout":
            animation_player.play("fadein")
            fadeout_finished.emit()
        "fadein", "flash":
            color_rect.visible = false
            fadein_finished.emit()

func fadeout():
    color_rect.visible = true
    color_rect.color = Color(0, 0, 0, 1)
    animation_player.play("fadeout")

func flash(color: Color):
    color_rect.visible = true
    color_rect.color = color
    animation_player.play("flash")

func flash_window(color: Color):
    var orig_color = IO.window_color_rect.color
    var tween = get_tree().create_tween()
    tween.tween_property(
        IO.window_color_rect,
        "color",
        color,
        0.05,
    )
    tween.chain().tween_property(
        IO.window_color_rect,
        "color",
        orig_color,
        0.05,
    )

func shake_obj(obj, dist, duration):
    var tween = create_tween()
    tween.tween_property(
        obj,
        "position",
        obj.position - Vector2(dist, 0),
        duration,
    )

    tween.chain().tween_property(
        obj,
        "position",
        obj.position,
        duration,
    )

    tween.chain().tween_property(
        obj,
        "position",
        obj.position + Vector2(dist, 0),
        duration,
    )

    tween.chain().tween_property(
        obj,
        "position",
        obj.position,
        duration,
    )

func shake_hero_stats() -> void:
    shake_obj(IO.hero_stats_container, 5, 0.05)

func shake_window_message() -> void:
    shake_obj(IO.window_message, 5, 0.05)
