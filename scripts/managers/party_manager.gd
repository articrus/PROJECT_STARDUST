extends Node2D
# Written By: Gianni Coladonato
# Date Created / Modified: 24-10-2025 / 06-03-2026
@onready var core = $CORE
# The current party, the character at 0 is the leader/in control
@export var party = []

func _ready():
	Signalbus.pass_party_to_load.connect(_init_players)
	Signalbus.refresh_player_data.connect(_apply_new_player_data)
	Signalbus.temp_do_chatter.connect(_two_party_chatter)
	GameManager._on_world_ready()

func _init_players(current_party):
	for player_type in current_party:
		var new_player = GameManager.player_templates[player_type].instantiate()
		call_deferred("add_child", new_player)
		party.append(new_player)
		new_player.pending_data = GameManager.player_data_saves[player_type].duplicate(true)
		new_player.pending_quips = Dialogue_Parser._get_player_quip_lines(player_type)
	party[0].current_state = enums.PLAYER_CONTROL_STATUS.CONTROLLED
	_init_dialogue(current_party)
	core._add_followers(party)

func _init_dialogue(current_party):
	var party_source = current_party.duplicate() # Init Two-Character resources (testing to see sorting)
	party_source.shuffle()
	var key_one = _generate_dialogue_key([party_source[0], party_source[1]])
	var key_two = _generate_dialogue_key([party_source[0], party_source[2]])
	var key_three = _generate_dialogue_key([party_source[1], party_source[2]])
	# Assign Dialogue Trees to manager
	DialogueManager.two_chara_dialogue[key_one] = Dialogue_Parser._get_two_character_dialogue(key_one)
	DialogueManager.two_chara_dialogue[key_two] = Dialogue_Parser._get_two_character_dialogue(key_two)
	DialogueManager.two_chara_dialogue[key_three] = Dialogue_Parser._get_two_character_dialogue(key_three)
	#print(str(key_one) + " " + str(key_two) + " " + str(key_three))

# Tweak a little but yeah
func _apply_new_player_data():
	for i in range(party.size()):
		party[i].char_stats._load_player_data(GameManager._get_player_data(party[i].player_type))
		party[i].actor_ui._update_hp_bar(party[i].char_stats.hp)

func _two_party_chatter() -> void:
	var randomly_sorted = party.duplicate()
	randomly_sorted.shuffle()
	var first = party.find(randomly_sorted[0])
	var second = party.find(randomly_sorted[1])
	var key = _generate_dialogue_key([randomly_sorted[0].player_type, randomly_sorted[1].player_type])
	DialogueManager._two_chara_dialogue(party[first], party[second], key)
	randomly_sorted = null

func _generate_dialogue_key(actors) -> String:
	actors.sort()
	return str(enums.PLAYERS_STRING[actors[0]] + "_" + enums.PLAYERS_STRING[actors[1]])
