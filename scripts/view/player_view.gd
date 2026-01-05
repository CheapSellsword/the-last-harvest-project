extends CharacterBody2D

# --- Components ---
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var cursor_visual = $Cursor

# The State Machine playback allows us to trigger transitions (travel) via code.
# Note: Use the exact path defined in your AnimationTree's parameters.
@onready var state_machine = animation_tree.get("parameters/playback")

const INTERACTION_DISTANCE: float = 64.0

func _ready():
	# Ensure the tree is active. 
	# From now on, the Tree controls the AnimatedSprite2D, not our code.
	if animation_tree:
		animation_tree.active = true

func _physics_process(_delta: float):
	_handle_movement()
	_handle_interaction_input()

func _handle_movement():
	# 1. Get Input
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# 2. Report Input to Simulation (Domain logic)
	SimulationManager.set_player_input_direction(input_direction)
	
	# 3. Get Calculated Velocity from Simulation
	velocity = SimulationManager.get_player_velocity()
	
	# 4. Execute Movement (Physics)
	move_and_slide()
	
	# 5. Report physical position back to Simulation
	SimulationManager.set_player_position(global_position)
	
	# 6. Update Animation Parameters
	_update_animation_parameters(input_direction)

func _handle_interaction_input():
	# Calculate facing direction based on velocity
	var facing_dir = velocity.normalized()
	if facing_dir.length_squared() < 0.1:
		facing_dir = Vector2.DOWN 
	
	var target_pos = global_position + (facing_dir * 32.0)
	
	if cursor_visual:
		cursor_visual.global_position = target_pos
	
	if Input.is_action_just_pressed("ui_accept"): 
		# Convert pixels to Grid (Isometric conversion)
		var grid_x = int(target_pos.x / 32.0 + target_pos.y / 16.0)
		var grid_y = int(target_pos.y / 16.0 - target_pos.x / 32.0)
		SimulationManager.player_interact_grid(Vector2i(grid_x, grid_y))

func _update_animation_parameters(move_input: Vector2):
	if !animation_tree or !state_machine:
		return

	if move_input != Vector2.ZERO:
		# Update the BlendSpace positions so the tree knows WHICH direction to play
		animation_tree.set("parameters/Idle/blend_position", move_input)
		animation_tree.set("parameters/Run/blend_position", move_input)
		
		# Tell the state machine to transition to Run
		state_machine.travel("Run")
	else:
		# Tell the state machine to transition to Idle
		# It will remember the last 'blend_position' we set above!
		state_machine.travel("Idle")

# --- CLEANUP NOTES ---
# 1. DELETE: Any lines like $AnimatedSprite2D.play("run_down")
# 2. DELETE: Any "facing_direction" variables inside this script, 
#    as the AnimationTree BlendSpace now stores that state for us.
# 3. DELETE: Any code that manually flips the sprite (flip_h), 
#    as your animations in the AnimationPlayer should handle mirroring if needed.
