extends Node2D
# Written By: Gianni Coladonato
# Date Created/Modificed: 27-10-2025 | 25-04-2026
# Scene Components
@onready var party_node = $Players
@onready var enemies_node = $Enemies
@onready var ranks = $Ranks
@onready var battle_hud = $CanvasLayer/BattleHUD
@onready var targetor = $Targetor
@onready var battle_cam = $BattleCam
@onready var timers = $Timers
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
	"Target": null,
	"Choice": enums.PLAYER_CHOICE.NONE, 
	"Cost": 0,
	"Skill": null }
var current_player
var turn_order = []

func _ready() -> void:
	player_turn = true
	_connect_signals()
	timers._connect_to_battle_manager(self)

###---INITIATION FUNCTIONS---###
func _connect_signals(): # Connect all signals for battle hud
	Signalbus.attack_selected.connect(_attack_option_selected) # Connect attack option
	Signalbus.skipped_selected.connect(_skip_option_selected) # Connect skip option
	Signalbus.skill_selected.connect(_skill_option_selected) # Connect skill select
	Signalbus.skill_button_pressed.connect(_skill_selected) # Connect specific chosen skill

func _on_battle_scene_ready(encounter: Encounter_Data): # Called when Node is loaded
	await _load_players_into_scene(GameManager.current_party)
	await _load_enemies_into_scene(encounter)
	_scene_set_up()

func _scene_set_up():
	targetor.visible = false
	turn_index = 0
	battle_cam.make_current()
	Battle_Utils._position_players(ranks, party_node, enemies_node)
	battle_hud._populate_profile_container(party_node)
	current_state = enums.STATE.TURN_START

func _load_players_into_scene(current_party): # Grab player data and instantiate players
	for player_type in current_party:
		var new_player = Player_Loader._load_player(player_type).instantiate()
		call_deferred("_add_child_to_node", new_player, party_node)
		new_player.pending_data = Player_Loader._load_player_data(player_type).duplicate(true)
		new_player.pending_quips = Dialogue_Parser._get_player_quip_lines(player_type)
		_add_entry_to_dictionary(new_player)
	await get_tree().process_frame

func _load_enemies_into_scene(encounter: Encounter_Data) -> void: # Grab encoutner data and instantiate enemies
	for monster in encounter.enemies:
		var new_enemy = Enemy_List._get_monster(monster).instantiate()
		call_deferred("_add_child_to_node", new_enemy, enemies_node)
		# Pass any necessary data/modifiers here
	await get_tree().process_frame

func _add_child_to_node(child, node):
	node.add_child(child)

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
		enums.STATE.TARGETING_PARTY_NOT_SELF:
			_select_ally_not_self()
		enums.STATE.TARGETING_SELF:
			_selecting_self()
		enums.STATE.TARGETING_ALL_ENEMIES:
			_select_all()
		enums.STATE.TARGETING_ALL_ALLIES:
			_select_all()
		enums.STATE.CHOOSING_SKILL:
			_selecting_skill()
		enums.STATE.RESOLVE_CHOICES:
			pass
		enums.STATE.COMBAT_OVER:
			pass

func _start_turn():
	if player_turn:
		turn_index = 0
		for player in party_node.get_children(): #Apply dot damage
			player.char_stats._start_of_turn_checks()
		battle_hud._toggle_buttons_lists(true, false)
		current_player = party_node.get_child(turn_index)
		battle_hud._set_current_turn_profile(current_player)
		current_state = enums.STATE.PLAYER_TURN
		if !current_player.char_stats.is_alive:
			_switch_to_next_player()
		else:
			battle_hud._set_option_name_and_descriptions(current_player.char_stats)
	else: 
		current_state = enums.STATE.ENEMY_TURN
		for enemy in enemies_node.get_children(): # Apply dot damage
			enemy.char_stats._start_of_turn_checks()
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

func _attack_option_selected(): # When the attack option is selected
	current_state = enums.STATE.TARGETING_ENEMIES
	player_dictionary[current_player].Choice = enums.PLAYER_CHOICE.ATTACK
	player_dictionary[current_player].Skill = current_player.char_stats.char_attack
	_reset_targetor()
	targetor._adjust_targeting(enemies_node.get_child(0))
	battle_hud._toggle_buttons_lists(false, false)

func _skill_option_selected(): # When the skill option is selected
	battle_hud._toggle_buttons_lists(false, true)
	battle_hud._populate_skill_container(current_player.char_stats)
	current_state = enums.STATE.CHOOSING_SKILL

func _skill_selected(skill: Skill): # When a specific skill is selected
	player_dictionary[current_player].Choice = enums.PLAYER_CHOICE.SKILL 
	player_dictionary[current_player].Skill = skill 
	battle_hud._toggle_buttons_lists(false, false)
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
		enums.TARGET.ALLY_NOT_SELF:
			current_state = enums.STATE.TARGETING_PARTY_NOT_SELF
			targeting_index = turn_index + 1 #Add check for when last in order
			targetor._adjust_targeting(party_node.get_child(targeting_index))
		enums.TARGET.ALL_ENEMIES:
			current_state = enums.STATE.TARGETING_ALL_ENEMIES
			targetor._adjust_targeting(enemies_node)
		enums.TARGET.ALL_ALLIES:
			current_state = enums.STATE.TARGETING_ALL_ALLIES
			targetor._adjust_targeting(party_node)

func _skip_option_selected() -> void: # When the skip option is selected
	DialogueManager._skip_quip(current_player)
	player_dictionary[current_player].Choice = enums.PLAYER_CHOICE.NONE 
	player_dictionary[current_player].Cost = -15.0 # Save Cost
	battle_hud._toggle_buttons_lists(true, false)
	_switch_to_next_player()

###---TARGETING FUNCTIONS---###
func _set_single_target(node: Node) -> void: # Sets a single target
	targetor.visible = false
	player_dictionary[current_player].Target = node.get_child(targeting_index)
	player_dictionary[current_player].Cost = player_dictionary[current_player].Skill.cost
	_switch_to_next_player()

# Single target functions
func _set_attack_target(): _set_single_target(enemies_node)
func _set_friendly_target(): _set_single_target(party_node)

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
		battle_hud._toggle_buttons_lists(false, false)
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
			battle_hud._toggle_buttons_lists(true, false)

func _cancel_targeting():
	current_state = enums.STATE.NONE
	battle_hud._toggle_buttons_lists(false, false)
	targetor.visible = false
	var refund = player_dictionary[current_player].Cost
	_reset_choice(current_player)
	ManaManager._add_mana(refund)
	current_state = enums.STATE.PLAYER_TURN
	battle_hud._toggle_buttons_lists(true, false)

func _reset_choice(player) -> void:
	player_dictionary[player].Choice = enums.PLAYER_CHOICE.NONE
	player_dictionary[player].Cost = 0.0
	player_dictionary[player].Target = null
	player_dictionary[player].Skill = null

###---SELECTING FUNCTIONS---###
func _select_target(): # Select an enemy target
	Battle_Utils._handle_section_input(
		func(): _cycle_enemy_targets(1),
		func(): _cycle_enemy_targets(-1),
		func(): _set_attack_target(), # Return attack target
		func(): _cancel_targeting() )

func _select_all(): # For selecting all enemies or allies (handled in _set_all_target())
	Battle_Utils._handle_section_input(
		func(): pass, func(): pass,
		func(): _set_all_target(),
		func(): _cancel_targeting())

func _select_ally(): # Select an ally
	Battle_Utils._handle_section_input(
		func(): _cycle_allies(1),
		func(): _cycle_allies(-1),
		func(): _set_friendly_target(), # Return friendly target
		func(): _cancel_targeting() )

func _selecting_skill():
	Battle_Utils._handle_section_input( func(): pass, func(): pass, func(): pass,
		func(): _cancel_targeting() )

func _selecting_self():
		Battle_Utils._handle_section_input(
		func(): pass, func(): pass,
		func(): _set_friendly_target(), #Return self
		func(): _cancel_targeting() )

func _select_ally_not_self():
		Battle_Utils._handle_section_input(
			func(): _cycle_non_self_target(1),
			func(): _cycle_non_self_target(-1),
			func(): _set_friendly_target(),
			func(): _cancel_targeting() )

func _cycle_non_self_target(newIndex: int) -> void:
	targeting_index = targetor._cycle_targets(party_node, newIndex, targeting_index)
	if party_node.get_child(targeting_index) == current_player:
		targeting_index += newIndex
		_cycle_allies(targeting_index) #Move to next ally

func _cycle_enemy_targets(newIndex: int) -> void: # Cycle through enemy targets
	targeting_index = targetor._cycle_targets(enemies_node, newIndex, targeting_index)

func _cycle_allies(newIndex: int) -> void:
	targeting_index = targetor._cycle_targets(party_node, newIndex, targeting_index)

func _end_turn(): # End the turn and switch sides
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
			enums.PLAYER_CHOICE.SKILL, enums.PLAYER_CHOICE.ATTACK:
				skill = choice_data.Skill
				var target = Battle_Utils._get_valid_target(skill, choice_data)
				# Execute skill against target
				if is_instance_valid(target):
					player.animation_node._skill(skill.skill_anim_index)
					#ManaManager._attack_mana_bonus(player.char_stats)
					await _process_player_skill(player, skill, target)
		await get_tree().process_frame
	for entry in turn_order:
		entry.Key.char_stats._end_of_turn_checks()
	timers.turn_change.start() #_end_turn()

func _enemy_turn(): # Enemy turn logic (Do similar things to player logic (attack and skill handling)
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
			enemy.animation_node._skill(skill.skill_anim_index)
			#ManaManager._damage_mana_bonus(enemy.char_stats)
			await Signalbus.perform_skill
			skill._execute_skill(enemy, target)
			await Signalbus.skill_finished
		await get_tree().process_frame
	for enemy in enemies_node.get_children():
		enemy.enemy_brain._end_of_turn_check()
	timers.turn_change.start() #_end_turn()

func _process_player_skill(player, skill, target): # Process the player's skill
	await Signalbus.perform_skill
	skill._execute_skill(player, target)
	await Signalbus.skill_finished
	return

func _sort_turn_order():
	turn_order.clear()
	for key in player_dictionary.keys():
		turn_order.append({"Key": key, "Value": player_dictionary[key].Choice})
	turn_order.sort_custom(Battle_Utils._sort_turn_order_values)

func _on_battle_end():
	Battle_Utils._save_player_data(party_node)
	timers.battle_end.start()
