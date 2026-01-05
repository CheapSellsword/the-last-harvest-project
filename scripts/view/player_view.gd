extends CharacterBody2D

# --- Interaction Variables ---
@onready var cursor_visual = $Cursor
const INTERACTION_DISTANCE: float = 64.0

func _physics_process(_delta: float):
	_handle_movement()
	_handle_interaction_input()

func _handle_movement():
	# 1. Get Input
	# This returns a vector where (-1, 0) is Left, (1, 0) is Right, (0, -1) is Up, (0, 1) is Down.
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# 2. Report Input to Simulation
	# We pass the raw input direction for screen-space movement (W = Up).
	# We REMOVED the isometric transformation math here.
	SimulationManager.set_player_input_direction(input_direction)
	
	# 3. Get Velocity from Simulation
	velocity = SimulationManager.get_player_velocity()
	
	# 4. Execute Movement (View/Physics)
	move_and_slide()
	
	# 5. Report State back to Simulation
	SimulationManager.set_player_position(global_position)
	
	# 6. Update View
	#_update_animation(input_direction)

func _handle_interaction_input():
	var facing_dir = velocity.normalized()
	if facing_dir.length_squared() < 0.1:
		facing_dir = Vector2.DOWN 
	
	# Project interaction point in front of the player
	var target_pos = global_position + (facing_dir * 32.0)
	
	if cursor_visual:
		cursor_visual.global_position = target_pos
	
	if Input.is_action_just_pressed("ui_accept"): 
		# Convert global pixels to Sim Grid coordinates.
		# This formula works regardless of movement style because it maps 
		# screen pixels to the isometric grid layout.
		var grid_x = int(target_pos.x / 32.0 + target_pos.y / 16.0)
		var grid_y = int(target_pos.y / 16.0 - target_pos.x / 32.0)
		var grid_coords = Vector2i(grid_x, grid_y)
		
		# Interact glue code
		SimulationManager.player_interact_grid(grid_coords)

#func _update_animation(_move_direction: Vector2):
	# Animation logic placeholder...
	# Note: _move_direction is now screen-space. 
	# (0, -1) is Up, (1, 0) is Right.
	#pass
