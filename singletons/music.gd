extends AudioStreamPlayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

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


var current_track: AudioStream

func play_track(track_name: AudioStream):
    if track_name != current_track:
        var fade_in = false
        if playing:
            animation_player.play("fade_out")
            await animation_player.animation_finished
            fade_in = true

        current_track = track_name
        stream = track_name
        stream.loop = true
        play()

        if fade_in:
            animation_player.play("fade_in")
