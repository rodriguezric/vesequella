extends Control

enum NavEnum { NORTH, SOUTH, EAST, WEST, ENTER }

@onready var north: Button = $CenterContainer/NavMenu/North
@onready var west: Button = $CenterContainer/NavMenu/West
@onready var nav_enter: Button = $CenterContainer/NavMenu/Enter
@onready var east: Button = $CenterContainer/NavMenu/East
@onready var south: Button = $CenterContainer/NavMenu/South

@onready var ap: AnimationPlayer = $ap
@onready var label: Label = $WindowMessage/MarginContainer/Label
@onready var timer: Timer = $WindowMessage/Timer
@onready var v_menu: VBoxContainer = $VMenu
@onready var grid_menu: GridContainer = $MarginContainer/MarginContainer/GridMenu
@onready var grid_menu_panel: Panel = $MarginContainer/GridMenuPanel
@onready var window_message: MarginContainer = $WindowMessage
@onready var window_color_rect: ColorRect = $WindowMessage/WindowColorRect
@onready var line_edit_submit: Button = $LineEditContainer/LineEditSubmit
@onready var line_edit: LineEdit = $LineEditContainer/LineEdit
@onready var line_edit_container: HBoxContainer = $LineEditContainer
@onready var advance_button: Button = $AdvanceButton
@onready var nav_menu: GridContainer = $CenterContainer/NavMenu

# Hero UI labels
@onready var hero_stats_container: CenterContainer = $VBoxContainer/HeroStatsContainer
@onready var name_label: Label = $VBoxContainer/HeroStatsContainer/HBoxContainer/MarginContainer/MarginContainer/VBoxContainer/NameLabel
@onready var hp_val_label: Label = $VBoxContainer/HeroStatsContainer/HBoxContainer/MarginContainer/MarginContainer/VBoxContainer/HPContainer/HPValLabel
@onready var sp_val_label: Label = $VBoxContainer/HeroStatsContainer/HBoxContainer/MarginContainer/MarginContainer/VBoxContainer/SPContaner/SPValLabel

signal closed
signal finished_displaying_text
signal option_selected
signal options_closed
signal hero_stats_changed
signal nav_sig

var text := ""
var finished := false
var active := true

const MAX_LINES = 9

func show_text(_text: String, close_flg := true):
    show_text_impl(_text)

    if close_flg:
        await closed
    else:
        await finished_displaying_text

func scroll_text(_text: String, close_flg := true):
    scroll_text_impl(_text)

    if close_flg:
        await closed
    else:
        await finished_displaying_text

func append_text(_text: String, close_flg := true):
    append_text_impl(_text)
    if close_flg:
        await closed
    else:
        await finished_displaying_text

func show_text_impl(_text: String):
    text = _text
    label.text = _text
    label.lines_skipped = 0
    label.visible_characters = label.get_total_character_count()
    visible = true
    window_message.visible = true
    advance_button.visible = true
    advance_button.grab_focus()
    finished = true

func scroll_text_impl(_text: String):
    text = _text
    label.text = _text
    label.lines_skipped = 0
    label.visible_characters = 0
    visible = true
    window_message.visible = true
    advance_button.visible = true
    advance_button.grab_focus()
    finished = false
    timer.start()

func append_text_impl(_text: String):
    var visible_characters = label.visible_characters
    label.text += "\n" + _text
    label.visible_characters = visible_characters
    visible = true
    window_message.visible = true
    advance_button.visible = true
    advance_button.grab_focus()
    finished = false
    timer.start()

func prompt(clear_flg := true):
    visible = true
    var message_active_flg = advance_button.visible

    # Make it so we can't advance the message window
    active = false
    if message_active_flg:
        advance_button.visible = false

    line_edit_container.visible = true
    line_edit.grab_focus()
    await line_edit.text_submitted

    # Restore ability to advance the message window
    active = true
    if message_active_flg:
        advance_button.visible = true
        advance_button.grab_focus()
        advance_button.pressed.emit()

    line_edit_container.visible = false

    var line_edit_text = line_edit.text
    if clear_flg:
        line_edit.text = ""

    return line_edit_text

func menu(options: Array, text: String = ""):
    if text:
        await scroll_text(text, false)

    visible = true
    var message_active_flg = advance_button.visible

    active = false
    if message_active_flg:
        advance_button.visible = false

    v_menu.visible = true
    v_menu.show_options(options)
    var option_idx = await v_menu.option_selected

    active = true

    if message_active_flg:
        advance_button.visible = true
        advance_button.grab_focus()
        advance_button.pressed.emit()

    return option_idx

func confirm(scrolling := true):
    var idx = await menu(["YES", "NO"])
    return idx == 0

func show_grid_menu(options: Array):
    label.text = ""
    window_message.visible = false
    active = false

    visible = true
    grid_menu.visible = true
    grid_menu_panel.visible = true
    grid_menu.show_options(options)
    var idx = await grid_menu.option_selected

    grid_menu.visible = false
    grid_menu_panel.visible = false
    window_message.visible = true
    active = true
    return idx

func show_inventory():
    var options = CTX.inventory.map(func(x): return x.name)
    return await show_grid_menu(options)

func show_skills():
    var options = ["skill"]
    return await show_grid_menu(options)

func _ready() -> void:
    visible = false
    label.anchor_left = 0
    label.anchor_right = 1
    label.autowrap_mode = TextServer.AUTOWRAP_WORD
    timer.timeout.connect(_on_timer_timeout)
    line_edit_submit.button_down.connect(_on_line_edit_submit)
    advance_button.button_down.connect(_on_advance_button_down)
    hero_stats_changed.connect(_on_hero_stats_changed)

    north.button_down.connect(func(): nav_sig.emit(NavEnum.NORTH))
    south.button_down.connect(func(): nav_sig.emit(NavEnum.SOUTH))
    east.button_down.connect(func(): nav_sig.emit(NavEnum.EAST))
    west.button_down.connect(func(): nav_sig.emit(NavEnum.WEST))
    nav_enter.button_down.connect(func(): nav_sig.emit(NavEnum.ENTER))

func advance_text():
    if finished:
        visible = false
        window_message.visible = false
        closed.emit()
    else:
        label.visible_characters = label.get_total_character_count()

func _on_timer_timeout() -> void:
    if visible and not finished:
        label.visible_characters += 1
        if label.get_line_count() > MAX_LINES:
            label.lines_skipped = label.get_line_count() - MAX_LINES
        if label.visible_characters >= label.get_total_character_count():
            finished = true
            finished_displaying_text.emit()
            timer.stop()

func _on_line_edit_submit():
    line_edit.text_submitted.emit()

func _on_advance_button_down():
    if grid_menu.visible:
        window_message.visible = true
        active = true
        grid_menu.visible = false
        grid_menu_panel.visible = false
        grid_menu.option_selected.emit(-1)
    else:
        advance_text()

func _on_hero_stats_changed():
    hp_val_label.text = str(CTX.player.hp)
    sp_val_label.text = str(CTX.player.sp)

func show_nav(text: String = ""):
    await IO.scroll_text(text, false)

    var message_active_flg = advance_button.visible

    active = false
    if message_active_flg:
        advance_button.visible = false

    nav_menu.visible = true

    nav_enter.grab_focus()
    var nav_idx = await nav_sig

    nav_menu.visible = false

    return nav_idx
