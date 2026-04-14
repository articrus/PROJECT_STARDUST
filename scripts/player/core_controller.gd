extends CharacterBody2D
@export var move_speed: float
@export var distance_spacing:= 24.0
var ACCELERATION:= 20
var FRICTION:= 25
var followers : Array[Node2D] = []
var trail_points : Array[Vector2] = []
var is_moving := false
const TRAIL_STEP := 4.0

func _physics_process(_delta: float) -> void:
	_handle_input()
	move_and_slide()
	_update_trail()
	_update_followers()

# Handle movement input
func _handle_input():
	if Input.is_action_just_pressed("pause"):
		GameManager._on_pause()
		return
	if !GlobalVariables.can_move:
		velocity = Vector2.ZERO
		is_moving = false
		return
	var dir = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()
	is_moving = dir != Vector2.ZERO
	velocity = dir * move_speed

# Add the followers to the party
func _add_followers(fellows):
	for f in fellows:
		f.FRICTION = FRICTION
		f.ACCELERATION = ACCELERATION
		followers.append(f)
		# First point
		if trail_points.is_empty():
			trail_points.append(global_position)
		f.global_position = _get_point(distance_spacing * followers.size())

# Update the trail points
func _update_trail():
	if !is_moving:
		return # Don't update if not moving
	if trail_points.is_empty() or trail_points[0].distance_to(global_position) >= TRAIL_STEP: #Keep it from going over
		trail_points.push_front(global_position)
	# Keep trail within required size
	var max_len = int((followers.size() + 1) * (distance_spacing / TRAIL_STEP)) + 2
	while trail_points.size() > max_len:
		trail_points.resize(max_len)

# Update the followers positions
func _update_followers():
	if followers.is_empty():
		return
	# First follower = mimic player position
	var leader = followers[0]
	leader.update_follow_target(
		global_position,
		is_moving,
		velocity.normalized() if is_moving else leader.look_dir
	)
	# Remaining followers
	for i in range(1, followers.size()):
		var pos = _get_point(distance_spacing * i)
		var follower = followers[i]
		var dir = (pos-follower.global_position).normalized()
		follower.update_follow_target(pos, is_moving, dir)

func _get_point(dist: float) -> Vector2:
	if trail_points.is_empty():
		return global_position
	var traveled := 0.0
	for i in range(trail_points.size() - 1):
		var a = trail_points[i]
		var b = trail_points[i + 1]
		var seg_len = a.distance_to(b)
		if traveled + seg_len >= dist:
			var t = ((dist - traveled) / seg_len)
			return a.lerp(b, t)
		traveled += seg_len
	return trail_points.back()
