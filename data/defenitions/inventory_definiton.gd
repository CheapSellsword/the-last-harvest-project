# inventory_definition.gd
# This is a DATA TEMPLATE for an *entire inventory*.
# It's simply an array of InventorySlot resources.
# We'll create .tres files from this (e.g., player_inventory.tres, chest_1.tres)

@tool
class_name InventoryDefinition
extends Resource

## The collection of slots that make up this inventory.
## To set the size in the editor:
## 1. Click the array.
## 2. Set the size (e.g., 36).
## 3. For each slot, click "[empty]" and choose "New InventorySlot".
@export var slots: Array[InventorySlot]
