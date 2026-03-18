extends Node2D
# Written By: Gianni Coladonato
# Date Created/Modificed: 27-10-2025 | 17-03-2026
# Scene Components
@onready var party_node = $Players
@onready var enemies_node = $Enemies
@onready var rank_manager = $Ranks
@onready var enemy_rank_manager = $EnemyRanks
@onready var battle_hud = $CanvasLayer/BattleHUD
@onready var targetor = $Targetor
@onready var battle_cam = $BattleCam
@onready var timers = $Timers
# The Current Sate of the Battle
@export var current_state : enums.STATE = enums.STATE.SETUP:
	set(value):
		if value != current_state:
			current_state = value
# Variables
var player_turn: bool 
var targeting_index: int
var turn_index: int
var player_dictionary = {}
var player_entry = {
	"Target": Node2D,
	"Choice": enums.PLAYER_CHOICE.NONE,
	"Cost": 0,
	"Skill": Skill,
	"Rank": 0 }
var current_player
var turn_order = []

func _ready() -> void:
	player_turn = true
	_connect_signals()
	timers._connect_to_battle_manager(self)

###---INITIATION FUNCTIONS---###
# Connect all signals for battle hud
func _connect_signals():
	Signalbus.attack_selected.connect(_attack_option_selected) # Connect attack option
	Signalbus.move_selected.connect(_move_option_selected) # Connect move option
	Signalbus.skipped_selected.connect(_skip_option_selected) # Connect skip option
	Signalbus.skill_selected.connect(_skill_option_selected) # Connect skill select
	Signalbus.skill_button_pressed.connect(_skill_selected) # Connect specific chosen skill

# Called when Node is loaded
func _on_battle_scene_ready():
	_load_players_into_scene(GameManager.current_party)
	#_load_enemies_into_scene(encounter_data) #Instantiates enemies (make a manager class?)

func _scene_set_up():
	targetor.visible = false
	turn_index = 0
	battle_cam.make_current()
	Battle_Utils._position_players(rank_manager, enemy_rank_manager, party_node, enemies_node)
	battle_hud._populate_profile_container(party_node)
	current_state = enums.STATE.TURN_START

# Grab player data and initialize players
func _load_players_into_scene(current_party):
	for player_type in current_party:
		var new_player = GameManager.player_templates[player_type].instantiate()
		call_deferred("_add_child_to_party_node", new_player)
		new_player.pending_data = GameManager.player_data_saves[player_type].duplicate(true)
		new_player.pending_quips = Dialogue_Parser._get_player_quip_lines(player_type)
		_add_entry_to_dictionary(new_player)
	await get_tree().process_frame
	_scene_set_up()

func _add_child_to_party_node(child):
	party_node.add_child(child)

func _add_entry_to_dictionary(player):
	player_dictionary[player] = player_entry.duplicate()

###---PROCESS AND MAIN FUNCTIONS---#
func _process(_delta) -> void:
	match(current_state):
		enums.STATE.TURN_START:
			_start_turn()
		enums.STATE.PLAYER_TURN:
			_player_turn()
		enums.STATE.ENEMY_TURN:
			pass
		enums.STATE.TARGETING_ENEMIES:
			_select_target()
		enums.STATE.TARGETING_PARTY:
			_select_ally()
		enums.STATE.TARGETING_SELF:
			_selecting_self()
		enums.STATE.TARGETING_ALL_ENEMIES:
			_select_all()
		enums.STATE.TARGETING_ALL_ALLIES:
			_select_all()
		enums.STATE.CHANGING_POSITION:
			_select_rank()
		enums.STATE.CHOOSING_SKILL:
			_selecting_skill()
		enums.STATE.COMBAT_OVER:
			pass

func _start_turn():
	if player_turn:
		turn_index = 0
		current_state = enums.STATE.PLAYER_TURN
		battle_hud._toggle_player_buttons(true)
		current_player = party_node.get_child(turn_index)
		battle_hud._set_current_turn_profile(current_player)
		if !current_player.char_stats.is_alive:
			_switch_to_next_player()
		else:
			battle_hud._set_option_name_and_descriptions(current_player.char_stats)
	else: 
		current_state = enums.STATE.ENEMY_TURN
		_enemy_turn()

func _player_turn():
	if Input.is_action_just_pressed("cancel") && turn_index > 0: # Go back one turn
		current_state = enums.STATE.NONE # Prevent process from running this method a second time
		#_reset_choice(current_player)
		turn_index -= 1
		current_player = party_node.get_child(turn_index)
		ManaManager._add_mana(player_dictionary[current_player].Cost)
		_reset_choice(current_player)
		battle_hud._set_option_name_and_descriptions(current_player.char_stats)
		battle_hud._set_current_turn_profile(current_player)
		current_state = enums.STATE.PLAYER_TURN

func _attack_option_selected():
	current_state = enums.STATE.TARGETING_ENEMIES
	player_dictionary[current_player].Choice = enums.PLAYER_CHOICE.ATTACK
	player_dictionary[current_player].Skill = current_player.char_stats.char_attack
	_reset_targetor()
	targetor._adjust_targeting(enemies_node.get_child(0))
	battle_hud._toggle_player_buttons(false)

func _move_option_selected():
	current_state = enums.STATE.CHANGING_POSITION
	_reset_targetor()
	targetor._adjust_targeting(rank_manager.get_child(0))
	battle_hud._toggle_player_buttons(false)

func _skill_option_selected():
	battle_hud._toggle_player_buttons(false)
	battle_hud._populate_skill_container(current_player.char_stats)
	current_state = enums.STATE.CHOOSING_SKILL

# Handle logic of a specific skill chosen (assigning target)
func _skill_selected(skill: Skill):
	player_dictionary[current_player].Choice = enums.PLAYER_CHOICE.SKILL 
	player_dictionary[current_player].Skill = skill 
	battle_hud._toggle_skill_list(false)
	# Add a handle for not_self (should be easy enough to configure)
	_reset_targetor()
	match skill.skill_target:
		enums.TARGET.ENEMY:
			current_state = enums.STATE.TARGETING_ENEMIES
			targetor._adjust_targeting(enemies_node.get_child(0))
		enums.TARGET.ALLY:
			current_state = enums.STATE.TARGETING_PARTY
			targetor._adjust_targeting(party_node.get_child(0))
		enums.TARGET.SELF:
			current_state = enums.STATE.TARGETING_SELF
			targeting_index = turn_index
			targetor._adjust_targeting(current_player)
		enums.TARGET.ALL_ENEMIES:
			current_state = enums.STATE.TARGETING_ALL_ENEMIES
			targetor._adjust_targeting(enemies_node)
		enums.TARGET.ALL_ALLIES:
			current_state = enums.STATE.TARGETING_ALL_ALLIES
			targetor._adjust_targeting(party_node)

func _skip_option_selected():
	DialogueManager._skip_quip(current_player)
	player_dictionary[current_player].Choice = enums.PLAYER_CHOICE.NONE 
	player_dictionary[current_player].Cost = -15.0 # Save Cost
	battle_hud._toggle_player_buttons(false)
	_switch_to_next_player()

###---TARGETING FUNCTIONS---###
# Sets a single target
func _set_single_target(node: Node) -> void:
	targetor.visible = false
	player_dictionary[current_player].Target = node.get_child(targeting_index)
	player_dictionary[current_player].Cost = player_dictionary[current_player].Skill.cost
	_switch_to_next_player()

# Single target functions
func _set_attack_target(): _set_single_target(enemies_node)
func _set_friendly_target(): _set_single_target(party_node)

# Set player move target
func _set_move_target():
	targetor.visible = false
	player_dictionary[current_player].Choice = enums.PLAYER_CHOICE.MOVE
	player_dictionary[current_player].Rank = targeting_index
	player_dictionary[current_player].Cost = 0.0
	_switch_to_next_player()

func _set_all_target():
	targetor.visible = false
	match current_state:
		enums.STATE.TARGETING_ALL_ENEMIES:
			player_dictionary[current_player].Target = enemies_node
		enums.STATE.TARGETING_ALL_ALLIES:
			player_dictionary[current_player].Target = party_node
	player_dictionary[current_player].Cost = player_dictionary[current_player].Skill.cost
	_switch_to_next_player()

func _switch_to_next_player():
	turn_index += 1
	ManaManager._remove_mana(player_dictionary[current_player].Cost)
	if turn_index >= party_node.get_child_count():
		current_state = enums.STATE.RESOLVE_CHOICES
		_resolve_player_choices()
	else:
		current_player = party_node.get_child(turn_index)
		battle_hud._set_option_name_and_descriptions(current_player.char_stats)
		battle_hud._set_current_turn_profile(current_player)
		if !current_player.char_stats.is_alive:
			player_dictionary[current_player].Choice = enums.PLAYER_CHOICE.NONE
			_switch_to_next_player()
		else:
			current_state = enums.STATE.PLAYER_TURN
			battle_hud._toggle_player_buttons(true)

func _cancel_targeting():
	battle_hud._toggle_skill_list(false)
	targetor.visible = false
	current_state = enums.STATE.NONE
	var refund = player_dictionary[current_player].Cost
	_reset_choice(current_player)
	ManaManager._add_mana(refund)
	current_state = enums.STATE.PLAYER_TURN
	battle_hud._toggle_player_buttons(true)

func _reset_choice(player) -> void:
	player_dictionary[player].Choice = enums.PLAYER_CHOICE.NONE
	player_dictionary[player].Cost = 0.0

###---SELECTING FUNCTIONS---###
# Select an enemy target
func _select_target():
	Battle_Utils._handle_section_input(
		func(): _cycle_enemy_targets(1),
		func(): _cycle_enemy_targets(-1),
		func(): _set_attack_target(), # Return attack target
		func(): _cancel_targeting() )

# For selecting all enemies or allies (handled in _set_all_target())
func _select_all():
	Battle_Utils._handle_section_input(
		func(): pass, func(): pass,
		func(): _set_all_target(),
		func(): _cancel_targeting())

# Select a rank to swap to
func _select_rank():
	Battle_Utils._handle_section_input(
		func(): _cycle_ranks(1),
		func(): _cycle_ranks(-1),
		func(): _set_move_target(), # Return new rank
		func(): _cancel_targeting() )

# Select an ally
func _select_ally():
	Battle_Utils._handle_section_input(
		func(): _cycle_allies(1),
		func(): _cycle_allies(-1),
		func(): _set_friendly_target(), # Return friendly target
		func(): _cancel_targeting() )

func _selecting_skill():
	Battle_Utils._handle_section_input(
		func(): pass, func(): pass, func(): pass,
		func(): _cancel_targeting() )

func _selecting_self():
		Battle_Utils._handle_section_input(
		func(): pass, func(): pass,
		func(): _set_friendly_target(), #Return self
		func(): _cancel_targeting() )

# Cycle through enemy targets
func _cycle_enemy_targets(newIndex: int) -> void:
	targeting_index = targetor._cycle_targets(enemies_node, newIndex, targeting_index)

# Cycle through player ranks
func _cycle_ranks(newIndex: int) -> void:
	targeting_index = targetor._cycle_targets(rank_manager, newIndex, targeting_index)

func _cycle_allies(newIndex: int) -> void:
	targeting_index = targetor._cycle_targets(party_node, newIndex, targeting_index)

# End the turn and switch sides
func _end_turn():
	player_turn = !player_turn
	if Battle_Utils._check_if_no_enemies_remain(enemies_node):
		current_state = enums.STATE.COMBAT_OVER
		print("Victory")
		_on_battle_end()
	elif Battle_Utils._check_if_all_players_downed(party_node):
		current_state = enums.STATE.GAME_OVER
	else:
		current_state = enums.STATE.TURN_START

func _reset_targetor():
	targetor.visible = true
	targeting_index = 0

func _resolve_player_choices():
	_sort_turn_order()
	for entry in turn_order:
		var player = entry.Key
		var choice_data = player_dictionary[player]
		var skill = null
		match choice_data.Choice:
			enums.PLAYER_CHOICE.NONE:
				pass
			enums.PLAYER_CHOICE.MOVE:
				var new_rank = choice_data.Rank
				var move_signals = rank_manager._change_target_position(player, new_rank, party_node)
				for sig in move_signals:
					await sig
			enums.PLAYER_CHOICE.SKILL, enums.PLAYER_CHOICE.ATTACK:
				skill = choice_data.Skill
				print(skill.skill_name)
				var target = Battle_Utils._get_valid_target(skill, choice_data)
				# Execute skill against target
				if is_instance_valid(target):
					player.animation_node._skill(skill._get_anim_index(player))
					#ManaManager._attack_mana_bonus(player.char_stats)
					await _process_player_skill(player, skill, target)
		await get_tree().process_frame
	for entry in turn_order:
		entry.Key.char_stats._end_of_turn_checks()
	timers.turn_change.start() #_end_turn()

# Process the player's attack/skill (Check to see if there's any oppertunities for missed calls
func _process_player_skill(player, skill, target):
	await Signalbus.perform_skill
	skill._execute_skill(player, target)
	await Signalbus.skill_finished
	return

func _sort_turn_order():
	turn_order.clear()
	for key in player_dictionary.keys():
		turn_order.append({"Key": key, "Value": player_dictionary[key].Choice})
	turn_order.sort_custom(Battle_Utils._sort_turn_order_values)

# Enemy turn logic (Do similar things to player logic (attack and skill handling)
func _enemy_turn():
	for enemy in enemies_node.get_children():
		var decision = enemy.enemy_brain._make_decision(party_node, enemies_node)
		await get_tree().process_frame
		var skill = null
		match decision:
			enums.ENEMY_CHOICE.SIG_SKILL:
				skill = enemy.enemy_brain.signature_skill
			enums.ENEMY_CHOICE.SKILL:
				skill = enemy.enemy_brain._get_enemy_skill()
			enums.ENEMY_CHOICE.ATTACK:
				skill = enemy.enemy_brain.attack
		var target = Battle_Utils._get_skill_target(skill.skill_target, enemy, party_node, enemies_node)
		if is_instance_valid(target):
			enemy.animation_node._skill(skill._get_anim_index(enemy))
			#ManaManager._damage_mana_bonus(enemy.char_stats)
			await Signalbus.perform_skill
			skill._execute_skill(enemy, target)
			await Signalbus.skill_finished
		await get_tree().process_frame
	for enemy in enemies_node.get_children():
		enemy.enemy_brain._end_of_turn_check()
	timers.turn_change.start() #_end_turn()

func _on_battle_end():
	Battle_Utils._save_player_data(party_node)
	timers.battle_end.start()
