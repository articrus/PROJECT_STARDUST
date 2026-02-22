extends Resource
class_name Character_Quips
# The color of the character's text
@export var text_color : Color = Color.WHITE
# An array of skip quotes
@export var skip_quotes : Array[String]
@export var crit_quotes : Array[String]

# Returns a random skip quote
func _get_skip_quote() -> String:
	var rand = randi_range(0, skip_quotes.size()-1)
	return skip_quotes[rand]

func _get_crit_quote() -> String:
	var rand = randi_range(0, crit_quotes.size()-1)
	return crit_quotes[rand]
