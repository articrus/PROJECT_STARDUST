extends CharacterBody2D

@onready var animation_node = $SimpleEnemy
@onready var chase_timer = $ChaseTimer
@export var texture: Texture
@export var encounter: Encounter_Data
# Variables
var target
var is_chasing: bool = false

func _ready() -> void:
	animation_node.sprite_sheet = texture
	animation_node.enemy_state = enums.ENEMY_STATE.IDLE

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


func _on_area_2d_area_entered(_area: Area2D) -> void:
	Signalbus.trigger_encounter.emit(encounter)
