extends Skill_Effect
class_name Talk_Effect

@export var quip_category_name: String = ""

func _apply_effect(actor: Node2D, _target: Node2D):
	# Fix/implement this but we've almost got it
	var dialogue = actor.essentials.quips._get_skill_dialogue(quip_category_name)
	DialogueManager._display_dialogue(dialogue, actor)
