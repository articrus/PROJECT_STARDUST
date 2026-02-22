extends Node2D
# Written By: Gianni Coladonato
# Date Created / Modified : 04-10-2025 / 12-02-2026
# Scene Components
@onready var animation_node = $PlayerAnimationNode
@onready var char_stats = $Character
@onready var actor_ui = $ActorUI
@onready var essentials = $CharacterEssentials
# Variables
@export var char_moving : bool :
	get:
		return animation_node.is_moving
	set(new_value):
		if animation_node:
			animation_node.is_moving = new_value
@export var current_state : enums.PLAYER_CONTROL_STATUS = enums.PLAYER_CONTROL_STATUS.FOLLOWING
# Other Data
@export var player_type: enums.PLAYERS
# Other Vars
var pending_data
# Follower variables
var ACCELERATION: float
var FRICTION: float
var target_pos: Vector2
var look_dir: Vector2
var last_look_dir_y: float = 1
var is_init: bool = false #Prevent physics from running too early

func _ready() -> void:
	char_stats._load_player_data(pending_data)
	char_stats.hp_changed.connect(actor_ui._update_hp_bar)
	actor_ui._inital_values(char_stats)
	actor_ui.visible = false
	is_init = true
	char_stats.animation_node = animation_node
	actor_ui.buff_container._set_character_tokens(true)
	char_stats.buff_container = actor_ui.buff_container

func _physics_process(delta) -> void:
	if !is_init:
		return
	var prev = global_position
	# Smoothed movement
	var factor = ACCELERATION if char_moving else FRICTION
	var weight = 1.0 - exp(-factor * delta)
	global_position = global_position.lerp(target_pos, weight)
	
	# Update facing (Only if received valid direction)
	if look_dir != Vector2.ZERO:
		if look_dir.y != 0:
			last_look_dir_y = look_dir.y
	var moved = global_position.distance_to(prev) > 0.05
	if moved and look_dir.x != 0:
		animation_node.sprite.flip_h = look_dir.x < 0

func update_follow_target(pos: Vector2, moving: bool, dir: Vector2):
	target_pos = pos
	char_moving = moving
	if dir != Vector2.ZERO:
		look_dir = dir

func _enter_battle():
	current_state = enums.PLAYER_CONTROL_STATUS.BATTLE
	actor_ui.visible = true
	animation_node._enter_battle(true)
