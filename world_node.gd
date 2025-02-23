class_name WorldNode
extends Node

@export_multiline var description : String
@export var north_node : Node
@export var south_node : Node
@export var east_node : Node
@export var west_node : Node
@export var encounters : Array[CTX.Enemy]
@export_range(0, 100, 1) var encounter_rate : int = 0

@export var game_node : Node
# Note, enter_functions will only be called from Game node
@export var enter_function : String

var menu_idx
var move_idx
var invn_idx

func run():
    if CTX.rng.randi_range(1, 100) <= encounter_rate:
        var encounter = encounters.pick_random()
        await BATTLE.run(encounter)

    if MUSIC.current_track != MUSIC.OVERWORLD:
        MUSIC.play_track(MUSIC.OVERWORLD)

    while true:
        var menu_list = ["ENTER", "MOVE", "ITEM"]
        var func_list = [enter_fn, move_fn, item_fn]

        if not enter_function:
            menu_list.pop_front()
            func_list.pop_front()

        menu_idx = await IO.menu(menu_list, description)

        if await func_list[menu_idx].call():
            return

func enter_fn() -> bool:
    # Boolean return represents whether the caller should return out of the
    # while true game loop
    MUSIC.stop()
    await IO.scroll_text("You enter")
    game_node.call(enter_function)
    return true

func move_fn() -> bool:
    # Boolean return represents whether the caller should return out of the
    # while true game loop
    var move_list = []
    var node_list = []

    if north_node:
        move_list.append("NORTH")
        node_list.append(north_node)

    if south_node:
        move_list.append("SOUTH")
        node_list.append(south_node)

    if east_node:
        move_list.append("EAST")
        node_list.append(east_node)

    if west_node:
        move_list.append("WEST")
        node_list.append(west_node)

    move_list.append("CANCEL")

    move_idx = await IO.menu(move_list, "Which direction will you move?")

    if move_idx > -1 and move_idx < move_list.size() - 1:
        await IO.scroll_text("You travel %s" % move_list[move_idx])
        node_list[move_idx].run()
        return true

    return false

func item_fn() -> bool:
    # Boolean return represents whether the caller should return out of the
    # while true game loop
    invn_idx = await IO.show_inventory()
    if invn_idx > -1:
        await IO.show_text(CTX.inventory[invn_idx].description)

    return false
