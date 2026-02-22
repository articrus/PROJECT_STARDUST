extends BoxContainer

@onready var counter = $Counter
@onready var counter2 = $Counter2

func _ready() -> void:
	counter.visible = false
	counter2.visible = false

func _toggle_additional_counters(count: int) -> void:
	counter.visible = false
	counter2.visible = false
	match count:
		2:
			counter.visible = true
		3:
			counter.visible = true
			counter2.visible = true
