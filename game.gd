extends Node2D

enum SceneEnum {NONE, BATON_TOWN, POLIS_CITY, YERKINK_VILLAGE}
enum ItemEnum {
    POTION,
    TORCH,
    SPYGLASS,
    BOOTS,
    ROPE,
    BOLT_SCROLL,
    HEAL_SCROLL,
    FOG_SCROLL,
    BRIGHT_SCROLL,
}

# Hack for preventing global running intro during title
@export var running: bool = false

@export var debug_scene: SceneEnum
var debug_scene_map = {
    SceneEnum.BATON_TOWN: baton_town_room,
    SceneEnum.POLIS_CITY: polis_city_room,
    SceneEnum.YERKINK_VILLAGE: yerkink_village_room,
}

@export var debug_inventory: Array[ItemEnum]

var rng = RandomNumberGenerator.new()

@onready var baton_world_node: WorldNode = $World/Baton
@onready var polis_world_node: WorldNode = $World/Polis
@onready var yerkink_world_node: WorldNode = $World/Yerkink

@onready var baton_shop: Shop = $Shop/BatonShop
@onready var polis_shop: Shop = $Shop/PolisShop
@onready var yerkink_shop: Shop = $Shop/YerkinkShop


func SWITCHES(): pass
var switches = {
    "baton_professor_quest_received": false,
    "baton_professor_quest_completed": false,
    "baton_professor_quest_rewarded": false,
    "baton_lumarius_introduction": false,
    "baton_caligarius_introduction": false,
    "baton_letter_opened": false,
    "polis_vimarkos_introduction": false,
    "polis_vimarkos_distrust": false,
    "polis_vimarkos_trust": false,
    "polis_pella_introduction": false,
    "polis_himar_introduction": false,
    "polis_himar_vanish": false,
    "yerkink_rope_restored": false,
    "yerkink_aman_introduction": false,
    "yerkink_aris_introduction": false,
    "yerkink_aris_given_token": false,
}

var names = {
    "LUMARIUS": "LUMARIUS",
    "CALIGARIUS": "CALIGARIUS",
    "PELLA": "PELLA",
    "HIMAR": "HIMAR",
    "ARIS": "ARIS",
    "AMAN": "AMAN",
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

var caligarius_one_liners = [
    "'Back in my youth, I traveled the world. These hands have seen more than just leather and thread!'",
    "'A good pair of boots can take you anywhere—trust me, I’ve walked a thousand miles in my own creations.'",
    "'The tavern’s my favorite place. A warm fire, a cold drink, and stories from travelers—what more could an old man need?'",
    "'I once made boots for a king. He said they were the most comfortable he’d ever worn. A proud moment, that was.'",
    "'Leather and ale have one thing in common—they both get better with age.'",
    "'I’ve seen adventurers come and go, but the ones with good boots always come back.'",
    "'The secret to a perfect boot? Patience, skill, and a little bit of magic—or so I like to say.'",
    "'I don’t just make boots; I make companions for the road. Every pair has a story waiting to be walked.'",
    "'The tavern’s where I hear the best tales. Some true, some not, but all worth a listen.'",
    "'If you ever need boots that can outlast a dragon’s breath, you know where to find me.'"
]

var vimarkos_one_liners = [
    "'Polis thrives because its people are its strength. Without them, even the grandest city would crumble.'",
    "'Leadership is not about power; it’s about responsibility. Every decision I make weighs heavily on my shoulders.'",
    "'The city’s prosperity comes at a cost. Not all debts are paid in gold.'",
    "'I’ve seen Polis grow from a humble town to what it is today. Its future depends on the choices we make now.'",
    "'Ambition drives this city, but unchecked, it can lead to ruin. Balance is everything.'",
    "'There are whispers in the shadows of Polis. Some say they’re just stories. I’m not so sure.'",
    "'A mayor’s duty is to protect his people, even from threats they cannot see.'",
    "'The world beyond Polis is vast and dangerous. We must remain vigilant.'",
    "'Every stone in this city hall was laid with purpose. Just like every decision I make.'",
    "'Trust is earned, not given. Remember that, especially in a city like Polis.'"
]

var vimarkos_distrust_one_liners = [
    "'Trust is fragile. Once broken, it’s not easily repaired.'",
    "'I hope your curiosity was worth the cost of my confidence in you.'",
    "'Actions have consequences. Remember that.'",
    "'I’ll assist you, but don’t mistake my cooperation for trust.'",
    "'You’ve proven yourself resourceful, but not honorable.'",
    "'I’ll keep an eye on you. Don’t make me regret it.'",
    "'Polis has no room for those who meddle in others’ affairs.'",
    "'You’ve made your choice. Now live with it.'",
    "'I’ll help you find Vesequella, but only because she matters to this city.'",
    "'Integrity is a rare commodity. Pity you’ve squandered yours.'"
]

var vimarkos_trust_one_liners = [
    "'You’ve proven yourself trustworthy. That’s no small feat.'",
    "'Integrity like yours is rare. Polis could use more of it.'",
    "'You’ve earned my respect. Don’t take that lightly.'",
    "'Your honesty speaks volumes. I won’t forget it.'",
    "'Polis thrives because of people like you.'",
    "'You’ve shown discretion and honor. A rare combination.'",
    "'I trust you’ll handle this matter with the same care you’ve shown today.'",
    "'You’ve done well. I’ll remember your service.'",
    "'Your actions have earned my gratitude. Thank you.'",
    "'Polis is safer in the hands of those who value integrity.'"
]

var pella_one_liners = [
    "'Have you heard the rumors about Yerkink? They say some people there have learned to fly! Can you imagine?'",
    "'Stathis, that bard? He packed up and headed east last I heard. Something about chasing a new muse.'",
    "'There’s a tree in the Senlin Forest—alive, I mean, really alive. It moves, they say, and whispers secrets to those who listen.'",
    "'If you ever go to the ice cave in Toiyun, keep an eye out. Folks say there’s a faint purple glow deep inside. No one knows what causes it.'",
    "'The mayor’s been acting strange lately. I wonder if it has something to do with those missing travelers.'",
    "'I can’t stand turnips. They’re the worst thing anyone ever decided to cook, if you ask me.'",
    "'There’s nothing better than a warm honey cake on a cold day. I’d trade a secret or two for one right now.'",
    "'I love listening to bards, but only the good ones. If they can’t play a decent tune, they shouldn’t bother.'",
    "'Dancing is my favorite way to pass the time. You should’ve seen me at the last festival—I outdanced everyone!'",
    "'I hate the rain. It ruins my hair and makes the tavern smell like wet dog.'"
]

var aris_one_liners = [
    "'The spyglass reveals much, but not all. Some truths are best left hidden, even from the keenest eye.'",
    "'The desert whispers its secrets to those who listen. Dost thou hear its voice?'",
    "'Magic is but a thread in the tapestry of the world. The spyglass shows thee the weave, but not the hand that guides it.'",
    "'Beware the illusions of the desert. What seems real may be but a mirage, and what seems false may hold the greatest truth.'",
    "'The Paran is not the only bond between earth and sky. There are other threads, older and more fragile.'",
    "'Tricks are but a shadow of true magic. The spyglass will show thee the light behind the veil.'",
    "'The Yerevand watch from above, but they are not the only ones who see. The desert has eyes of its own.'",
    "'The runes on the spyglass are ancient, their meaning known only to the Mystics. Treat it with care, for it is a piece of our history.'",
    "'The token thou gavest me was but a key. The spyglass is the door. What lies beyond is for thee to discover.'",
    "'Magic is a gift and a burden. Use the spyglass wisely, for not all who seek the truth are ready to bear it.'"
]

var aman_one_liners_before = [
    "'The Paran’s absence is a wound upon the earth. We must heal it, lest the desert itself turn against us.'",
    "'The Yerevand grow restless. Without the Paran, the bond between our peoples frays.'",
    "'The desert whispers of danger. The Paran’s light is needed now more than ever.'",
    "'The Paran is not a mere tool—it is a living thread, a symbol of unity. Its loss is a blow to us all.'",
    "'The runes upon the bottle grow dim. Without the Paran, their power fades.'",
    "'The Yerevand watch from above, but their patience is not infinite. The Paran must be restored.'",
    "'The desert’s secrets are many, but none so vital as the Paran. Seek it with haste.'",
    "'The Paran’s light once guided us. Now, we wander in shadow.'",
    "'The bond between earth and sky is fragile. Without the Paran, it may shatter.'"
]

var aman_one_liners_after = [
    "'The Paran’s light shines once more. The bond between earth and sky is whole again.'",
    "'The Yerevand sing thy praises, traveler. Thou hast done what many thought impossible.'",
    "'The runes upon the bottle glow with renewed vigor. The Paran’s return has awakened them.'",
    "'The desert’s whispers are kinder now. The Paran’s light soothes its restless spirit.'",
    "'Himar’s shadow fades in the light of the Paran. Thy deeds have undone his mischief.'",
    "'The Paran’s song is a balm to the earth. Yerkink owes thee a debt beyond measure.'",
    "'The Yerevand watch with gratitude. The bond between our peoples is stronger than ever.'",
    "'The Paran’s light guides us once more. Thy courage has restored our path.'",
    "'The desert’s heart beats anew. The Paran’s return has brought it peace.'",
    "'The Paran’s light is a beacon of hope. Thy actions have saved us all.'"
]

func ITEMS(): pass
func use_item(invn_idx, source=null, target=null):
    var item = CTX.inventory[invn_idx]
    var fn = GAME.item_skill_map[item["id"]]
    await IO.scroll_text(item.description)
    await IO.append_text("Do you want to use it?", false)

    var menu_idx = await IO.menu(["YES", "NO"])
    if menu_idx == 0:
        await fn.call(source, target)
        if item.consumable:
            CTX.inventory.remove_at(invn_idx)

var potion = {
    "id": ItemEnum.POTION,
    "name": "Potion",
    "description": "A medicinal potion",
    "consumable": true,
}

var torch = {
    "id": "torch",
    "name": "Torch",
    "description": "Chat GPT the description",
    "consumable": true,
}

var boots = {
    "id": "boots",
    "name": "Boots",
    "description": "A warm pair of boots",
}

var spyglass = {
    "id": "spyglass",
    "name": "Spyglass",
    "description": "A Mystic spyglass, said to reveal magic secrets.",
    "consumable": false,
}

var rope = {
    "id": "rope",
    "name": "Rope",
    "description": "A rope made with an unfamiliar material.",
    "consumable": false,
}

var bolt_scroll = {
    "id": "bolt_scroll",
    "name": "Bolt Scroll",
    "description": "A magical scroll for casting the Bolt spell.",
}

var heal_scroll = {
    "id": "heal_scroll",
    "name": "Heal Scroll",
    "description": "A magical scroll for casting the Heal spell.",
}

var fog_scroll = {
    "id": "fog_scroll",
    "name": "Fog Scroll",
    "description": "A magical scroll for creating a fog.",
}

var bright_scroll = {
    "id": "bright_scroll",
    "name": "Bright Scroll",
    "description": "A magical scroll for shining light"
}

var item_skill_map = {
    ItemEnum.POTION: SKILL.potion,
}

var item_map = {
    ItemEnum.POTION: potion,
    ItemEnum.TORCH: torch,
    ItemEnum.SPYGLASS: spyglass,
    ItemEnum.BOOTS: boots,
    ItemEnum.ROPE: rope,
    ItemEnum.BOLT_SCROLL: bolt_scroll,
    ItemEnum.HEAL_SCROLL: heal_scroll,
    ItemEnum.FOG_SCROLL: fog_scroll,
    ItemEnum.BRIGHT_SCROLL: bright_scroll,
}

func use_professor_letter():
    await IO.scroll_text("This is the letter from the professor of Baton to Vimarkos, mayor of Polis.")
    await IO.append_text("Do you want to read it?", false)
    var choice_idx = await IO.menu(["YES", "NO"])
    if choice_idx == 0:
        if not switches.baton_letter_opened:
            await IO.scroll_text("You open the envelope")
            switches.baton_letter_opened = true

        var letter_text_list = [
            "To the Esteemed Mayor of Polis,",
            "I hope this letter finds you well. I write to you with growing concern regarding one of my most promising students, Vesequella.",
            "Vesequella recently traveled to your city on an important mission, the details of which I am not at liberty to disclose. She was expected to return to Baton over a fortnight ago, yet I have received no word from her since her arrival in Polis.",
            "Given her dedication and sense of responsibility, it is highly unusual for her to remain out of contact for so long. I fear that something may have hindered her progress or, worse, put her in danger.",
            "I implore you, as a steward of Polis, to look into her whereabouts and ensure her safety. Any assistance you can provide would be invaluable, not only to me but to the academy as a whole.",
            "Should you require further information or wish to discuss this matter, please do not hesitate to send word. Vesequella’s well-being is of the utmost importance to us.",
            "Thank you for your attention to this urgent matter. I trust in your wisdom and hope for her swift and safe return.",
            "Yours sincerely,",
            "Magister Arcanor",
            "Professor of Arcane Studies",
            "The Athenaeum Arcanum"
        ]
        await proc_text_list(letter_text_list)
    elif choice_idx == 1:
        if not switches.baton_letter_opened:
            await IO.scroll_text("You decide to keep the envelope sealed.")

var professor_letter = {
    "id": "professor_letter",
    "name": "Professor's Letter",
    "description": "A letter from the professor to Vimarkos, mayor of Polis",
    "use_function": use_professor_letter,
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if not running:
        return

    if debug_inventory:
        for item_enum in debug_inventory:
            var item = item_map[item_enum]
            CTX.inventory.append(item.duplicate())
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
    IO.name_label.text = CTX.player.name
    IO.hero_stats_container.visible = true
    MUSIC.play_track(MUSIC.BATON)

    var intro_scene_8 = [
        "\"Well then, %s, it is a pleasure to welcome you." % [player_name],
        "After today’s session, I would like a brief word with you.",
        "It won’t take long.",
        "Now, let us continue…\""
    ]
    await proc_text_list(intro_scene_8)


func BATON_ROOMS(): pass
func baton_professor_room():
    var menu_idx
    var invn_idx
    var move_idx
    var intro_text =  "You step into the professor’s room, and the air immediately feels different—thick with the scent of old parchment and arcane herbs."
    await IO.scroll_text(intro_text)

    while true:
        var text =  "The professor is sitting at his desk, examining tomes and writing notes."
        menu_idx = await IO.menu(["TALK", "ITEM", "LEAVE"], text)

        if menu_idx == 0:
            if not switches.baton_professor_quest_received:
                switches.baton_professor_quest_received = true
                await proc_text_list([
                    "\"Hello %s, I'm glad you stopped by." % [CTX.player.name],
                    "I have a request, please take this letter to Vimarkos in Polis.",
                    "You can reach Polis by traveling west when you leave the town.\"",
                ])
                await IO.scroll_text("The professor hands you a letter.")
                CTX.inventory.append(professor_letter.duplicate())
            elif not switches.baton_professor_quest_completed:
                if switches.baton_letter_opened and professor_letter in CTX.inventory:
                    await IO.scroll_text("'I see, you decided to read the letter. I suppose it was inevitible for you to discover. Please, still deliver the letter to Vimarkos.'")
                    await IO.scroll_text("'although...'")
                    await IO.append_text("'I don't believe he will be pleased that you opened his letter.'")
                else:
                    await IO.scroll_text("The professor raises his eyes from the tomes.")
                    await IO.scroll_text("\"Please, deliver the letter and let me know what Vimarkos has to say.")
            elif not switches.baton_professor_quest_rewarded:
                pass
            else:
                await IO.scroll_text("\"Hello %s, good to see you.\"" % [CTX.player.name])
        elif menu_idx == 1:
            invn_idx = await IO.show_inventory()
            if invn_idx >= 0:
                var item = CTX.inventory[invn_idx]
                if item.use_function:
                    await item.use_function.call()
                else:
                    await IO.scroll_text(item.description)
        elif menu_idx == 2:
            await IO.scroll_text("You leave the academy.")
            baton_town_room()
            return

func baton_town_room():
    if MUSIC.current_track != MUSIC.BATON:
        MUSIC.play_track(MUSIC.BATON)

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
            MUSIC.stop()
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
            await baton_shop.run()
        elif menu_idx == 1:
            invn_idx = await IO.show_inventory()
            if invn_idx >= 0:
                await IO.scroll_text(CTX.inventory[invn_idx].description)
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

            if switches.baton_caligarius_introduction:
                people[0] = names.CALIGARIUS
            if switches.baton_lumarius_introduction:
                people[1] = names.LUMARIUS

            talk_idx = await IO.menu(people, "Who do you want to talk to?")

            # Caligarius
            if talk_idx == 0:
                if not switches.baton_caligarius_introduction:
                    switches.baton_caligarius_introduction = true
                    await IO.scroll_text("An elderly man with weathered hands and a kind smile greets you. His workshop is filled with leather, tools, and rows of finely crafted boots.")
                    await IO.scroll_text("'Welcome, traveler. I am Caligarius, a humble boot-maker. How may I assist you today?'", false)
                else:
                    await IO.scroll_text("Caligarius greets you with a warm smile", false)

                while true:
                    menu_idx = await IO.menu(["TALK", "ITEM", "CANCEL"])
                    if menu_idx == 0:
                        var boot_talk = caligarius_one_liners.pick_random()
                        await IO.scroll_text(boot_talk, false)
                    elif menu_idx == 1:
                        invn_idx = await IO.show_inventory()
                        await IO.scroll_text("Some debug invn text", false)
                    elif menu_idx == 2:
                        break

            # Lumarius
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

func POLIS_ROOMS(): pass
func polis_city_room():
    if MUSIC.current_track != MUSIC.POLIS:
        MUSIC.play_track(MUSIC.POLIS)

    var menu_idx

    while true:
        var text = "Polis greets you with bustling streets and glinting spires, a city of boundless ambition where the air hums with opportunity—and the faint whisper of something darker lurking beneath."
        menu_idx = await IO.menu(["CITY HALL", "STORE", "TAVERN", "LEAVE"], text)

        if menu_idx == 0:
            await IO.scroll_text("You enter the city hall")
            polis_city_hall_room()
            return
        elif menu_idx == 1:
            await IO.scroll_text("You enter the store")
            polis_store_room()
            return
        elif menu_idx == 2:
            await IO.scroll_text("You enter the tavern")
            polis_tavern_room()
            return
        elif menu_idx == 3:
            MUSIC.stop()
            await IO.scroll_text("You leave the city")
            polis_world_node.run()
            return

func polis_city_hall_room():
    var menu_idx
    var invn_idx
    var text

    var intro_text = "The grand hall is a cavernous space of polished stone, with towering banners, echoing footsteps, and a sense of weighty decisions hanging in the air."
    await IO.scroll_text(intro_text)
    while true:
        text = "A middle-aged man with sharp features and a commanding presence, his serious demeanor and finely tailored robes speak of a life dedicated to leadership and responsibility."
        if switches.polis_vimarkos_introduction:
            text = "Vimarkos, the mayor of Polis, carries himself with the gravitas of a seasoned leader, his sharp eyes and measured words revealing both his wisdom and the weight of his duties."

        menu_idx = await IO.menu(["TALK", "ITEM", "LEAVE"], text)

        if menu_idx == 0:
            if not switches.polis_vimarkos_introduction:
                text = "'I am Vimarkos, Mayor of Polis. Speak plainly, for time is a luxury I cannot afford to waste.'"
                switches.polis_vimarkos_introduction = true
                await IO.scroll_text(text)
            else:
                text = vimarkos_one_liners.pick_random()
                if switches.polis_vimarkos_distrust:
                    text = vimarkos_distrust_one_liners.pick_random()
                elif switches.polis_vimarkos_trust:
                    text = vimarkos_trust_one_liners.pick_random()
                await IO.scroll_text(text)
        elif menu_idx == 1:
            invn_idx = await IO.show_inventory()
            if invn_idx >= 0:
                var item = CTX.inventory[invn_idx]
                if item.id == "professor_letter":
                    await IO.scroll_text("You hand Vimarkos the professor's letter")
                    if switches.baton_letter_opened:
                        await IO.scroll_text("Vimarkos takes the opened letter from your hands, his eyes narrowing as he reads the broken seal. His jaw tightens, and for a moment, the room feels colder.")
                        await IO.scroll_text("'You had no right to open this,' he says, his voice low and sharp. 'This is a breach of trust that I do not take lightly.'")
                        await IO.scroll_text("He pauses, studying you for a moment, then exhales slowly.")
                        await IO.scroll_text("'But given the circumstances, I understand why you felt compelled to do so. Vesequella’s disappearance is troubling, and time is of the essence.'")
                        await IO.scroll_text("'I cannot offer you a reward for this... indiscretion,' he continues, his tone firm. 'However, I will tell you this: Vesequella was last seen in the company of a bard named Stathis. He frequents the taverns near the eastern market. If anyone knows what happened to her, it would be him.'")
                        await IO.scroll_text("Vimarkos folds the letter and places it on his desk. 'Now, if you’ll excuse me, I have a city to run.'")
                    else:
                        await IO.scroll_text("Vimarkos takes the letter from your hands, his expression softening as he notices the unbroken seal. He nods approvingly.")
                        await IO.scroll_text("'You’ve done well to deliver this unopened,' he says, his tone appreciative. 'Integrity is a rare quality, and it deserves to be rewarded.'")
                        await IO.scroll_text("He reaches into a drawer and retrieves a small pouch, placing it on the desk in front of you. 'Take this as a token of my gratitude. It’s not much, but it’s the least I can do.'")
                        await IO.scroll_text("'As for Vesequella,' he continues, his voice growing serious, 'she was last seen in the company of a bard named Stathis. He frequents the taverns near the eastern market. If anyone knows what happened to her, it would be him.'")
                        await IO.scroll_text("Vimarkos leans back in his chair, his gaze thoughtful. 'I trust you’ll follow this lead with the same discretion you’ve shown today.'")
                elif item.use_function:
                    await item.use_function.call()
                else:
                    await IO.scroll_text(item.description)
        elif menu_idx == 2:
            polis_city_room()
            return

func polis_store_room():
    var menu_idx
    var invn_idx
    var shop_idx

    while true:
        var text = "The shop is a cozy haven of warmth, its walls lined with thick fur cloaks, sturdy boots, and woolen garments, all crafted to brave the harshest winters."
        menu_idx = await IO.menu(["BUY", "SELL", "LEAVE"], text)

        if menu_idx == 0:
            await polis_shop.run()
        if menu_idx == 1:
            invn_idx = await IO.show_inventory()
            if invn_idx >= 0:
                await IO.scroll_text(CTX.inventory[invn_idx].description)
        elif menu_idx == 2:
            await IO.scroll_text("You leave the shop.")
            polis_city_room()
            return


func polis_tavern_room():
    var menu_idx
    var invn_idx
    var talk_idx
    var text

    while true:
        text = "The tavern is a dimly lit den of murmured conversations and clinking glasses, where weary travelers and shadowed figures alike seek refuge from the city’s relentless pace."
        menu_idx = await IO.menu(["TALK", "LEAVE"], text)

        if menu_idx == 0:
            var people = ["MYSTIC", "WOMAN", "CANCEL"]

            if switches.polis_himar_introduction:
                people[0] = names.HIMAR
            if switches.polis_pella_introduction:
                people[1] = names.PELLA

            if switches.polis_himar_vanish:
                people.pop_front()

            talk_idx = await IO.menu(people, "Who do you want to talk to?")
            var person = people[talk_idx]

            if person in ["MYSTIC", "HIMAR"]:
                if not switches.polis_himar_introduction:
                    switches.polis_himar_introduction = true
                    await IO.scroll_text("'Hark, a wanderer approaches,' intones the robed figure, his voice low and melodic, his eyes glinting with mischief above the cloth masking his mouth.")
                    await IO.scroll_text("'I am Himar, keeper of secrets and games...'")
                    await IO.append_text("Dost thou dare to test thy fortune?'", false)
                else:
                    await IO.scroll_text("Himar’s eyes crinkle with recognition as you approach, the cloth over his mouth shifting slightly as if hiding a smile.")
                    await IO.scroll_text("'Ah, ’tis thee again, wanderer,' he says, his voice smooth and melodic.")
                    await IO.append_text("'What brings thee to my humble corner of the world this day?'")
                    await IO.append_text("'Dost thou seek another dance with chance?'", false)
                menu_idx = await IO.menu(["YES", "NO"])
                if menu_idx == 0:
                    if spyglass in CTX.inventory:
                        await IO.scroll_text("As Himar begins shuffling the cups, you discreetly raise the mystic spyglass to your eye. Through its lens, the glowing pebble’s movement becomes clear, and you see the subtle magic Himar uses to manipulate it.")
                        await IO.scroll_text("When Himar stops and gestures for you to choose, you confidently point to the correct cup. His eyes widen slightly above the cloth, a flicker of panic breaking through his usual composure.")
                        await IO.scroll_text("'Thou... thou hast a keen eye, wanderer,' he stammers, his voice losing its usual smoothness. 'Few can see through the veil of illusion. But this... this cannot be!'")
                        await IO.scroll_text("Before you can react, Himar mutters an incantation under his breath.")
                        await IO.scroll_text("On the ground where he stood lies a coiled rope, glowing faintly with a soft, otherworldly light. You pick it up, feeling a strange warmth emanating from it.")
                        CTX.inventory.append(rope)
                        SFX.play_track(SFX.PICKUP)
                        await IO.scroll_text("You pick up the rope.")
                        switches.polis_himar_vanish = true
                    else:
                        await IO.scroll_text("You place your bet and point to a cup. Himar lifts it with a flourish, revealing... nothing but empty air. His eyes glimmer with mischief above the cloth covering his mouth.")
                        await IO.scroll_text("'Fortune favors not the bold this day,' he says, his voice tinged with mock sympathy. 'Perchance thou shalt fare better anon.'")
                else:
                    await IO.scroll_text("Himar tilts his head slightly, the cloth shifting as if hiding a smirk. 'A prudent choice, wanderer. Not all are prepared to dance with chance. Shouldst thou change thy mind, I shall be here.'")
            elif person in ["WOMAN", "PELLA"]:
                if not switches.polis_pella_introduction:
                    switches.polis_pella_introduction = true
                    await IO.scroll_text("Sitting at a corner table with a half-empty mug of ale is a woman with a mischievous glint in her eye. Her auburn hair is tied back loosely, and her sleeves are rolled up as if she’s been here for hours.")
                    await IO.scroll_text("She notices you looking her way and waves you over with a grin. 'Come, sit! I’m Pella, and if you’re looking for good company—or a good story—you’ve come to the right place.'")
                else:
                    text = pella_one_liners.pick_random()
                    await IO.scroll_text(text)
            elif person == "CANCEL":
                pass
        elif menu_idx == 1:
            await IO.scroll_text("You leave the tavern.")
            polis_city_room()
            return

func YERKINK_ROOMS(): pass
func yerkink_village_room():
    if MUSIC.current_track != MUSIC.YERKINK:
        MUSIC.play_track(MUSIC.YERKINK)

    var menu_idx
    var invn_idx

    while true:
        var text = "Yerkink rises from the desert sands, its Mystics moving like shadows beneath the sun, their faces wrapped in cloth, while the towering bottle at its center stands silent and still, its runes faintly glowing."
        if switches.yerkink_rope_restored:
            text = "Yerkink rises from the desert sands, its Mystics moving like shadows beneath the sun, their faces wrapped in cloth, as the glowing magic rope stretches skyward, a bridge to the city above the clouds."

        menu_idx = await IO.menu(["BOTTLE", "STORE", "TAVERN", "LEAVE"], text)

        if menu_idx == 0:
            await IO.scroll_text("You approach the bottle.")
            yerkink_bottle_room()
            return
        elif menu_idx == 1:
            await IO.scroll_text("You enter the store.")
            yerkink_store_room()
            return
        elif menu_idx == 2:
            await IO.scroll_text("You enter the tavern.")
            yerkink_tavern_room()
            return
        elif menu_idx == 3:
            MUSIC.stop()
            await IO.scroll_text("You leave the village.")
            yerkink_world_node.run()
            return

func yerkink_bottle_room():
    var menu_idx
    var invn_idx

    while true:
        var text = "The bottle stands before you, its smooth surface cool to the touch and etched with glowing runes that pulse faintly, like a heartbeat. The open top yawns wide, empty and silent, as if yearning for something lost."
        if switches.yerkink_rope_restored:
            text = "The bottle thrums with a low, resonant energy, its runes blazing with light as the magic rope spirals upward from its open top, a luminous thread weaving into the heavens, alive with power."

        menu_idx = await IO.menu(["ITEMS", "LEAVE"], text)
        if menu_idx == 0:
            invn_idx = await IO.show_inventory()
            if invn_idx >= 0:
                var item = CTX.inventory[invn_idx]
                if item == rope:
                    await IO.scroll_text("You restored the rope!")
                    CTX.inventory.remove_at(invn_idx)
                    switches.yerkink_rope_restored = true
                elif item.use_function:
                    await item.use_function.call()
                else:
                    await IO.scroll_text(item.description)
        elif menu_idx == 1:
            await IO.scroll_text("You step away from the bottle")
            yerkink_village_room()
            return

func yerkink_store_room():
    var menu_idx
    var invn_idx
    var shop_idx

    while true:
        var text = "The shop is a dim, sand-scented haven, its walls lined with shelves of ancient scrolls, their edges glowing faintly with runes that whisper of forgotten secrets."
        menu_idx = await IO.menu(["BUY", "SELL", "LEAVE"], text)

        if menu_idx == 0:
            await yerkink_shop.run()
        if menu_idx == 1:
            invn_idx = await IO.show_inventory()
            if invn_idx >= 0:
                await IO.scroll_text(CTX.inventory[invn_idx])
        elif menu_idx == 2:
            await IO.scroll_text("You leave the shop.")
            yerkink_village_room()
            return


func yerkink_tavern_room():
    var menu_idx
    var invn_idx
    var talk_idx
    var text

    while true:
        text = "The tavern greets you with the warm glow of lanterns, the hum of murmured conversations, and the rich scent of spiced wine, a haven from the desert’s relentless sun."
        menu_idx = await IO.menu(["TALK", "LEAVE"], text)

        if menu_idx == 0:
            var people = ["MYSTIC 1", "MYSTIC 2", "CANCEL"]

            if switches.yerkink_aman_introduction:
                people[0] = names.AMAN
            if switches.yerkink_aris_introduction:
                people[1] = names.ARIS

            talk_idx = await IO.menu(people, "Who do you want to talk to?")
            var person = people[talk_idx]

            if person in ["MYSTIC 1", "AMAN"]:
                if not switches.yerkink_aman_introduction:
                    switches.yerkink_aman_introduction = true
                    await IO.scroll_text("The Mystic stands tall and composed, her robes flowing like liquid shadow against the golden sands. Her face is framed by a tightly wrapped turban, leaving only her piercing eyes visible, sharp and unwavering. A faint glow emanates from the runes embroidered on her sleeves, hinting at her deep connection to the mystical arts.")
                    await IO.scroll_text("'I am Aman,' she intones, her voice steady and resonant. 'Ambassador to the Yerevand and guardian of the Paran. Its absence doth weigh heavily upon us all. Pray, traveler, what brings thee to Yerkink?'", false)
                else:
                    await IO.scroll_text("'Hail traveler. How may I help you?'", false)
                    await IO.scroll_text("Aman’s piercing eyes meet yours as you approach, her expression as composed as ever.")
                    await IO.scroll_text("'Thou returnest, traveler. The desert’s winds have guided thee back to Yerkink. What news dost thou bring of the Paran?'", false)

                while true:
                    menu_idx = await IO.menu(["TALK", "ITEM", "CANCEL"])
                    if menu_idx == 0:
                        if not switches.yerkink_rope_restored:
                            text = aman_one_liners_before.pick_random()
                        else:
                            text = aman_one_liners_after.pick_random()
                        await IO.scroll_text(text, false)
                    elif menu_idx == 1:
                        invn_idx = await IO.show_inventory()
                        await IO.scroll_text("Some debug invn text", false)
                    elif menu_idx == 2:
                        break

            elif person in ["MYSTIC 2", "ARIS"]:
                if not switches.yerkink_aris_introduction:
                    switches.yerkink_aris_introduction = true
                    await IO.scroll_text("A middle-aged Mystic sits at a corner table, his robes dusty from the desert winds. His face is weathered but kind, and his eyes gleam with a quiet wisdom. A small, intricately carved spyglass rests on the table before him.")

                if not switches.yerkink_aris_given_token:
                    await IO.scroll_text("The Mystic looks up as you approach, his voice low and measured. 'Greetings, traveler. I am Aris. If thou seekest the truth hidden from mortal eyes, I can aid thee—but all things come at a cost.'")
                    await IO.append_text("'Hast thou a token to offer?'", false)
                    var choice_idx = await IO.menu(["YES", "NO"])
                    if choice_idx == 0:
                        if true:
                            switches.yerkink_aris_given_token = true
                            await IO.scroll_text("Aris nods approvingly as you hand over the token. 'A fair exchange,' he says, sliding the spyglass across the table. 'This artifact shall reveal what lies beyond the veil. Use it wisely, for not all truths are meant to be seen.'")
                            SFX.play_track(SFX.PICKUP)
                            await IO.scroll_text("Aris hands you the spyglass")
                            CTX.inventory.append(spyglass.duplicate())
                        else:
                            await IO.scroll_text("Aris sighs softly, his expression sympathetic.")
                            await IO.scroll_text("'Without a token, I cannot part with the spyglass. Seek one out, and return when thou art ready. The desert is generous to those who listen to its whispers.'")
                    else:
                        await IO.scroll_text("Aris tilts his head slightly, his expression unreadable. 'As thou wishest, traveler. But remember: the desert guards its secrets closely, and not all paths are open to those who hesitate.'")
                else:
                    text = aris_one_liners.pick_random()
                    await IO.scroll_text(text)
            elif person == "CANCEL":
                pass
        elif menu_idx == 1:
            await IO.scroll_text("You leave the tavern.")
            yerkink_village_room()
            return
