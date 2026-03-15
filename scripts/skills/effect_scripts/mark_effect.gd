extends Skill_Effect
class_name Mark_Effect

@export var duration: int = 3

# Mark a target, targets are more likely to be targeted by enemies
func _apply_effect(_actor: Node2D, target: Node2D):
	target.char_stats._mark_actor(duration)
	target.actor_ui.buff_container._toggle_mark(true)
