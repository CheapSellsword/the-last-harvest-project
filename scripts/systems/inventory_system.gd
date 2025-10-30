# inventory_system.gd
# A modular, non-node class for handling inventory LOGIC.
# It is "glued" in by the SimulationManager.
# It operates on an InventoryDefinition resource.

class_name InventorySystem
extends RefCounted

# --- Signal ---
# Emits when any slot is changed. UI connects to this.
signal inventory_changed(slot_index: int)

# --- State ---
# This is the *data* this system manages.
var _inventory_data: InventoryDefinition

# --- Public API ---

func _init(data: InventoryDefinition):
	if data:
		_inventory_data = data
	else:
		printerr("InventorySystem: Initialized with null data!")
		_inventory_data = InventoryDefinition.new()

## Tries to add an item to the inventory.
## First, tries to stack. Second, tries to find an empty slot.
## Returns: int (amount of item that *could not* be added)
func add_item(item_id: StringName, amount: int) -> int:
	var item_def = ItemDatabase.get_item(item_id)
	if !item_def:
		printerr("InventorySystem: Tried to add unknown item '%s'" % item_id)
		return amount
		
	var amount_to_add = amount
	
	# --- 1. Try to stack ---
	if item_def.stackable:
		for i in _inventory_data.slots.size():
			var slot = _inventory_data.slots[i]
			if !slot.is_empty() and slot.item.id == item_id:
				var space_left = slot.get_space_left()
				if space_left > 0:
					var add_amount = min(amount_to_add, space_left)
					slot.quantity += add_amount
					amount_to_add -= add_amount
					inventory_changed.emit(i)
					
					if amount_to_add <= 0:
						return 0 # All items added
	
	# --- 2. Try to find empty slot ---
	if amount_to_add > 0:
		for i in _inventory_data.slots.size():
			var slot = _inventory_data.slots[i]
			if slot.is_empty():
				slot.item = item_def
				var add_amount = min(amount_to_add, item_def.max_stack_size)
				slot.quantity = add_amount
				amount_to_add -= add_amount
				inventory_changed.emit(i)
				
				if amount_to_add <= 0:
					return 0 # All items added
	
	# --- Return leftover amount ---
	return amount_to_add

## Removes a specific amount of an item from a slot.
func remove_item_from_slot(slot_index: int, amount: int):
	if slot_index < 0 or slot_index >= _inventory_data.slots.size():
		return
		
	var slot = _inventory_data.slots[slot_index]
	if !slot.is_empty():
		slot.quantity -= amount
		if slot.quantity <= 0:
			slot.clear() # clear() will set quantity to 0 and item to null
		
		inventory_changed.emit(slot_index)

# --- Getters for the "View" (UI) ---
func get_slot_count() -> int:
	return _inventory_data.slots.size()

func get_slot(index: int) -> InventorySlot:
	if index >= 0 and index < _inventory_data.slots.size():
		return _inventory_data.slots[index]
	return null
