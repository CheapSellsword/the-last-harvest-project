# item_definition.gd
# This is a DATA TEMPLATE. It defines what an "Item" is in our game.
# We will create .tres files from this script.
# It holds IMMUTABLE data. "quantity" is NOT stored here.

@tool
class_name ItemDefinition
extends Resource

## The unique string ID (e.g., "parsnip_seed", "stone").
@export var id: StringName

## The player-facing name (e.g., "Parsnip Seed").
@export var display_name: String

## The in-game description.
@export_multiline var description: String

## The texture for the UI.
@export var icon: Texture2D

## Can this item stack in the inventory?
@export var stackable: bool = true

## If stackable, what's the max stack size?
@export var max_stack_size: int = 99
