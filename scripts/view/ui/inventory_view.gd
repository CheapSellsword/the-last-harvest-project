extends Control

# --- Configuration ---
## Drag the inventory_slot_view.tscn here in the Inspector
@export var slot_scene: PackedScene 

# --- Nodes ---
# Adjust path if your scene structure differs
@onready var grid_container: GridContainer = $Panel/MarginContainer/GridContainer

# --- State ---
var _inventory_system: InventorySystem

func _ready():
	# 1. Get the System
	_inventory_system = SimulationManager.get_player_inventory_system()
	
	if _inventory_system:
		# 2. Connect Signals
		_inventory_system.inventory_changed.connect(_on_inventory_changed)
		
		# 3. Initial Draw
		_initialize_grid()
	
	# Start hidden
	visible = false

func _input(event: InputEvent):
	if event.is_action_pressed("toggle_inventory"): # You need to add this Action in Project Settings
		visible = not visible

# --- Visual Logic ---

func _initialize_grid():
	if !slot_scene or !grid_container:
		printerr("InventoryView: Missing slot_scene or grid_container!")
		return

	# Clear any placeholders
	for child in grid_container.get_children():
		child.queue_free()
	
	# Create a slot UI for every slot in the data
	for i in range(_inventory_system.get_slot_count()):
		var slot_inst = slot_scene.instantiate()
		grid_container.add_child(slot_inst)
		# Update it immediately
		_update_single_slot(i)

func _on_inventory_changed(index: int):
	_update_single_slot(index)

func _update_single_slot(index: int):
	if index < 0 or index >= grid_container.get_child_count():
		return
		
	var slot_ui = grid_container.get_child(index) as InventorySlotView
	var slot_data = _inventory_system.get_slot(index)
	
	if slot_ui:
		slot_ui.update_slot(slot_data)
