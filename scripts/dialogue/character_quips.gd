extends Resource
class_name Character_Quips
# An array of skip quotes
@export var battle_start: = []
@export var skip_quotes: = []
@export var crit_quotes: = []
@export var signature_skill = []

func _random_integer(size: int) -> int: return randi_range(0, size-1)

func _get_skip_quote() -> String: return skip_quotes[_random_integer(skip_quotes.size())]

func _get_crit_quote() -> String: return crit_quotes[_random_integer(crit_quotes.size())]

func _get_battle_start_quote() -> String: return battle_start[_random_integer(battle_start.size())]

func _get_signature_quote() -> String: return signature_skill[_random_integer(signature_skill.size())]
