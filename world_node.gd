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

    IO.north.disabled = true
    IO.south.disabled = true
    IO.east.disabled = true
    IO.west.disabled = true
    IO.nav_enter.disabled = true

    if north_node:
        IO.north.disabled = false

    if south_node:
        IO.south.disabled = false

    if east_node:
        IO.east.disabled = false

    if west_node:
        IO.west.disabled = false

    if enter_function:
        IO.nav_enter.disabled = false

    while true:
        var nav_idx = await IO.show_nav(description)
        if nav_idx == IO.NavEnum.NORTH:
            north_node.run()
            return
        elif nav_idx == IO.NavEnum.SOUTH:
            south_node.run()
            return
        elif nav_idx == IO.NavEnum.EAST:
            east_node.run()
            return
        elif nav_idx == IO.NavEnum.WEST:
            west_node.run()
            return
        elif nav_idx == IO.NavEnum.ENTER:
            await enter_fn()
            return
        elif nav_idx == IO.MENU_IDX:
            await IO.show_esc_menu()

func enter_fn() -> bool:
    # Boolean return represents whether the caller should return out of the
    # while true game loop
    MUSIC.stop()
    await IO.scroll_text("You enter")
    game_node.call(enter_function)
    return true

func item_fn() -> bool:
    # Boolean return represents whether the caller should return out of the
    # while true game loop
    invn_idx = await IO.show_inventory()
    await CTX.use_item(invn_idx, CTX.player)

    return false
