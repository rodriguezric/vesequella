extends AudioStreamPlayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

const BATON = preload("res://music/baton.ogg")
const BEST_FRIEND = preload("res://music/chip_best_friend.mp3")
const FACES = preload("res://music/chip_faces.mp3")
const BOUNCE = preload("res://music/chip_midnight_bounce.mp3")
const MYSTERY = preload("res://music/chip_midnight_bounce.mp3")
const GREENSLEEVES = preload("res://music/cm_greensleeves.mp3")
const MOSAKU = preload("res://music/cm_moskau.mp3")
const REEDS = preload("res://music/cm_reeds.mp3")
const SONATA = preload("res://music/cm_sonata.mp3")
const UNDERSEA = preload("res://music/ct_undersea.mp3")
const ZEAL = preload("res://music/ct_zeal.mp3")
const BOSS = preload("res://music/mmx4_boss.mp3")
const OVERWORLD = preload("res://music/overworld.ogg")
const POLIS = preload("res://music/polis.ogg")

var current_track: AudioStream

func play_track(track_name: AudioStream):
    current_track = track_name
    stream = track_name
    stream.loop = true
    play()

func fade_in():
    var tween = get_tree().create_tween()
    volume_db = -80
    await tween.tween_property(
        MUSIC,
        "volume_db",
        0,
        1,
    )

func fade_out():
    var tween = get_tree().create_tween()
    await tween.tween_property(
        MUSIC,
        "volume_db",
        -80,
        3
    )
