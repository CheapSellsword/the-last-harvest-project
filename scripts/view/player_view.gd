extends CharacterBody2D

# --- Configuration ---
@export var camera_zoom: Vector2 = Vector2(3.0, 3.0) 

# --- Components ---
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var cursor_visual = $Cursor
@onready var camera = $Camera2D

@onready var state_machine = animation_tree.get("parameters/playback")

const INTERACTION_DISTANCE: float = 64.0

func _ready():
	if animation_tree:
		animation_tree.active = true
	
	if camera:
		camera.zoom = camera_zoom

func _physics_process(_delta: float):
	_handle_movement()
	_handle_interaction_input()
	
	# DEBUG: Press TAB (ui_focus_next) to add test items
	if Input.is_action_just_pressed("ui_focus_next"): 
		SimulationManager.debug_add_test_item()

func _handle_movement():
	# 1. Get Input
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# 2. Report Input to Simulation
	SimulationManager.set_player_input_direction(input_direction)
	
	# 3. Get Calculated Velocity
	velocity = SimulationManager.get_player_velocity()
	
	# 4. Execute Movement
	move_and_slide()
	
	# 5. Report position
	SimulationManager.set_player_position(global_position)
	
	# 6. Update Animation
	_update_animation_parameters(input_direction)

func _handle_interaction_input():
	# Calculate facing direction
	var facing_dir = velocity.normalized()
	if facing_dir.length_squared() < 0.1:
		# Use mouse position relative to player if not moving
		var mouse_dir = (get_global_mouse_position() - global_position).normalized()
		facing_dir = mouse_dir
	
	# Determine target grid position
	var target_pos_world = global_position + (facing_dir * 32.0)
	
	# Optional: Use exact mouse position if mouse is used
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		target_pos_world = get_global_mouse_position()

	if cursor_visual:
		cursor_visual.global_position = target_pos_world
	
	# Convert to Grid
	var grid_pos = IsometricUtils.world_to_grid(target_pos_world)

	# --- Use Tool (Left Click / Space) ---
	if Input.is_action_just_pressed("use_tool"): 
		SimulationManager.player_use_tool(grid_pos)
		_play_action_animation()

	# --- Interact (Enter / Right Click) ---
	if Input.is_action_just_pressed("ui_accept"): 
		SimulationManager.player_interact_grid(grid_pos)

func _play_action_animation():
	# For now, just reuse the Punch animation
	if state_machine:
		state_machine.travel("Punch")

func _update_animation_parameters(move_input: Vector2):
	if !animation_tree or !state_machine:
		return

	if move_input != Vector2.ZERO:
		animation_tree.set("parameters/Idle/blend_position", move_input)
		animation_tree.set("parameters/Run/blend_position", move_input)
		animation_tree.set("parameters/Punch/blend_position", move_input) # Update action direction
		state_machine.travel("Run")
	else:
		state_machine.travel("Idle")
