# world_tile_data.gd
# This is a DATA TEMPLATE for the *simulation state* of a single tile.

@tool
class_name WorldTileData
extends Resource

## What crop is planted here?
@export var crop_definition_id: StringName = &""

## How many days has this crop been growing?
@export var crop_growth_days: int = 0

## Is the soil tilled?
@export var is_tilled: bool = false

## Is the soil watered?
@export var is_watered: bool = false
