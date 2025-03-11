extends Node

var rng = RandomNumberGenerator.new()
var inventory = []
var tokens = 10

# Player Data
var player = {
    "name": "",
    "hp": 10,
    "sp": 5,
    "atk": 5,
    "def": 2,
    "dex": 2,
    "agi": 2,
}

# Enemy Models
func ENEMIES(): pass

var rat = {
    "name": "Rat",
    "description": "A vile Rat",
    "hp": 8,
    "sp": 5,
    "atk": 2,
    "def": 2,
    "dex": 3,
    "agi": 5,
    "skills": [
        SKILL.attack,
        SKILL.rat_eat_cheese,
        SKILL.rat_nibble,
    ]
}

var slime = {
    "name": "Slime",
    "description": "A green Slime",
    "hp": 6,
    "sp": 5,
    "atk": 3,
    "def": 1,
    "dex": 2,
    "agi": 3,
    "skills": [
        SKILL.attack,
        SKILL.pulses_eerily,
    ]
}

var squishy_slime = {
    "name": "Slime",
    "description": "A squishy, green Slime",
    "hp": 4,
    "sp": 5,
    "atk": 2,
    "def": 1,
    "dex": 1,
    "agi": 4,
    "skills": [
        SKILL.attack,
        SKILL.pulses_eerily,
    ]
}

var goblin = {
    "name": "Goblin",
    "description": "A Goblin",
    "hp": 12,
    "sp": 5,
    "atk": 4,
    "def": 3,
    "dex": 3,
    "agi": 6,
    "skills": [
        SKILL.attack,
        SKILL.trip,
    ]
}

var lost_sorcerer = {
    "name": "Tattered Sorcerer",
    "description": "A tattered Sorcerer",
    "hp": 10,
    "sp": 5,
    "atk": 2,
    "def": 3,
    "dex": 3,
    "agi": 3,
    "skills": [
        #SKILL.attack,
        SKILL.bolt,
        #SKILL.fizzle,
    ]
}

enum Enemy {
    RAT,
    SLIME,
    SQUISHY_SLIME,
    GOBLIN,
    LOST_SORCERER,
}

# map for getting a copy an instance of an enemy model
var enemy_map = {
    Enemy.RAT: rat,
    Enemy.SLIME: slime,
    Enemy.SQUISHY_SLIME: squishy_slime,
    Enemy.GOBLIN: goblin,
    Enemy.LOST_SORCERER: lost_sorcerer,
}

func create_enemy(enemy: Enemy):
    return enemy_map[enemy].duplicate()

func dice_roll(sides, modifier=0):
    # Roll 1d{sides} + modifier
    return rng.randi_range(1, sides) + modifier

func ITEMS(): pass

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
    PROFESSOR_LETTER,
}

func use_item(invn_idx, source=null, target=null):
    var item = CTX.inventory[invn_idx]
    await IO.scroll_text(item.description)
    if item["id"] in CTX.item_skill_map:
        var fn = CTX.item_skill_map[item["id"]]
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
    "id": ItemEnum.TORCH,
    "name": "Torch",
    "description": "Chat GPT the description",
    "consumable": true,
}

var boots = {
    "id": ItemEnum.BOOTS,
    "name": "Boots",
    "description": "A warm pair of boots",
    "consumable": false,
}

var spyglass = {
    "id": ItemEnum.SPYGLASS,
    "name": "Spyglass",
    "description": "A Mystic spyglass, said to reveal magic secrets.",
    "consumable": false,
}

var rope = {
    "id": ItemEnum.ROPE,
    "name": "Rope",
    "description": "A rope made with an unfamiliar material.",
    "consumable": false,
}

var bolt_scroll = {
    "id": ItemEnum.BOLT_SCROLL,
    "name": "Bolt Scroll",
    "description": "A magical scroll for casting the Bolt spell.",
    "consumable": false,
}

var heal_scroll = {
    "id": ItemEnum.HEAL_SCROLL,
    "name": "Heal Scroll",
    "description": "A magical scroll for casting the Heal spell.",
    "consumable": false,
}

var fog_scroll = {
    "id": ItemEnum.FOG_SCROLL,
    "name": "Fog Scroll",
    "description": "A magical scroll for creating a fog.",
    "consumable": false,
}

var bright_scroll = {
    "id": ItemEnum.BRIGHT_SCROLL,
    "name": "Bright Scroll",
    "description": "A magical scroll for shining light",
    "consumable": false,
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
        if not SWITCHES.baton_letter_opened:
            await IO.scroll_text("You open the envelope")
            SWITCHES.baton_letter_opened = true

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
        await IO.proc_text_list(letter_text_list)
    elif choice_idx == 1:
        if not SWITCHES.baton_letter_opened:
            await IO.scroll_text("You decide to keep the envelope sealed.")

var professor_letter = {
    "id": ItemEnum.PROFESSOR_LETTER,
    "name": "Professor's Letter",
    "description": "A letter from the professor to Vimarkos, mayor of Polis",
    "consumable": false,
}

var item_skill_map = {
    ItemEnum.POTION: SKILL.potion,
    ItemEnum.PROFESSOR_LETTER: use_professor_letter,
}
