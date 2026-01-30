# simulation_manager.gd
extends Node

# --- Modular Systems ---
var time_system: TimeSystem
var player_inventory_system: InventorySystem
var world_system: WorldSystem
var movement_system: MovementSystem 
var player_stats_system: StatsSystem
var tool_system: ToolSystem

# --- Signals ---
signal player_position_changed(new_position: Vector2)

func _ready():
	# --- Instantiate Simulation Systems ---
	time_system = TimeSystem.new()
	world_system = WorldSystem.new()
	movement_system = MovementSystem.new()
	player_stats_system = StatsSystem.new(100.0)
	tool_system = ToolSystem.new()
	
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
	time_system.update(delta)
	movement_system.update(delta, player_stats_system.current_stamina)

# --- Glue Code: Interaction ---
func player_interact_grid(grid_coords: Vector2i):
	print("Simulation: Interact at ", grid_coords)

## Called when player presses "Use Tool" button
func player_use_tool(target_grid_pos: Vector2i):
	var selected_item = player_inventory_system.get_selected_item()
	
	# Check if we are holding a tool
	if selected_item is ToolItemDefinition:
		tool_system.use_tool(selected_item, target_grid_pos, world_system, player_stats_system)
	else:
		print("Simulation: No tool selected.")

# --- DEBUG: Testing ---
func debug_add_test_item():
	if player_inventory_system:
		print("Debug: Adding Hoe and Seeds...")
		player_inventory_system.add_item("hoe", 1)
		player_inventory_system.add_item("parsnip_seed", 5)

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
