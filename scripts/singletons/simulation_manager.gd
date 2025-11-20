# simulation_manager.gd
# AUTOLOAD SINGLETON
# This is the "Simulation" hub. It owns the core game state and
# the modular logic systems. It also acts as the "glue"
# to connect systems without them knowing about each other.

extends Node

# --- Core Game State ---
# This is the "Simulation" data. The "View" will read from this.
var player_position: Vector2 = Vector2.ZERO
var player_velocity: Vector2 = Vector2.ZERO
var player_stamina: float = 100.0

# --- Modular Systems ---
# We instantiate our logic systems here. They are not nodes.
var time_system: TimeSystem
var player_inventory_system: InventorySystem
var world_system: WorldSystem # <<< NEW SYSTEM

# --- Input State ---
# The View (player_view.gd) will write to this.
var _player_input_direction: Vector2 = Vector2.ZERO

# --- Constants ---
const PLAYER_SPEED: float = 150.0

# --- Signals ---
# The "View" (e.g., the HUD) can connect to these to stay in sync.
signal player_stamina_changed(new_stamina: float)
signal player_position_changed(new_position: Vector2)


func _ready():
	# --- Instantiate Simulation Systems ---
	time_system = TimeSystem.new()
	world_system = WorldSystem.new() # <<< NEW SYSTEM
	
	# Load the player's inventory data (you'll need to create this .tres file)
	# NOTE: This path assumes you fixed the typo and created the file.
	var player_inv_data = load("res://data/player_inventory.tres") as InventoryDefinition
	if player_inv_data:
		player_inventory_system = InventorySystem.new(player_inv_data)
	else:
		printerr("SimulationManager: Failed to load player_inventory.tres!")
		# Create a fallback empty inventory
		var new_inv_def = InventoryDefinition.new()
		# Check if 'definitions' folder was renamed
		var inventory_slot_script = load("res://data/definitions/inventory_slot.gd")
		if inventory_slot_script == null:
			inventory_slot_script = load("res://data/defenitions/inventory_slot.gd")
			
		new_inv_def.slots.resize(36) # Default to 36 slots
		for i in 36:
			var slot = InventorySlot.new()
			# We must assign the script this way if it's not a global class
			if inventory_slot_script and !slot.get_script():
				slot.set_script(inventory_slot_script)
			new_inv_def.slots[i] = slot
		player_inventory_system = InventorySystem.new(new_inv_def)
		
	print("SimulationManager: Ready.")
	
	# --- "Glue" Systems Together ---
	# We connect the TimeSystem's signal to the WorldSystem's function.
	# The two systems don't know about each other.
	time_system.day_passed.connect(world_system.on_day_passed)


# --- Deliberate Execution Order ---
# We use _physics_process as our main simulation "tick".
func _physics_process(delta: float):
	# 1. Update Time
	time_system.update(delta)
	
	# 2. Update Player Logic
	_update_player_simulation(delta)
	
	# 3. Update World (e.g., crop growth, furnace processing)
	# The world_system is now mostly event-driven by time_system,
	# but you could add a world_system.update(delta) here if needed
	# for things like processing machines.
	
	# 4. Update NPCs
	# ... (npc_system.update(delta)) ...
	
	pass


# --- Player Simulation Logic ---
func _update_player_simulation(delta: float):
	# Calculate velocity from the input provided by the View
	player_velocity = _player_input_direction * PLAYER_SPEED
	
	# In a real game, this is where you'd check for stamina, being asleep, etc.
	# For example:
	# if player_stamina <= 0:
	#   player_velocity = Vector2.ZERO
	
	# The *actual* movement and collision is handled by the PlayerView (CharacterBody2D),
	# which will READ this `player_velocity` value. We just calculate it here.
	
	# We don't set player_position here directly, as the PlayerView
	# will report its new position back to us after move_and_slide().
	pass


# --- Public API for the "View" ---
# The PlayerView calls this every frame to tell the simulation
# what the player wants to do.
func set_player_input_direction(direction: Vector2):
	_player_input_direction = direction.normalized()

# The PlayerView calls this after it has moved.
func set_player_position(new_position: Vector2):
	if new_position != player_position:
		player_position = new_position
		player_position_changed.emit(new_position)

# --- Public API for other Systems ---
# This is "glue code." The UI can call this to get the inventory
# system and connect to its signals.
func get_player_inventory_system() -> InventorySystem:
	return player_inventory_system

# --- NEW PUBLIC API ---
## The View (e.g., the TileMap) can get this to connect signals.
func get_world_system() -> WorldSystem:
	return world_system
