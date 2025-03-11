class_name Shop
extends Node


@export var items: Array[CTX.ItemEnum]
@export var prices: Array[int]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    assert(items.size() == prices.size())

func run():
    var item_names = items.map(func(x): return CTX.item_map[x].name)
    await IO.scroll_text("Take a look and see what you like.")
    var idx = await IO.show_grid_menu(item_names)

    var item = CTX.item_map.get(items[idx])
    var item_name = item_names[idx]
    var price = prices[idx]

    var text = "%s, that will be %d. Do you want to buy it?" % [item_name, price]
    var choice_idx = await IO.menu(["YES", "NO"], text)

    if choice_idx == 0:
        #TODO check if enough money
        CTX.inventory.append(item.duplicate())
        await IO.scroll_text("You purchased %s" % item_name)
    else:
        await IO.scroll_text("No problem")

    return
