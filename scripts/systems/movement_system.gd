class_name MovementSystem
extends RefCounted

# State managed by this system
var velocity: Vector2 = Vector2.ZERO
var position: Vector2 = Vector2.ZERO
var input_direction: Vector2 = Vector2.ZERO

# Stats
var move_speed: float = 150.0

func update(_delta: float, current_stamina: float):
	# Example of modular logic: Can't move if exhausted
	if current_stamina <= 0:
		velocity = input_direction * (move_speed * 0.5) # Exhausted walk
	else:
		velocity = input_direction * move_speed

func set_input(direction: Vector2):
	input_direction = direction.normalized()

func set_position(new_pos: Vector2):
	position = new_pos
