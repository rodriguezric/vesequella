extends AudioStreamPlayer

const ATTACK = preload("res://sfx/attack.ogg")
const CRIT = preload("res://sfx/crit.ogg")
const HIT = preload("res://sfx/hit.ogg")
const MISS = preload("res://sfx/miss.ogg")
const PICKUP = preload("res://sfx/pickup.ogg")
const PORTAL = preload("res://sfx/portal.ogg")
const UIMOVE = preload("res://sfx/uimove.ogg")
const UISELECT = preload("res://sfx/uiselect.ogg")
const UITYPER = preload("res://sfx/uityper.ogg")
const BATTLE_STARTED = preload("res://sfx/battle_started.ogg")

func play_track(sfx: AudioStream):
    stream = sfx
    play()
