extends Node

var rng = RandomNumberGenerator.new()

func hit_check(source, target):
    var source_chance = CTX.dice_roll(source.dex) + 1
    var target_chance = CTX.dice_roll(target.agi) / 2

    return source_chance > target_chance

func agi_check(source, target):
    var source_chance = CTX.dice_roll(source.agi)
    var target_chance = CTX.dice_roll(target.agi)

    return source_chance > target_chance

func calc_dmg(source, target):
    # Does a minimum of 1 damage
    # If damage is greater than 1, make it vary 20%
    var base = max(1, source.atk - target.def)
    if base == 1:
        return 1

    var variance = .2 * base
    return rng.randi_range(max(1, floor(base-variance)), ceil(base+variance))

func attack(source, target):
    await IO.scroll_text("%s attacks %s ..." % [source.name, target.name])
    if hit_check(source, target):
        var dmg = calc_dmg(source, target)
        if target.defend:
            dmg /= 2
        await IO.append_text("and hits for %d damage!" % [dmg])
        target.hp -= dmg
    else:
        await IO.append_text("but misses!")

    if target == CTX.player:
        IO.hero_stats_changed.emit()

func defend(source, _target):
    await IO.scroll_text(source.name + " embraces for an attack...")
    source.defend = true

func escape(source, target):
    #TODO need a way to communicate escape to the battle code
    #maybe hardcode in battle.gd
    await IO.scroll_text("%s tries to run away..." % [source.name])

    if agi_check(source, target):
        await IO.append_text("and you escape!")
        return true
    else:
        await IO.append_text("but the %s blocks your path!" % [target.name])

    return false

func trip(source, _target):
    await IO.scroll_text("%s loses balance and trips!" % [source.name])
    var dmg = rng.randi_range(1,3)
    await IO.append_text("%s takes %d damage!" % [source.name, dmg])

func pulses_eerily(source, _target):
    await IO.scroll_text("%s pulses eerily..." % [source.name])

func inventory(source, _target):
    var idx = await IO.show_inventory()
    await IO.scroll_text("%s used %s" % [source.name, CTX.inventory[idx]])
