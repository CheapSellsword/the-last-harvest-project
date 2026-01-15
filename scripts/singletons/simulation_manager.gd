# simulation_manager.gd
extends Node

# --- Modular Systems ---
var time_system: TimeSystem
var player_inventory_system: InventorySystem
var world_system: WorldSystem
var movement_system: MovementSystem 
var player_stats_system: StatsSystem # New System

# --- Signals ---
signal player_position_changed(new_position: Vector2)

func _ready():
	# --- Instantiate Simulation Systems ---
	time_system = TimeSystem.new()
	world_system = WorldSystem.new()
	movement_system = MovementSystem.new()
	player_stats_system = StatsSystem.new(100.0) # Initialize with 100 stamina
	
	# Load player inventory
	var player_inv_data = load("res://data/player_inventory.tres") as InventoryDefinition
	if player_inv_data:
		player_inventory_system = InventorySystem.new(player_inv_data)
	else:
		printerr("SimulationManager: Failed to load player_inventory.tres!")
		_create_fallback_inventory()
		
	print("SimulationManager: Ready.")
	
	# --- "Glue" Systems Together ---
	time_system.day_passed.connect(world_system.on_day_passed)

func _create_fallback_inventory():
	var new_inv_def = InventoryDefinition.new()
	var inventory_slot_script = load("res://data/definitions/inventory_slot.gd")
	new_inv_def.slots.resize(36)
	for i in 36:
		var slot = InventorySlot.new()
		if inventory_slot_script: slot.set_script(inventory_slot_script)
		new_inv_def.slots[i] = slot
	player_inventory_system = InventorySystem.new(new_inv_def)

# --- Deliberate Execution Order ---
func _physics_process(delta: float):
	# 1. Update Time
	time_system.update(delta)
	
	# 2. Update Player Logic
	# Pass stamina from stats system to movement system
	movement_system.update(delta, player_stats_system.current_stamina)
	
	# 3. Update World (Uncomment when dynamic world logic is added)
	# world_system.update(delta) 

# --- Glue Code: Interaction ---
func player_interact_grid(grid_coords: Vector2i):
	# Example: Tilling soil costs stamina
	var stamina_cost = 2.0
	
	if player_stats_system.consume_stamina(stamina_cost):
		print("Simulation: Tilling at ", grid_coords)
		world_system.set_tile_tilled(grid_coords)
	else:
		print("Simulation: Too tired to till!")

# --- Public API for the "View" ---

func set_player_input_direction(direction: Vector2):
	movement_system.set_input(direction)

func set_player_position(new_position: Vector2):
	movement_system.set_position(new_position)
	player_position_changed.emit(new_position)

func get_player_velocity() -> Vector2:
	return movement_system.velocity

func get_player_inventory_system() -> InventorySystem:
	return player_inventory_system

func get_world_system() -> WorldSystem:
	return world_system

func get_player_stats() -> StatsSystem:
	return player_stats_system
