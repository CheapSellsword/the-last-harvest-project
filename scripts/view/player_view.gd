# player_view.gd
# This script is attached to the PlayerView.tscn (a CharacterBody2D).
# This is the "View." It handles rendering, input, and physics collisions.
# It reads its *intent* from the SimulationManager.

extends CharacterBody2D

# --- Interaction Variables ---
@onready var cursor_visual = $Cursor # Ensure you created this Sprite2D child!
const INTERACTION_DISTANCE: float = 64.0

# --- Core Logic ---
func _physics_process(_delta: float):
	# 1. Handle Movement (Existing Logic)
	_handle_movement()
	
	# 2. Handle Interaction (New Logic)
	_handle_interaction_input()

func _handle_movement():
	# --- 1. Get Input ---
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# --- 2. Transform for Isometric View ---
	var iso_direction = Vector2.ZERO
	iso_direction.x = (input_direction.x - input_direction.y)
	iso_direction.y = (input_direction.x + input_direction.y) * 0.5
	
	# --- 3. Report Input to Simulation ---
	SimulationManager.set_player_input_direction(iso_direction)
	
	# --- 4. Get Velocity from Simulation ---
	velocity = SimulationManager.player_velocity
	
	# --- 5. Execute Movement (View/Physics) ---
	move_and_slide()
	
	# --- 6. Report State back to Simulation ---
	SimulationManager.set_player_position(global_position)
	
	# --- 7. Update View (Animation) ---
	_update_animation(iso_direction)

func _handle_interaction_input():
	# 1. Calculate cursor position (Projected in front of player)
	var facing_dir = velocity.normalized()
	if facing_dir.length_squared() < 0.1:
		facing_dir = Vector2.DOWN # Default to down if standing still
	
	# Simple isometric projection offset (adjust 32.0 based on your tile size)
	var target_pos = global_position + (facing_dir * 32.0)
	
	# 2. Update Visual Cursor
	if cursor_visual:
		cursor_visual.global_position = target_pos
	
	# 3. Send Intent on Click/Press
	if Input.is_action_just_pressed("ui_accept"): # Spacebar or Enter
		# Convert global pixels to Sim Grid coordinates.
		# Standard Isometric conversion:
		var grid_x = int(target_pos.x / 32.0 + target_pos.y / 16.0)
		var grid_y = int(target_pos.y / 16.0 - target_pos.x / 32.0)
		var grid_coords = Vector2i(grid_x, grid_y)
		
		SimulationManager.player_interact_grid(grid_coords)

func _update_animation(iso_direction: Vector2):
	var sprite = $Sprite2D
	if !sprite: return

	if velocity.length_squared() > 0.1:
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
