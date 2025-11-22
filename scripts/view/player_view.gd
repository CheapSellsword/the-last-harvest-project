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
# New variables for interaction
@onready var cursor_visual = $Cursor # Ensure you added this node!

# How far away can we select?
const INTERACTION_DISTANCE: float = 64.0

func _physics_process(_delta: float):
	# ... existing movement code ... (Input -> iso_direction -> Sim -> move_and_slide)
	
	_handle_interaction_input()

func _handle_interaction_input():
	# 1. Calculate where the "cursor" should be.
	# For keyboard: It's in front of the player.
	# For mouse: It's at the mouse position.
	
	# Let's implement a simple "Tile in front of player" logic for now.
	# We need the last non-zero input direction to know which way we are facing.
	var facing_dir = velocity.normalized()
	if facing_dir.length() == 0:
		# Fallback if standing still (you might want to store 'last_facing_dir' variable)
		facing_dir = Vector2.DOWN 
	
	# Calculate global target position (offset by some distance)
	var target_pos = global_position + (facing_dir * 32.0)
	
	# 2. Snap to Grid (View Logic)
	# Isometric grid snapping can be tricky.
	# Godot's TileMapLayers have a built-in function: local_to_map().
	# However, PlayerView doesn't know about the TileMap.
	# We will ESTIMATE grid coordinates purely for visual feedback here.
	# Assuming standard isometric projection (2:1 ratio).
	
	# Simple hack for snapping:
	if cursor_visual:
		cursor_visual.global_position = target_pos
	
	# 3. Send Input
	if Input.is_action_just_pressed("ui_accept"): # Spacebar or Enter
		# We need to convert this pixel position to Grid Coordinates for the Simulation.
		# Since we don't have reference to the TileMap here, we have two choices:
		# A. Pass global pixels to Sim, let Sim figure it out.
		# B. Use a helper to convert.
		
		# Let's send Global Pixels and let the Sim handles the specific mapping logic
		# OR, strictly, the Sim shouldn't know about pixels.
		
		# ARCHITECTURE FIX: The PlayerView should ideally ask the Game/WorldView to convert.
		# But to keep it simple for Phase 3:
		# We will calculate a "rough" grid coordinate based on tile size (e.g. 32x16).
		
		# Isometric conversion (Cartesian to Iso Grid):
		var grid_x = int(target_pos.x / 32.0 + target_pos.y / 16.0)
		var grid_y = int(target_pos.y / 16.0 - target_pos.x / 32.0)
		var grid_coords = Vector2i(grid_x, grid_y)
		
		# Send Intent
		SimulationManager.player_interact_grid(grid_coords)
