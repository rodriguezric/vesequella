extends Node

signal game_event_sig
signal start_battle_sig
signal enter_room_sig

var SIG_MAP = {
    "event": game_event_sig,
    "battle": start_battle_sig,
    "room": enter_room_sig,
}

func run(data: Dictionary) -> void:
    var description_list = data.description_list
    var first_description = description_list[0]
    var last_description = description_list[-1]

    var encounter_flg = false
    var encounter_chance = data.encounter_dict.chance
    encounter_flg = encounter_chance > SKILL.rng.randi_range(1, 100)

    if encounter_flg:
        await VFX.flash(Color.WHITE)
        var enemy_name = data.encounter_dict.enemy_names.pick_random()
        start_battle_sig.emit({"enemy_name": enemy_name})
        await BATTLE.complete_sig

    if first_description == last_description:
        await IO.scroll_text(first_description, false)
    else:
        await IO.scroll_text(first_description)
        for description_text in description_list.slice(1, -1):
            await IO.append_text(description_text)
        await IO.append_text(last_description, false)

    var choice_idx = await IO.menu(data.menu_list)
    var result_dict = data.result_list[choice_idx]

    var sig = SIG_MAP[result_dict["sig"]]
    sig.emit(result_dict["data"])
