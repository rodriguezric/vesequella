extends Node2D

enum SceneEnum {NONE, BATON_TOWN}
@export var debug_scene: SceneEnum
var debug_scene_map = {
    SceneEnum.BATON_TOWN: baton_town_room,
}

var rng = RandomNumberGenerator.new()

@onready var baton_world_node: WorldNode = $World/Baton

var switches = {
    "baton_professor_quest_received": false,
    "baton_professor_quest_completed": false,
    "baton_professor_quest_rewarded": false,
    "baton_lumarius_introduction": false,
}

var names = {
    "LUMARIUS": "Lumarius",
}
var limarius_one_liners = [
    "'Did you know some slimes can change color based on their mood? This one’s always blue—must be a chill little guy!'",
    "'I once saw a slime eat an entire apple. It took a week, but it was the happiest slime I’ve ever met!'",
    "'You should see my jar collection! Each one is specially designed to keep slimes comfy and safe. They deserve the best, you know!'",
    "'I think slimes are like people—each one’s unique. Some are shy, some are bold, and some are just plain weird!'",
    "'If you listen closely, you can hear slimes giggle. It’s the cutest sound in the world!'",
    "'This slime here? It’s a rare Shimmerglow. It sparkles like starlight when it’s happy!'",
    "'I’ve been trying to teach this slime to juggle. So far, it’s just really good at sticking to things.'",
    "'Slimes are great listeners. They never interrupt, and they always nod—well, wobble—along!'",
    "'I once met a slime that could mimic voices. It kept saying ‘blorp’ in my voice for days!'",
    "'You haven’t lived until you’ve seen a slime dance. It’s like watching jelly in an earthquake!'"
]

var potion = {
    "id": "potion",
    "name": "Potion",
    "description": "A medicinal potion",
}

var torch = {
    "id": "torch",
    "name": "Torch",
    "description": "Chat GPT the description",
}

var boots = {
    "id": "boots",
    "name": "Boots",
    "description": "A warm pair of boots",
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if debug_scene:
        await debug_scene_map[debug_scene].call()
    else:
        await intro_scene()
        await baton_professor_room()

func proc_text_list(text_list):
    # Helper function for scrolling a list of texts
    # It will clear the window and show the first text
    # then append the remainder without clearing
    await IO.scroll_text(text_list[0])
    for text in text_list.slice(1):
        await IO.append_text(text)

func intro_scene() -> void:
    var player_name = ""
    var choice_idx: int

    var intro_scene_1 = [
        "You are in a grand lecture hall filled with murmuring students.",
        "The walls are lined with ancient tomes and glowing orbs, casting a soft, shifting light across the room.",
        "The professor, a stern yet kind-looking figure draped in flowing robes, steps forward, his voice calm yet commanding."
    ]
    await proc_text_list(intro_scene_1)

    var intro_scene_2 = [
        "\"Greetings, students.",
        "Welcome to your first day at Baton Academy, where you will embark on a journey to master the great art of magic.",
        "Whether you are here to heal, to harness shadow, or to command the forces of motion, know that your study requires both discipline and imagination.\""
    ]
    await proc_text_list(intro_scene_2)

    var intro_scene_3 = [
        "He pauses, glancing across the room, as if assessing each student."
    ]
    await proc_text_list(intro_scene_3)

    var intro_scene_4 = [
        "\"You are more than mere students—you are the future of magical study.",
        "Each of you brings something unique, something that this academy and the world beyond have yet to see.",
        "Now, let us begin with introductions.",
        "You there…\""
    ]
    await proc_text_list(intro_scene_4)

    var intro_scene_5 = [
        "The professor gestures toward you."
    ]
    await proc_text_list(intro_scene_5)

    var intro_scene_6 = [
        "\"What is your name?\""
    ]
    await IO.scroll_text(intro_scene_6[0], false)
    player_name = await IO.prompt()
    while player_name == "":
        await IO.append_text("\"I didn't hear you, what is your name?\"")
        player_name = await IO.prompt()

    CTX.player.name = player_name

    var intro_scene_7 = [
        "After hearing your name, the professor nods."
    ]
    await proc_text_list(intro_scene_7)

    var intro_scene_8 = [
        "\"Well then, %s, it is a pleasure to welcome you." % [player_name],
        "After today’s session, I would like a brief word with you.",
        "It won’t take long.",
        "Now, let us continue…\""
    ]
    await proc_text_list(intro_scene_8)

# Baton rooms
func baton_professor_room():
    var menu_idx
    var invn_idx
    var move_idx
    var intro_text =  "You step into the professor’s room, and the air immediately feels different—thick with the scent of old parchment and arcane herbs."
    await IO.scroll_text(intro_text)

    while true:
        var text =  "The professor is sitting at his desk, examining tomes and writing notes."
        menu_idx = await IO.menu(["TALK", "ITEM", "MOVE"], text)

        if menu_idx == 0:
            if not switches.baton_professor_quest_received:
                await proc_text_list([
                    "\"Hello %s, I'm glad you stopped by." % [CTX.player.name],
                    "I have a request, please take this letter to Vimarkos in Polis.",
                    "You can reach Polis by traveling west when you leave the town.\"",
                ])
                await IO.scroll_text("The professor hands you a letter.")
            elif not switches.baton_professor_quest_completed:
                await IO.scroll_text("The professor raises his eyes from the tomes.")
                await IO.scroll_text("\"Please, deliver the letter and let me know what Vimarkos has to say.")
            elif not switches.baton_professor_quest_rewarded:
                pass
            else:
                await IO.scroll_text("\"Hello %s, good to see you.\"" % [CTX.player.name])
        elif menu_idx == 1:
            print("ITEM")
            invn_idx = await IO.show_inventory()
            if invn_idx >= 0:
                await IO.scroll_text(CTX.inventory[invn_idx])
        elif menu_idx == 2:
            move_idx = await IO.menu(["TO TOWN", "CANCEL"], "Where do you want to go?")
            if move_idx == 0:
                baton_town_room()
                return

func baton_town_room():
    var menu_idx
    var invn_idx
    var move_idx

    while true:
        var text = "Cobblestone streets wind between charming stone buildings, their roofs topped with red clay tiles. Stalls in the marketplace hum with life, selling everything from fresh produce to enchanted trinkets."
        menu_idx = await IO.menu(["ACADEMY", "STORE", "TAVERN", "LIBRARY", "LEAVE"], text)

        if menu_idx == 0:
            await IO.scroll_text("You enter the academy")
            baton_professor_room()
            return
        elif menu_idx == 1:
            await IO.scroll_text("You enter the store")
            baton_store_room()
            return
        elif menu_idx == 2:
            await IO.scroll_text("You enter the tavern")
            baton_tavern_room()
            return
        elif menu_idx == 3:
            await IO.scroll_text("You enter the library")
            baton_library_room()
            return
        elif menu_idx == 4:
            await IO.scroll_text("You leave the town")
            baton_world_node.run()
            return

func baton_store_room():
    var menu_idx
    var invn_idx
    var shop_idx

    while true:
        var text = "A cozy shop brimming with arcane curiosities and rare spell ingredients, its shelves packed tightly with gleaming trinkets and dusty tomes."
        menu_idx = await IO.menu(["BUY", "SELL", "LEAVE"], text)

        if menu_idx == 0:
            var shop_items = ["POTION", "BOLT SCROLL", "HEAL SCROLL"]
            await IO.scroll_text("\"Take a look and see what you like.\"")
            shop_idx = await IO.show_grid_menu(shop_items)

            await IO.scroll_text("You chose %s, that costs %d, do you want to buy it?" % [shop_items[shop_idx], shop_idx])

            pass
        elif menu_idx == 1:
            invn_idx = await IO.show_inventory()
            if invn_idx >= 0:
                await IO.scroll_text(CTX.inventory[invn_idx])
        elif menu_idx == 2:
            await IO.scroll_text("You leave the shop.")
            baton_town_room()
            return
    pass

func baton_tavern_room():
    var menu_idx
    var invn_idx
    var talk_idx

    while true:
        var text = "Lanterns cast a warm glow over the room, the scent of spiced cider fills the air, and the cheerful murmur of travelers and townsfolk sharing tales surrounds you."
        menu_idx = await IO.menu(["TALK", "LEAVE"], text)

        if menu_idx == 0:
            var people = ["OLD MAN", "BOY", "CANCEL"]

            if switches.baton_lumarius_introduction:
                people[1] = names.LUMARIUS

            talk_idx = await IO.menu(people, "Who do you want to talk to?")

            if talk_idx == 0:
                # this guy can make slime boots
                await IO.scroll_text("The old man greets you with a smile raising his mug.")
            elif talk_idx == 1:
                if not switches.baton_lumarius_introduction:
                    switches.baton_lumarius_introduction = true
                    await IO.scroll_text("A young boy with a satchel full of jars approaches you, his eyes sparkling with excitement. Each jar clinks softly as he moves, containing slimes of various colors and sizes.")
                    await IO.scroll_text("'Hi there! My name’s Limarius, and I’m a slime collector!'")
                    await IO.append_text("'Do you like slimes too?'", false)
                    var like_slimes_idx = await IO.menu(["YES", "NO"])
                    if like_slimes_idx == 0:
                        await IO.append_text("'Great to hear! If you find any interesting slimes please bring them my way'", false)
                    else:
                        await IO.append_text("'I get it, not everyone can appreciate the intricacies of slimeology.'", false)
                else:
                    await IO.scroll_text("%s shuffles through his jars of slimes. He looks up" % [names.LUMARIUS], false)

                while true:
                    menu_idx = await IO.menu(["TALK", "ITEM", "CANCEL"])
                    if menu_idx == 0:
                        var slime_talk = limarius_one_liners.pick_random()
                        await IO.scroll_text(slime_talk, false)
                    elif menu_idx == 1:
                        invn_idx = await IO.show_inventory()
                        await IO.scroll_text("Some debug invn text", false)
                    elif menu_idx == 2:
                        break
        if menu_idx == 1:
            await IO.scroll_text("You leave the tavern.")
            baton_town_room()
            return

func baton_library_room():
    var menu_idx
    var book_idx

    while true:
        var text = "Towering shelves of ancient tomes surround you, the air thick with the scent of parchment and the whispers of forgotten knowledge."
        menu_idx = await IO.menu(["BOOK OF POTIONS", "BOOK OF BEASTS", "BOOK OF MAGIC", "LEAVE"], text)

        if menu_idx == 0:
            book_idx = await IO.menu(["INTRO", "USES", "ELIXER", "CLOSING", "CANCEL"], "Which chapter would you like to read?")

            if book_idx == 0:
                await proc_text_list([
                    "INTRO",
                    "Potions are essential for magical healing, offering solutions for injuries and illnesses that can be stored and used as needed.",
                    "Healing potions typically use a blend of natural herbs, mystical extracts, and magical catalysts to trigger restorative effects.",
                ])
            elif book_idx == 1:
                await proc_text_list([
                    "USES",
                    "A single versatile potion can serve a variety of healing purposes. It can rehydrate the body, soothing the effects of dehydration and restoring lost vitality.",
                    "The same potion can mend minor wounds, closing small cuts and easing bruises with a calming, restorative effect.",
                    "In addition, it can enhance mental clarity, clearing distractions and sharpening focus, making it ideal for moments requiring concentration or during physical exhaustion.",
                ])
            elif book_idx == 2:
                await proc_text_list([
                    "ELIXER",
                    "The Elixer is a mythical potion said to grant godlike powers and the ability to lift even the darkest curses.",
                    "Legends speak of a young alchemist who created The Elixer to save their village from a plague and a curse. Though they succeeded, the alchemist vanished, sparking rumors of the potion's hidden price.",
                    "While its recipe remains lost, The Elixer inspires alchemists to pursue mastery with caution and responsibility.",
                ])
            elif book_idx == 3:
                await proc_text_list([
                    "CLOSING",
                    "Potion-making is a delicate and rewarding art. From simple healing draughts to legendary brews, potions remind us of their power to transform lives.",
                ])

        elif menu_idx == 1:
            await IO.scroll_text("You open the Book of Beasts.")
        elif menu_idx == 2:
            await IO.scroll_text("You open the Book of Magic.")
        elif menu_idx == 3:
            await IO.scroll_text("You leave the library.")
            baton_town_room()
            return
