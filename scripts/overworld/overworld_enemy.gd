extends CharacterBody2D

@onready var animation_node = $SimpleEnemy
@onready var chase_timer = $ChaseTimer
# Variables
var target
var is_chasing: bool = false

func _ready() -> void:
	pass

# Move around or stay still
func _physics_process(_delta: float) -> void:
	if is_chasing:
		pass
		# Move towards target
	move_and_slide()

# Get the player target
func _on_sight_line_body_entered(body: Node2D) -> void:
	target = body
	is_chasing = true
	chase_timer.start()

# Stop chasing the player
func _on_chase_timer_timeout() -> void:
	is_chasing = false
