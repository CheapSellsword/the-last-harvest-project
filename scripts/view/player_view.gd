extends CharacterBody2D

# --- Interaction Variables ---
@onready var cursor_visual = $Cursor
const INTERACTION_DISTANCE: float = 64.0

func _physics_process(_delta: float):
	_handle_movement()
	_handle_interaction_input()

func _handle_movement():
	# 1. Get Input
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# 2. Transform for Isometric View
	var iso_direction = Vector2.ZERO
	iso_direction.x = (input_direction.x - input_direction.y)
	iso_direction.y = (input_direction.x + input_direction.y) * 0.5
	
	# 3. Report Input to Simulation
	SimulationManager.set_player_input_direction(iso_direction)
	
	# 4. Get Velocity from Simulation (Updated to use Getter)
	velocity = SimulationManager.get_player_velocity()
	
	# 5. Execute Movement (View/Physics)
	move_and_slide()
	
	# 6. Report State back to Simulation
	SimulationManager.set_player_position(global_position)
	
	# 7. Update View
	_update_animation(iso_direction)

func _handle_interaction_input():
	var facing_dir = velocity.normalized()
	if facing_dir.length_squared() < 0.1:
		facing_dir = Vector2.DOWN 
	
	var target_pos = global_position + (facing_dir * 32.0)
	
	if cursor_visual:
		cursor_visual.global_position = target_pos
	
	if Input.is_action_just_pressed("ui_accept"): 
		var grid_x = int(target_pos.x / 32.0 + target_pos.y / 16.0)
		var grid_y = int(target_pos.y / 16.0 - target_pos.x / 32.0)
		var grid_coords = Vector2i(grid_x, grid_y)
		
		# This call will now work because we added it to the manager
		SimulationManager.player_interact_grid(grid_coords)

func _update_animation(_iso_direction: Vector2):
	# Animation logic placeholder...
	pass
