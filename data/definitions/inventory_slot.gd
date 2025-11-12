# inventory_slot.gd
# This is a DATA TEMPLATE for a *single slot* in an inventory.
# It holds MUTABLE data (quantity) and a reference
# to the IMMUTABLE item definition.

@tool
class_name InventorySlot
extends Resource

## The definition of the item in this slot.
@export var item: ItemDefinition

## How many of this item are in the slot.
@export_range(0, 999) var quantity: int = 0: # 999 is just a safety
	set(value):
		quantity = value
		if item and quantity > item.max_stack_size:
			quantity = item.max_stack_size
		if quantity <= 0:
			clear()

## Helper to see if the slot is empty.
func is_empty() -> bool:
	return item == null

## Helper to clear the slot.
func clear():
	item = null
	quantity = 0

## Can this slot accept this item type?
func can_accept_item(item_def: ItemDefinition) -> bool:
	if is_empty():
		return true
	if item.id == item_def.id and item.stackable:
		return quantity < item.max_stack_size
	return false

## Returns how much space is left in this stack.
func get_space_left() -> int:
	if is_empty():
		return 999 # Technically infinite, but we need a number
	if item.stackable:
		return item.max_stack_size - quantity
	return 0
