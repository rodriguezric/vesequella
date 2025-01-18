extends Node
@onready var timer: Timer = $Timer

func _ready() -> void:
    test_io_text_lines_increase_instead_of_cutitng_off()

func test_io_text_lines_increase_instead_of_cutitng_off():
    #
    timer.timeout.connect(simulate_advance_text)
    timer.start(0.01)
    var texts = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    await IO.scroll_text(texts[0])

    for text in texts.slice(1):
        await IO.append_text(text)

    assert(IO.label.lines_skipped == 1)

    await IO.append_text("11")
    assert(IO.label.lines_skipped == 2)
    timer.stop()

func simulate_advance_text():
    IO.advance_text()
