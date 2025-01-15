extends Node
# Text dialog should describe the battle
# Window showing player stats
# List menu for player options

var rng = RandomNumberGenerator.new()

signal complete_sig

func run(enemy_name):
    var enemy = CTX.create_enemy(enemy_name)
    await IO.scroll_text(enemy.description + " approaches.")
    IO._on_hero_stats_changed()
    IO.hero_stats_container.visible = true

    var choice_idx
    var player_skills = [SKILL.attack, SKILL.inventory, SKILL.defend, SKILL.escape]
    var player_skill
    var enemy_skill
    var item

    var res_dict = {}

    while true:
        CTX.player.defend = false
        enemy.defend = false
        await IO.append_text("What will you do?", false)
        choice_idx = await IO.menu(["ATTACK", "ITEM", "DEFEND", "RUN"])

        # handle item selection
        if choice_idx == 1:
            var item_idx = -1
            while item_idx == -1:
                item_idx = await IO.show_inventory()
            item = CTX.inventory[item_idx]

        if item:
            print(item)

        player_skill = player_skills[choice_idx]
        enemy_skill = enemy.skills.pick_random()

        var actors = [
            [enemy, enemy_skill],
            [CTX.player, player_skill],
        ]

        var player_first = SKILL.agi_check(CTX.player, enemy)
        if player_first or player_skill == SKILL.defend:
            actors.reverse()

        for x_ in 2:
            # actor in this case is a tuple: [entity, battle_function]
            # we will call the source's function
            var source = actors[0][0]
            var target = actors[1][0]
            var skill = actors[0][1]

            var res = await skill.call(source, target)
            if skill == SKILL.escape and res:
                break

            actors.reverse()

        if enemy.hp <= 0:
            await IO.append_text("You defeated the " + enemy.name)
            await IO.append_text("Good job, I guess.")
            break

    complete_sig.emit(res_dict)
