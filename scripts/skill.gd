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
        SFX.play_track(SFX.HIT)

        if target == CTX.player:
            IO.hero_stats_changed.emit()
            VFX.shake_hero_stats()
        else:
            VFX.shake_window_message()

        var dmg = calc_dmg(source, target)
        if target.defend:
            dmg /= 2
        await IO.append_text("and hits for %d damage!" % [dmg])
        target.hp -= dmg
    else:
        SFX.play_track(SFX.MISS)
        await IO.append_text("but misses!")

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

func rat_eat_cheese(source, _target):
    SFX.play_track(SFX.PICKUP)
    VFX.flash(Color.WHITE)
    await IO.scroll_text("%s eats some cheese" % [source.name])
    var heal = rng.randi_range(1,2)
    source.hp += heal
    await IO.append_text("%s recovers %d HP!" % [source.name, heal])

func rat_nibble(source, target):
    await IO.scroll_text("%s nibbles at your feet..." % [source.name])
    if hit_check(source, target):
        SFX.play_track(SFX.HIT)
        if target == CTX.player:
            IO.hero_stats_changed.emit()
            VFX.shake_hero_stats()
        var dmg = 1
        target.hp -= dmg
        await IO.append_text("and does %d damage!" % [dmg])
    else:
        SFX.play_track(SFX.MISS)
        await IO.append_text("but does no damage.")


func trip(source, _target):
    await IO.scroll_text("%s loses balance and trips!" % [source.name])
    var dmg = rng.randi_range(1,3)
    source.hp -= dmg
    await IO.append_text("%s takes %d damage!" % [source.name, dmg])

func pulses_eerily(source, target):
    if not source.pulse:
        await IO.scroll_text("%s pulses eerily..." % [source.name])
        source.pulse = true
    else:
        await IO.scroll_text("%s errupts in a slimey explosion!" % [source.name])
        source.hp -= 5
        await IO.append_text("%s takes 5 damage" % [source.name])
        target.hp -= 5
        await IO.append_text("%s takes 5 damage" % [target.name])

        if target == CTX.player:
            IO.hero_stats_changed.emit()
            VFX.shake_hero_stats()

func bolt(source, target):
    await IO.scroll_text("%s tries to cast a spell..." % [source.name])

    if source.sp >= 2:
        VFX.flash(Color.YELLOW)
        SFX.play_track(SFX.PICKUP)
        await IO.append_text("and casts the Bolt spell")
        source.sp -= 2
        var dmg = 2 + rng.randi_range(0, 3)
        target.hp -= dmg
        SFX.play_track(SFX.HIT)
        if target == CTX.player:
            IO.hero_stats_changed.emit()
            VFX.shake_hero_stats()
        else:
            VFX.shake_window_message()

        await IO.append_text("%s takes %d damage" % [target.name, dmg])
    else:
        SFX.play_track(SFX.MISS)
        await IO.append_text("but doesn't have enough energy")



func fizzle(source, _target):
    await IO.scroll_text("%s tries to cast a spell..." % [source.name])
    SFX.play_track(SFX.MISS)
    await IO.append_text("but fails to remember how.")

func inventory(source, _target):
    var idx = await IO.show_inventory()
    await IO.scroll_text("%s used %s" % [source.name, CTX.inventory[idx]])
