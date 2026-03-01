extends Node2D
# Written By: Gianni Coladonato
# Date Created/Modificed: 27-10-2025 | 17-02-2026
# Scene Components
@onready var party_node = $Players
@onready var enemies_node = $Enemies
@onready var rank_manager = $Ranks
@onready var enemy_rank_manager = $EnemyRanks
@onready var battle_hud = $CanvasLayer/BattleHUD
@onready var targetor = $Targetor
@onready var battle_cam = $BattleCam
@onready var turn_change = $TurnChange
# Variables
@export var current_state : enums.STATE = enums.STATE.SETUP
var player_turn: bool 
var targeting_index: int
var turn_index: int
var targetor_offset: = Vector2(0, -10)
#Testing something new
var player_dictionary = {}
var player_entry = {
	"Target": Node2D,
	"Choice": enums.PLAYER_CHOICE.NONE,
	"Cost": 0,
	"Skill": Skill,
	"Rank": 0 }
var current_player
var turn_order = []

func _add_entry_to_dictionary(player):
	player_dictionary[player] = player_entry.duplicate()

func _sort_turn_order():
	turn_order.clear()
	for key in player_dictionary.keys():
		turn_order.append({"Key": key, "Value": player_dictionary[key].Choice})
	turn_order.sort_custom(Battle_Utils._sort_turn_order_values)

func _ready() -> void:
	player_turn = true
	_connect_signals()

func _process(_delta) -> void:
	match(current_state):
		enums.STATE.TURN_START:
			_start_turn()
		enums.STATE.PLAYER_TURN:
			_player_turn()
		enums.STATE.ENEMY_TURN:
			pass
		enums.STATE.TARGETING_ENEMIES:
			battle_hud._toggle_player_buttons(false)
			_select_target()
		enums.STATE.TARGETING_PARTY:
			battle_hud._toggle_player_buttons(false)
			_select_ally()
		enums.STATE.TARGETING_SELF:
			battle_hud._toggle_player_buttons(false)
			_selecting_self()
		enums.STATE.TARGETING_ALL_ENEMIES:
			battle_hud._toggle_player_buttons(false)
			_select_all()
		enums.STATE.TARGETING_ALL_ALLIES:
			battle_hud._toggle_player_buttons(false)
			_select_all()
		enums.STATE.CHANGING_POSITION:
			battle_hud._toggle_player_buttons(false)
			_select_rank()
		enums.STATE.CHOOSING_SKILL:
			_selecting_skill()
		enums.STATE.COMBAT_OVER:
			print("Victory")

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
		_reset_choice(current_player)
		turn_index -= 1
		current_player = party_node.get_child(turn_index)
		ManaManager._add_mana(player_dictionary[current_player].Cost)
		_reset_choice(current_player)
		current_state = enums.STATE.NONE # Prevent process from running this method a second time
		battle_hud._set_option_name_and_descriptions(current_player.char_stats)
		battle_hud._set_current_turn_profile(current_player)
		current_state = enums.STATE.PLAYER_TURN

func _attack_option_selected():
	current_state = enums.STATE.TARGETING_ENEMIES
	player_dictionary[current_player].Choice = enums.PLAYER_CHOICE.ATTACK
	player_dictionary[current_player].Skill = current_player.char_stats.char_attack
	_reset_targetor()
	_adjust_targeting(enemies_node.get_child(0))

func _move_option_selected():
	current_state = enums.STATE.CHANGING_POSITION
	_reset_targetor()
	_adjust_targeting(rank_manager.get_child(0))

func _skill_option_selected():
	var player = party_node.get_child(turn_index)
	battle_hud._populate_skill_container(player.char_stats)
	current_state = enums.STATE.CHOOSING_SKILL

# Handle logic of a specific skill chosen (assigning target)
func _skill_selected(skill_index : int):
	var skill = current_player.char_stats.skill_list[skill_index]
	player_dictionary[current_player].Choice = enums.PLAYER_CHOICE.SKILL 
	player_dictionary[current_player].Skill = skill 
	battle_hud._toggle_skill_list(false)
	# Add a handle for not_self (should be easy enough to configure)
	_reset_targetor()
	match skill.skill_target:
		enums.TARGET.ENEMY:
			current_state = enums.STATE.TARGETING_ENEMIES
			_adjust_targeting(enemies_node.get_child(0))
		enums.TARGET.ALLY:
			current_state = enums.STATE.TARGETING_PARTY
			_adjust_targeting(party_node.get_child(0))
		enums.TARGET.SELF:
			current_state = enums.STATE.TARGETING_SELF
			targeting_index = turn_index
			_adjust_targeting(current_player)
		enums.TARGET.ALL_ENEMIES:
			current_state = enums.STATE.TARGETING_ALL_ENEMIES
			_adjust_targeting(enemies_node)
		enums.TARGET.ALL_ALLIES:
			current_state = enums.STATE.TARGETING_ALL_ENEMIES
			_adjust_targeting(party_node)

func _skip_option_selected():
	DialogueManager._skip_quip(current_player)
	player_dictionary[current_player].Choice = enums.PLAYER_CHOICE.NONE 
	player_dictionary[current_player].Cost = -15.0 # Save Cost
	battle_hud._toggle_player_buttons(false)
	_switch_to_next_player()

###--- TARGET FUNCTIONS ---###
# Sets player to attack target
func _set_attack_target():
	targetor.visible = false
	player_dictionary[current_player].Target = enemies_node.get_child(targeting_index)
	player_dictionary[current_player].Cost = player_dictionary[current_player].Skill.cost
	_switch_to_next_player()

# Set player move target
func _set_move_target():
	targetor.visible = false
	player_dictionary[current_player].Choice = enums.PLAYER_CHOICE.MOVE
	player_dictionary[current_player].Rank = targeting_index
	player_dictionary[current_player].Cost = 0.0
	_switch_to_next_player()

# Sets ally skill target
func _set_friendly_skill_target():
	targetor.visible = false
	player_dictionary[current_player].Target = party_node.get_child(targeting_index)
	player_dictionary[current_player].Cost = player_dictionary[current_player].Skill.cost
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
	current_state = enums.STATE.PLAYER_TURN
	var refund = player_dictionary[current_player].Cost
	_reset_choice(current_player)
	ManaManager._add_mana(refund)
	battle_hud._toggle_player_buttons(true)

func _reset_choice(player) -> void:
	player_dictionary[player].Choice = enums.PLAYER_CHOICE.NONE
	player_dictionary[player].Cost = 0.0

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
		func(): _set_friendly_skill_target(), # Return friendly target
		func(): _cancel_targeting() )

func _selecting_skill():
	Battle_Utils._handle_section_input(
		func(): pass, func(): pass, func(): pass,
		func(): _cancel_targeting() )

func _selecting_self():
		Battle_Utils._handle_section_input(
		func(): pass, func(): pass,
		func(): _set_friendly_skill_target(), #Return self
		func(): _cancel_targeting() )

# Cycle through enemy targets
func _cycle_enemy_targets(newIndex: int) -> void:
	_cycle_targets(enemies_node, newIndex)

# Cycle through player ranks
func _cycle_ranks(newIndex: int) -> void:
	_cycle_targets(rank_manager, newIndex)

func _cycle_allies(newIndex: int) -> void:
	_cycle_targets(party_node, newIndex)

func _cycle_targets(node : Node, delta: int):
	var child_count = node.get_child_count()
	targeting_index = (targeting_index + delta) % child_count
	if targeting_index < 0:
		targeting_index += child_count
	_adjust_targeting(node.get_child(targeting_index))

func _adjust_targeting(target: Node2D) -> void:
	targetor.fixed_position = target.global_position + targetor_offset

# End the turn and switch sides
func _end_turn():
	player_turn = !player_turn
	if Battle_Utils._check_if_no_enemies_remain(enemies_node):
		current_state = enums.STATE.COMBAT_OVER
		_on_battle_end()
	elif Battle_Utils._check_if_all_players_downed(party_node):
		current_state = enums.STATE.GAME_OVER
	else:
		current_state = enums.STATE.TURN_START

func _reset_targetor():
	targetor.visible = true
	targeting_index = 0

# Positioning Functions (Maybe reolocate?)
func _position_players():
	var index = 0
	for player in party_node.get_children():
		rank_manager._init_positions(player, index)
		player._enter_battle()
		index += 1
	index = 0
	for enemy in enemies_node.get_children():
		enemy_rank_manager._init_positions(enemy, index)
		index += 1

# Connect all signals for battle hud
func _connect_signals():
	Signalbus.attack_selected.connect(_attack_option_selected) # Connect attack option
	Signalbus.move_selected.connect(_move_option_selected) # Connect move option
	Signalbus.skipped_selected.connect(_skip_option_selected) # Connect skip option
	Signalbus.skill_selected.connect(_skill_option_selected) # Connect skill select
	Signalbus.skill_button_pressed.connect(_skill_selected) # Connect specific chosen skill

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
					if choice_data.Choice == enums.PLAYER_CHOICE.ATTACK:
						player.animation_node._attack(player.char_stats.rank)
						ManaManager._attack_mana_bonus(player.char_stats)
					else:
						player.animation_node._skill()
						#player.animation_node.__skill(skill.anim_type) # To implement soon
					await _process_player_skill(player, skill, target)
		await get_tree().process_frame
	for entry in turn_order:
		entry.Key.char_stats._end_of_turn_checks()
	turn_change.start() #_end_turn()

# Process the player's attack/skill (Check to see if there's any oppertunities for missed calls
func _process_player_skill(player, skill, target) -> void:
	await Signalbus.perform_skill
	skill._execute_skill(player, target)
	await Signalbus.skill_finished
	return

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
		print(enemy.char_stats.chara_name + " targets " + str(target) + " with " + skill.skill_name)
		if is_instance_valid(target):
			if decision == enums.ENEMY_CHOICE.ATTACK:
				enemy.animation_node._attack(enemy.char_stats.rank)
				ManaManager._damage_mana_bonus(enemy.char_stats)
			else:
				enemy.animation_node._skill()
			await Signalbus.perform_skill
			skill._execute_skill(enemy, target)
			await Signalbus.skill_finished
		await get_tree().process_frame
	for enemy in enemies_node.get_children():
		enemy.enemy_brain._end_of_turn_check()
	turn_change.start() #_end_turn()

func _scene_set_up():
	targetor.visible = false
	turn_index = 0
	battle_cam.make_current()
	_position_players()
	battle_hud._populate_profile_container(party_node)
	current_state = enums.STATE.TURN_START

# Called when everything is loaded
func _on_battle_scene_ready():
	_load_players_into_scene(GameManager.current_party)

func _add_child_to_party_node(child):
	party_node.add_child(child)

# Grab player data and initialize players
func _load_players_into_scene(current_party):
	for player_type in current_party:
		var new_player = GameManager.player_templates[player_type].instantiate()
		call_deferred("_add_child_to_party_node", new_player)
		new_player.pending_data = GameManager.player_data_saves[player_type].duplicate(true)
		new_player.pending_quips = Dialogue_Parser._get_player_quip_lines(player_type)
		_add_entry_to_dictionary(new_player) # New Things
	await get_tree().process_frame
	_scene_set_up()

func _on_turn_change_timeout() -> void:
	_end_turn()

func _on_battle_end():
	Battle_Utils._save_player_data(party_node)
	$Temp_End_Timer.start()

func _on_temp_end_timer_timeout() -> void:
	Signalbus.end_encounter.emit()
