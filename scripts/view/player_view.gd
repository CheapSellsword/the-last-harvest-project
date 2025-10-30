# player_view.gd
# This script is attached to the PlayerView.tscn (a CharacterBody2D).
# This is the "View." It handles rendering, input, and physics collisions.
# It reads its *intent* from the SimulationManager.

extends CharacterBody2D

# This node's job is to read input and move.
# It does NOT hold state like stamina or inventory.

func _physics_process(_delta: float):
	# --- 1. Get Input ---
	# Read player's raw input
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# --- 2. Transform for Isometric View ---
	# This maps diamond-style controls to our isometric world
	var iso_direction = Vector2.ZERO
	iso_direction.x = (input_direction.x - input_direction.y)
	iso_direction.y = (input_direction.x + input_direction.y) * 0.5 # Adjust 0.5 as needed for your art style
	
	# --- 3. Report Input to Simulation ---
	# We don't use the input directly. We send it to the "brain."
	SimulationManager.set_player_input_direction(iso_direction)
	
	# --- 4. Get Velocity from Simulation ---
	# Read the *calculated* velocity from the "brain."
	# The "brain" might have set it to zero (e.g., out of stamina).
	velocity = SimulationManager.player_velocity
	
	# --- 5. Execute Movement (View/Physics) ---
	# Let the Godot physics engine handle the collision and movement.
	move_and_slide()
	
	# --- 6. Report State back to Simulation ---
	# After moving, tell the "brain" where we are now.
	SimulationManager.set_player_position(global_position)
	
	# --- 7. Update View (Animation) ---
	# We'd also update our animations here based on `velocity`.
	# (e.g., $Sprite2D.play("walk_down") or $Sprite2D.flip_h)
	_update_animation(iso_direction)


func _update_animation(iso_direction: Vector2):
	var sprite = $Sprite2D # Assuming your sprite node is named Sprite2D
	if !sprite: return

	if velocity.length_squared() > 0.1:
		# This logic will depend on your sprite sheet.
		# A common way is to find the dominant axis.
		if abs(iso_direction.x) > abs(iso_direction.y):
			if iso_direction.x > 0:
				pass # play("walk_right")
			else:
				pass # play("walk_left")
		else:
			if iso_direction.y > 0:
				pass # play("walk_down")
			else:
				pass # play("walk_up")
	else:
		pass # play("idle_down")
